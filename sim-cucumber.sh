#!/usr/bin/env bash

if [ "$USER" = "jenkins" ]; then
    echo "INFO: hey, you are jenkins!  loading ~/.bash_profile_ci"
    source ~/.bash_profile_ci
    hash -r
    rbenv rehash
fi

CUCUMBER_ARGS=$*

if which rbenv > /dev/null; then
    RBENV_EXEC="rbenv exec"
else
    RBENV_EXEC=
fi

${RBENV_EXEC} bundle install

rm -rf ci-reports/calabash
mkdir -p ci-reports/calabash
touch ci-reports/calabash/empty.json

TARGET_NAME="LPSimpleExample-cal"
XC_PROJECT="LPSimpleExample.xcodeproj"
XC_SCHEME="${TARGET_NAME}"
CAL_BUILD_CONFIG=Debug
CAL_BUILD_DIR="${PWD}/build/jenkins"
rm -rf "${CAL_BUILD_DIR}"
mkdir -p "${CAL_BUILD_DIR}"

set +o errexit

xcrun xcodebuild \
    -derivedDataPath "${CAL_BUILD_DIR}" \
    -project "${XC_PROJECT}" \
    -scheme "${TARGET_NAME}" \
    -sdk iphonesimulator \
    -configuration "${CAL_BUILD_CONFIG}" \
    clean build | $RBENV_EXEC bundle exec xcpretty -c

RETVAL=${PIPESTATUS[0]}

set -o errexit

if [ $RETVAL != 0 ]; then
    echo "FAIL:  could not build"
    exit $RETVAL
else
    echo "INFO: successfully built"
fi

# remove any stale targets
$RBENV_EXEC bundle exec calabash-ios sim reset

# Disable exiting on error so script continues if tests fail
set +o errexit

APP_BUNDLE_PATH="${CAL_BUILD_DIR}/Build/Products/${CAL_BUILD_CONFIG}-iphonesimulator/${TARGET_NAME}.app"
cp -r "${APP_BUNDLE_PATH}" ./
export APP_BUNDLE_PATH="./${TARGET_NAME}.app"

RETVAL=0

rbenv exec bundle exec cucumber -p iphone_largest $CUCUMBER_ARGS
#rbenv exec bundle exec cucumber -p default $CUCUMBER_ARGS


set -o errexit

if [ $RETVAL != 0 ]; then
    echo "FAIL: failed $RETVAL out of 9 simulators"
fi

exit $RETVAL


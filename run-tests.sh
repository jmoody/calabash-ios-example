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

xcodebuild \
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

export APP_BUNDLE_PATH="${CAL_BUILD_DIR}/Build/Products/${CAL_BUILD_CONFIG}-iphonesimulator/${TARGET_NAME}.app"

RETVAL=0

$RBENV_EXEC bundle exec cucumber -p sim61_4in          -f json -o ci-reports/calabash/ipad-61-4in.json $CUCUMBER_ARGS
RETVAL=$(($RETVAL+$?))
$RBENV_EXEC bundle exec cucumber -p sim71_4in          -f json -o ci-reports/calabash/iphone-71-4in.json $CUCUMBER_ARGS
RETVAL=$(($RETVAL+$?))

if [ -z $TRAVIS ]; then
    $RBENV_EXEC bundle exec cucumber -p sim71_64b          -f json -o ci-reports/calabash/iphone-71-4in-64b.json $CUCUMBER_ARGS
    RETVAL=$(($RETVAL+$?))
else
    $RBENV_EXEC bundle exec cucumber -p sim70_64b          -f json -o ci-reports/calabash/iphone-70-4in-64b.json $CUCUMBER_ARGS
    RETVAL=$(($RETVAL+$?))
fi

$RBENV_EXEC bundle exec cucumber -p sim61r             -f json -o ci-reports/calabash/iphone-61-3.5in.json $CUCUMBER_ARGS
RETVAL=$(($RETVAL+$?))
$RBENV_EXEC bundle exec cucumber -p sim71r             -f json -o ci-reports/calabash/iphone-71-3.5in.json $CUCUMBER_ARGS
RETVAL=$(($RETVAL+$?))

$RBENV_EXEC bundle exec cucumber -p sim61_ipad_r       -f json -o ci-reports/calabash/ipad-61.json $CUCUMBER_ARGS
RETVAL=$(($RETVAL+$?))
$RBENV_EXEC bundle exec cucumber -p sim71_ipad_r       -f json -o ci-reports/calabash/ipad-71.json $CUCUMBER_ARGS
RETVAL=$(($RETVAL+$?))
$RBENV_EXEC bundle exec cucumber -p sim71_ipad_r_64b   -f json -o ci-reports/calabash/ipad-71-64b.json $CUCUMBER_ARGS
RETVAL=$(($RETVAL+$?))

$RBENV_EXEC bundle exec cucumber -p sim61_sl           -f json -o ci-reports/calabash/ipad-61-no-instruments.json $CUCUMBER_ARGS
RETVAL=$(($RETVAL+$?))

set -o errexit

if [ $RETVAL != 0 ]; then
    echo "FAIL: failed $RETVAL out of 9 simulators"
fi

exit $RETVAL


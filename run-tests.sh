#!/usr/bin/env bash

if [ "$USER" = "jenkins" ]; then
    echo "INFO: hey, you are jenkins!  loading ~/.bash_profile_ci"
    source ~/.bash_profile_ci
    hash -r
    rbenv rehash
fi

CUCUMBER_ARGS=$*

rbenv exec bundle install

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
    clean build | rbenv exec bundle exec xcpretty -c

RETVAL=${PIPESTATUS[0]}

set -o errexit

if [ $RETVAL != 0 ]; then
    echo "FAIL:  could not build"
    exit $RETVAL
else
    echo "INFO: successfully built"
fi

# remove any stale targets
rbenv exec bundle exec calabash-ios sim reset

#sleep 15

# Disable exiting on error so script continues if tests fail
set +o errexit

export APP_BUNDLE_PATH="${CAL_BUILD_DIR}/Build/Products/${CAL_BUILD_CONFIG}-iphonesimulator/${TARGET_NAME}.app"


rbenv exec bundle exec cucumber -p sim61_4in          -f json -o ci-reports/calabash/ipad-61-4in.json $CUCUMBER_ARGS
rbenv exec bundle exec cucumber -p sim71_4in          -f json -o ci-reports/calabash/iphone-71-4in.json $CUCUMBER_ARGS
rbenv exec bundle exec cucumber -p sim71_64b          -f json -o ci-reports/calabash/iphone-71-4in-64b.json $CUCUMBER_ARGS
rbenv exec bundle exec cucumber -p sim61r             -f json -o ci-reports/calabash/iphone-61-3.5in.json $CUCUMBER_ARGS
rbenv exec bundle exec cucumber -p sim71r             -f json -o ci-reports/calabash/iphone-71-3.5in.json $CUCUMBER_ARGS

rbenv exec bundle exec cucumber -p sim61_ipad_r       -f json -o ci-reports/calabash/ipad-61.json $CUCUMBER_ARGS
rbenv exec bundle exec cucumber -p sim71_ipad_r       -f json -o ci-reports/calabash/ipad-71.json $CUCUMBER_ARGS
rbenv exec bundle exec cucumber -p sim71_ipad_r_64b   -f json -o ci-reports/calabash/ipad-71-64b.json $CUCUMBER_ARGS

rbenv exec bundle exec cucumber -p sim61_sl           -f json -o ci-reports/calabash/ipad-61-no-instruments.json $CUCUMBER_ARGS


RETVAL=$?

set -o errexit

exit $RETVAL


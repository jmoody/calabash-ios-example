#!/usr/bin/env bash

if which rbenv > /dev/null; then
    RBENV_EXEC="rbenv exec"
else
    RBENV_EXEC=
fi

${RBENV_EXEC} bundle install

XAMARIN_DIR="${PWD}/xtc-staging"

echo "INFO: creating the ./xtc-staging directory"
rm -rf "${XAMARIN_DIR}"
mkdir -p "${XAMARIN_DIR}"

echo "INFO: copying features over to ${XAMARIN_DIR}"
cp -r features "${XAMARIN_DIR}/"

echo "INFO: installing config/xtc-profiles.yml to ${XAMARIN_DIR}/cucumber.yml"
cp "./config/xtc-profiles.yml" "${XAMARIN_DIR}/cucumber.yml"

TARGET_NAME="LPSimpleExample-cal"
XC_PROJECT="LPSimpleExample.xcodeproj"
XC_SCHEME="${TARGET_NAME}"
CONFIG="Debug"

CAL_DISTRO_DIR="build/xtc"
ARCHIVE_BUNDLE="${CAL_DISTRO_DIR}/lpsimpleexample-cal.xcarchive"
APP_BUNDLE_PATH="${ARCHIVE_BUNDLE}/Products/Applications/${TARGET_NAME}.app"
IPA_PATH="${CAL_DISTRO_DIR}/${TARGET_NAME}.ipa"

rm -rf "${CAL_DISTRO_DIR}"
mkdir -p "${CAL_DISTRO_DIR}"

set +o errexit

if [ -z $TRAVIS ]; then
    xcodebuild archive \
        -project "${XC_PROJECT}" \
        -scheme "${XC_SCHEME}" \
        -configuration "${CONFIG}" \
        -archivePath "${ARCHIVE_BUNDLE}" \
        -sdk iphoneos | ${RBENV_EXEC} bundle exec xcpretty -c
else
    xcodebuild archive \
        -project "${XC_PROJECT}" \
        -scheme "${XC_SCHEME}" \
        -configuration "${CONFIG}" \
        -archivePath "${ARCHIVE_BUNDLE}" \
        -exportArchive \
        -exportFormat IPA \
        -exportPath "${XAMARIN_DIR}/${TARGET_NAME}.ipa"
        -exportSigningIdentity "${1}" \
        -exportProvisioningProfile "${2}" \
        -sdk iphoneos | ${RBENV_EXEC} bundle exec xcpretty -c
fi


RETVAL=${PIPESTATUS[0]}

set -o errexit

if [ $RETVAL != 0 ]; then
    echo "FAIL:  archive failed"
    exit $RETVAL
fi

set +o errexit

if [ -z $TRAVIS ]; then
    xcrun -sdk iphoneos PackageApplication -v "${PWD}/${APP_BUNDLE_PATH}" -o "${PWD}/${IPA_PATH}"  > /dev/null
else
    echo "INFO: will sign with ${1}"
    echo "INFO: and embed ${2}"
    xcrun -sdk iphoneos PackageApplication -v "${PWD}/${APP_BUNDLE_PATH}" -o "${PWD}/${IPA_PATH}" --sign "${1}" --embed "${2}"
fi

RETVAL=$?

set -o errexit

if [ $RETVAL != 0 ]; then
    echo "FAIL:  export archive failed"
    exit $RETVAL
fi

cp "${IPA_PATH}" "${XAMARIN_DIR}/"
exit 0

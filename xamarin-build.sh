#!/bin/sh

XAMARIN_DIR="./xamarin/"

if [ -d "${XAMARIN_DIR}" ]; then
  rm -rf "${XAMARIN_DIR}"
fi

mkdir -p "${XAMARIN_DIR}"

PRODUCT_NAME="LPSimpleExample-cal"
SCHEME="LPSimpleExample-cal"
SIGNING_IDENTITY="iPhone Distribution: Joshua Moody"
PROVISIONING_PROFILE="${HOME}/.xamarin/ios-resign/ljs/F4854C99-1BA3-44E2-954D-3B47D4083DDA.mobileprovision"

echo "INFO: xcodebuild"
xcodebuild -scheme ${SCHEME} archive -configuration Release -sdk iphoneos > /dev/null

DATE=$( /bin/date +"%Y-%m-%d" )
ARCHIVE=$( /bin/ls -t "${HOME}/Library/Developer/Xcode/Archives/${DATE}" | /usr/bin/grep xcarchive | /usr/bin/sed -n 1p )

APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Applications/${PRODUCT_NAME}.app"
IPA="${HOME}/tmp/${PRODUCT_NAME}.ipa"


echo "INFO: xcrun PackageApplication"
xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "${IPA}" --sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE}" > /dev/null


echo "INFO: copying files"
cp "${IPA}" "${XAMARIN_DIR}"
cp -r "${APP}" "${XAMARIN_DIR}"
cp cucumber.yml "${XAMARIN_DIR}"

echo "INFO: making Gemfile ==> ${XAMARIN_DIR}Gemfile"
echo "source 'https://rubygems.org'" > "${XAMARIN_DIR}/Gemfile"
echo "gem 'calabash-cucumber'" >> "${XAMARIN_DIR}/Gemfile"








  

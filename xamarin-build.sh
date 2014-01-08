#!/bin/sh

XAMARIN_DIR="./xamarin/"

if [ -d "${XAMARIN_DIR}" ]; then
  rm -rf "${XAMARIN_DIR}"
fi

mkdir -p "${XAMARIN_DIR}"

PRODUCT_NAME="LPSimpleExample-cal"
SCHEME="LPSimpleExample-cal"

echo "INFO: xcodebuild"
xcodebuild -scheme ${SCHEME} archive -configuration Release -sdk iphoneos > /dev/null

DATE=$( /bin/date +"%Y-%m-%d" )
ARCHIVE=$( /bin/ls -t "${HOME}/Library/Developer/Xcode/Archives/${DATE}" | /usr/bin/grep xcarchive | /usr/bin/sed -n 1p )

APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Applications/${PRODUCT_NAME}.app"
IPA="${HOME}/tmp/${PRODUCT_NAME}.ipa"

# use this strategy for dealing with 3rd party ipas that have been resigned
# with briar resign
# SIGNING_IDENTITY=`cat ${HOME}/.xamarin/ios-resign/default/signing-identity | tr -d '\n'`
# PROVISIONING_PROFILE="${HOME}/.xamarin/ios-resign/default/wildcard.mobileprovision"
# xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "${IPA}" --sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE}" > /dev/null

# use this strategy for simply installing on a local device
xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "${IPA}" > /dev/null


echo "INFO: copying files"
cp "${IPA}" "${XAMARIN_DIR}"
cp -r "${APP}" "${XAMARIN_DIR}"

echo "INFO: making Gemfile ==> ${XAMARIN_DIR}Gemfile"
echo "source 'https://rubygems.org'" > "${XAMARIN_DIR}/Gemfile"
echo "gem 'calabash-cucumber'" >> "${XAMARIN_DIR}/Gemfile"

echo "INFO: making cucumber.yml ==> ${XAMARIN_DIR}cucumber.yml"
echo "xtc_wip:      --tags @wip" > "${XAMARIN_DIR}/cucumber.yml"



rm -rf "${XAMARIN_DIR}/features"
cp -r features "${XAMARIN_DIR}"






  

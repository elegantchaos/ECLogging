#!/bin/bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## Script which uploads the target to Testflight.
## Use this script as a Post-Action script in the Archive phase of a Scheme.
##
## The API token to use is read from the defaults system. To set it use
##     defaults write com.elegantchaos.testflight-upload API_TOKEN <token>
##
## The Team Token is passed in to the script as a first parameter, since it varies with each project.
## The second parameter should be the name of a TestFlight distribution list. All users in the list will be notified
## when the target has been uploaded.

say "uploading to test flight"

TMP=/tmp/testflight-upload
LOG="${TMP}/upload.log"
ERROR_LOG="${TMP}/error.log"

rm "${LOG}"
rm "${ERROR_LOG}"

mkdir -p "$TMP"
echo "Uploading..." > "${LOG}"
echo "" > "${ERROR_LOG}"

GIT=/usr/bin/git

APITOKEN=`defaults read com.elegantchaos.testflight-upload API_TOKEN`
if [[ "${APITOKEN}" == "" ]]; then
    echo "Need to set the TestFlight API token using 'defaults write com.elegantchaos.testflight-upload API_TOKEN <token>'" >> "${ERROR_LOG}"
    open "${ERROR_LOG}"
    say "API token missing"
    exit 1
fi


SCRIPT_DIR=`dirname $0`

# team token and distribution list are per-project settings, so should be passed in
TEAMTOKEN="$1"
shift
DISTRIBUTION="$1"
shift

# set this to true to show a confirmation dialog before doing the upload
CONFIRM_MESSAGE=false

# set this to true to use the git log as the default upload message
DEFAULT_MESSAGE_IS_GIT_LOG=true

MESSAGE=""

if $DEFAULT_MESSAGE_IS_GIT_LOG; then
    # use the git log since the last upload as the upload message
    # any unused shell arguments are passed to git to allow us to filter the log to certain directories (ie to avoid commit messages for unrelated targets)
    MESSAGE=`cd "$PROJECT_DIR"; $GIT log --oneline origin/testflight/latest..HEAD "$@"`
    if [[ $? != 0 ]]; then
        MESSAGE="first upload"
    fi

    if [[ "$MESSAGE" == "" ]]; then
        echo "Empty message! Something is wrong..."
        exit 1
    fi

else
    # default to the last saved message
    if [ -e "${TMP}/upload.txt" ]; then
        MESSAGE=`cat ${TMP}/upload.txt`
    fi
fi

if $CONFIRM_MESSAGE; then
    # use applescript to ask about the upload
    MESSAGE=`osascript -e "tell application id \"com.apple.dt.Xcode\" to text returned of (display dialog \"Upload archive?\" default answer \"$MESSAGE\")"`
    if [[ $? != 0 ]] ; then
        echo "Upload cancelled" >> "${LOG}"
        exit 1
    fi
fi

# archive the last commit message, just in case we want it
echo "$MESSAGE" > "${TMP}/upload.txt"


# make the ipa
echo "Making $EXECUTABLE_NAME.ipa as ${CODE_SIGN_IDENTITY}" >> "${LOG}"
APP="$ARCHIVE_PRODUCTS_PATH/Applications/$EXECUTABLE_NAME.app"
DSYM="$ARCHIVE_DSYMS_PATH/$EXECUTABLE_NAME.app.dSYM"
IPA="$TMPDIR/$EXECUTABLE_NAME.ipa"
XCROOT=`/usr/bin/xcode-select -print-path`
XCRUN="$XCROOT/usr/bin/xcrun"

"$XCRUN" -sdk iphoneos PackageApplication "$APP" -o "$IPA" --sign "${CODE_SIGN_IDENTITY}" --embed "${APP}/${EMBEDDED_PROFILE_NAME}" &> "${TMP}/xcrun.log"

if [[ $? == 0 ]] ; then

        CURLLOG="${TMP}/curl.log"
        CURLERR="${TMP}/curlerr.log"

        echo "Uploading to Test Flight with notes:" >> "${LOG}"
        echo "\"${MESSAGE}\"" >> "${LOG}"
        echo "" >> "${LOG}"
        echo "Distribution list ${DISTRIBUTION} will be mailed." >> "${LOG}"
        echo "" >> "${LOG}"

        zip -q -r "${DSYM}.zip" "${DSYM}"
        rm "$CURLLOG"
        CURL_OPTIONS="--connect-timeout 60 --max-time 600 --retry 10 --retry-delay 1 --retry-max-time 600 --verbose"
        #CURL_OPTIONS="--connect-timeout 60 --max-time 600 --retry 10 --retry-delay 1 --trace-ascii"
        curl http://testflightapp.com/api/builds.json $CURL_OPTIONS --form file="@${IPA}" --form dsym="@${DSYM}.zip" --form api_token="${APITOKEN}" --form team_token="${TEAMTOKEN}" --form notes="${MESSAGE}" --form notify="true" --form distribution_lists="${DISTRIBUTION}" -o "${CURLLOG}" &> "${CURLERR}"
        CONFIG_URL=`"${SCRIPT_DIR}/testflight-extract-url.py" < "${CURLLOG}"`

        if [[ $? == 0 ]] ; then
            say "upload done"
            echo "Upload done." >> "${LOG}"
            open "${CONFIG_URL}"

            # update the git branch
            cd "$PROJECT_DIR";
            $GIT branch testflight/latest HEAD --force
            $GIT push origin testflight/latest

            # clean up if the upload worked
            rm "${DSYM}.zip"
            rm "${IPA}"

        else
            say "upload failed"
            echo "Test Flight returned error:" > "${ERROR_LOG}"
            cat "${CURLLOG}" >> "${ERROR_LOG}"
            echo "Curl errors:" >> "${ERROR_LOG}"
            cat "${CURLERR}" >> "${ERROR_LOG}"

            open "${ERROR_LOG}"

        fi
else
    say "upload failed - couldn't make IPA"
    echo "Failed to build IPA"  >> "${ERROR_LOG}"
    echo "Profile was: ${PROVISIONING_PROFILE}" >> "${TMP}/xcrun.log"
    echo "Identity was: ${CODE_SIGN_IDENTITY}" >> "${TMP}/xcrun.log"
    open "${TMP}/xcrun.log"
    exit 1
fi



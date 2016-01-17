#!/bin/bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## Script which takes the line count of the git log and sets it as the CFBundleVersion number in the target's Info.plist
##
## The script also adds a ECVersionCommit key to the Info.plist with the full SHA1 hash of the current commit.
##
## To use this script, add a Run Script phase to a target, and include this line
##     "${ECLOGGING_SCRIPTS_PATH}/update-version.sh"
##

PLIST="$1"
if [ "$PLIST" == "" ]; then
    PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
fi

VERSION=`git log --oneline | wc -l`
COMMIT=`git rev-parse HEAD`

SHORT_VERSION="$2"

# update the plist in the built app
/usr/libexec/PlistBuddy -c "Add :ECVersionCommit string commit" "$PLIST" >& /dev/null
/usr/libexec/PlistBuddy -c "Set :ECVersionCommit $COMMIT" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$PLIST"
if [[ "$SHORT_VERSION" != "" ]]
then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $SHORT_VERSION" "$PLIST"
fi

echo "Bumped build number to $VERSION ($COMMIT) in $PLIST"

DSYM_PLIST="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"

echo "*${DSYM_PLIST}*"

if [[ -e "${DSYM_PLIST}" ]] ; then

    # update the plist in the dSYM file too so that the build numbers match
    /usr/libexec/PlistBuddy -c "Add :ECVersionCommit string commit" "$DSYM_PLIST" >& /dev/null
    /usr/libexec/PlistBuddy -c "Set :ECVersionCommit $COMMIT" "$DSYM_PLIST"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$DSYM_PLIST"
    if [[ "$SHORT_VERSION" != "" ]]
    then
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $SHORT_VERSION" "$DSYM_PLIST"
    fi

    echo "Also updated dSYM build number"

fi

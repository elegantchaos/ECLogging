#!/bin/bash

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

# update the plist in the built app
/usr/libexec/PlistBuddy -c "Add :ECVersionCommit string commit" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :ECVersionCommit $COMMIT" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$PLIST"

echo "Bumped build number to $VERSION ($COMMIT) in $PLIST"

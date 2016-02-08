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

SHORT_VERSION="$2"

# update the plist in the built app

PLB=/usr/libexec/PlistBuddy

EXISTING_COMMIT=`$PLB -c "Print :ECVersionCommit" "$PLIST" 2> /dev/null`
if [[ "$EXISTING_COMMIT" == "$COMMIT" ]]
then
    echo "Commit is unchanged - no need to bump build number."
    exit 0
fi

if [[ "$EXISTING_COMMIT" == "" ]]
then
    $PLB -c "Add :ECVersionCommit string $COMMIT" "$PLIST"
else
    $PLB -c "Set :ECVersionCommit $COMMIT" "$PLIST"
fi
$PLB -c "Set :CFBundleVersion $VERSION" "$PLIST"

# set any other keys that have been passed in
while [[ ("$3" != "") && ("$4" != "") ]]
do
  echo "$3 $4"
  $PLB -c "Set $3 $4" "$PLIST"
  shift
  shift
done

if [[ "$SHORT_VERSION" != "" ]]
then
    $PLB -c "Set :CFBundleShortVersionString $SHORT_VERSION" "$PLIST"
fi

echo "Bumped build number to $VERSION ($COMMIT) in $PLIST"

DSYM_PLIST="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"

echo "*${DSYM_PLIST}*"

if [[ -e "${DSYM_PLIST}" ]] ; then

    # update the plist in the dSYM file too so that the build numbers match
    $PLB -c "Add :ECVersionCommit string commit" "$DSYM_PLIST" >& /dev/null
    $PLB -c "Set :ECVersionCommit $COMMIT" "$DSYM_PLIST"
    $PLB -c "Set :CFBundleVersion $VERSION" "$DSYM_PLIST"
    if [[ "$SHORT_VERSION" != "" ]]
    then
        $PLB -c "Set :CFBundleShortVersionString $SHORT_VERSION" "$DSYM_PLIST"
    fi

    echo "Also updated dSYM build number"

fi



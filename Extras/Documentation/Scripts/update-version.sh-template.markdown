 Script which takes the line count of the git log and sets it as the CFBundleVersion number in the target's Info.plist

 To use this script, add a Run Script phase to a target, and include this line
     "${ECLOGGING_SCRIPTS_PATH}/update-version.sh"


### update-version.sh:
    #!/bin/bash
    
    ## Script which takes the line count of the git log and sets it as the CFBundleVersion number in the target's Info.plist
    ##
    ## To use this script, add a Run Script phase to a target, and include this line
    ##     "${ECLOGGING_SCRIPTS_PATH}/update-version.sh"
    ##
    
    PLIST="$1"
    if [ "$PLIST" == "" ]; then
        PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
    fi
    
    VERSION=`git log --oneline | wc -l`
    
    # update the plist in the built app
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$PLIST"
    
    echo "Bumped build number to $VERSION in $PLIST"

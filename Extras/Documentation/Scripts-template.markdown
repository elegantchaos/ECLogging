Scripts
-------

ECLogging contains a number of scripts used by ECLogging itself or by other EC Frameworks.

Some of these aren't really intended for public use, but they're all documented here just in case.
## backup-submodules.sh:
 Pushes all branches of all submodules in the current project to a remote called "backup".

 Used internally.


    #!/usr/bin/env bash
    
    ## Pushes all branches of all submodules in the current project to a remote called "backup".
    ##
    ## Used internally.
    
    git submodule foreach 'git push backup --all'
## extract-script-docs.sh:
 Extract any comments prefixed with "" (like this one) in a file, and write them out to
 a -template.md for inclusion in an appledoc documentation bundle.


    #!/usr/bin/env bash
    
    ## Extract any comments prefixed with "##" (like this one) in a file, and write them out to
    ## a -template.md for inclusion in an appledoc documentation bundle.
    
    output=$1
    mkdir -p "$output"
    echo "Output directory: $output"
    
    shift
    prefix=$1
    echo "Prefix file: $prefix"
    
    index=`cat "$prefix"`
    
    while :; do
    	shift
    	file=$1
    	if [[ "$file" == "" ]]; then
    		break
    	fi
    	
     
    	comments=`grep "^##" "$file"`
    
    	base=`basename "$file"`
    	name=${base%.*}
    
    	index=`echo "$index"; echo "## $base:"; echo "${comments//##/}"; echo ""; echo ""; awk '{print "    "$0}' $file; echo ""`
    #    echo "" >> "$output/$base-template.markdown"
    #	awk '{print "    "$0}' $file >> "$output/$base-template.markdown"
    #    echo "${comments//##/}" >> "$output/$base-template.markdown"
    #    echo "" >> "$output/$base-template.markdown"
    #    echo "" >> "$output/$base-template.markdown"
    #	index=`echo "$index"; echo "- [$base]($base.html)"`
    #    index=`echo "$index"; cat "$output/$base-template.markdown"`
    done
    
    echo "$index" > "$output/Scripts-template.markdown"
## merge-latest-submodules.sh:
 Runs the merge-latest.sh script for each submodule in the current project.

 Used internally.


    #!/usr/bin/env bash
    
    ## Runs the merge-latest.sh script for each submodule in the current project.
    ##
    ## Used internally.
    
    base=`dirname $0`
    pushd "$base" > /dev/null
    full="$PWD"
    popd > /dev/null
    
    git submodule foreach "\"$full\"/merge-latest.sh"
## merge-latest.sh:
 This script is an attempt to automate picking up the latest version of the "develop" branch for a module, given that it might be on a detatch HEAD at the time.

 It performs the following steps:

 - rebase on the local develop branch
 - save this to a temporary branch
 - switch to the local develop branch
 - merge in the temporary branch - this should be a fast forward
 - remove the temporary branch
 - rebase on the remote "develop" from origin
 - push the resulting changed branch back to origin


    #!/usr/bin/env bash
    
    ## This script is an attempt to automate picking up the latest version of the "develop" branch for a module, given that it might be on a detatch HEAD at the time.
    ##
    ## It performs the following steps:
    ##
    ## - rebase on the local develop branch
    ## - save this to a temporary branch
    ## - switch to the local develop branch
    ## - merge in the temporary branch - this should be a fast forward
    ## - remove the temporary branch
    ## - rebase on the remote "develop" from origin
    ## - push the resulting changed branch back to origin
    
    check() {
        if [[ $1 != 0 ]]; then
          echo "failed: $2"
          exit $1
        fi
    }
    
    status=`git status --porcelain`
    
    if [[ "$status" != "" ]]; then
        echo "You have local changes. Commit them first."
        exit 1
    fi
    
    # we may start on something that isn't the develop branch
    # possibly a detached HEAD
    
    # try to apply any changes on top of our local develop
    
    git rebase develop
    check $? "rebasing on develop"
    
    # now fast forward develop to the merged place
    
    git checkout -b develop-temp
    check $? "making temp branch"
    
    git checkout develop
    check $? "switching back to develop"
    
    git merge develop-temp
    check $? "merging local changes"
    
    git branch -d develop-temp
    check $? "removing temp branch"
    
    # we should now be on a local develop branch incorporating any local changes
    echo fetching latest revisions
    git fetch
    
    # try to rebase again on top of any remote changes
    
    git rebase
    check $? "rebasing on origin/develop"
    
    # if that worked, push back the merged version
    
    git push
    check $? "pushing"
    
    
## package-pseudo-framework.sh:
 This script is used in iOS targets that are packaged up as "pseudo" frameworks.

 The script is called from a Run Script phase, like this:

 "${ECLOGGING_SCRIPTS_PATH}/package-pseudo-framework.sh"

 It performs various linking and copying operations to lay out the framework bundle correctly.


    #!/usr/bin/env bash
    
    ## This script is used in iOS targets that are packaged up as "pseudo" frameworks.
    ##
    ## The script is called from a Run Script phase, like this:
    ##
    ## "${ECLOGGING_SCRIPTS_PATH}/package-pseudo-framework.sh"
    ##
    ## It performs various linking and copying operations to lay out the framework bundle correctly.
    
    FRAMEWORK_ROOT="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"
    
    mkdir -p "${FRAMEWORK_ROOT}/Versions"
    /bin/ln -sfh A "${FRAMEWORK_ROOT}/Versions/Current"
    /bin/ln -sfh Versions/Current/Headers "${FRAMEWORK_ROOT}/Headers"
    /bin/ln -sfh Versions/Current/Resources "${FRAMEWORK_ROOT}/Resources"
    /bin/ln -sfh "Versions/Current/${PRODUCT_NAME}" "${FRAMEWORK_ROOT}/${PRODUCT_NAME}"
## pull-latest-submodules.sh:
 Runs the merge-latest.sh script for each submodule in the current project.

 Used internally.


    #!/usr/bin/env bash
    
    ## Runs the merge-latest.sh script for each submodule in the current project.
    ##
    ## Used internally.
    
    base=`dirname $0`
    pushd "$base" > /dev/null
    full="$PWD"
    popd > /dev/null
    
    git submodule foreach "git pull --ff-only"
## sign-bundled.sh:
 Re-sign every plugin and framework using the bundle id and code signing identity of the target

 You can use this script in a Run Script phase to ensure that all plugins and frameworks are signed consistently.


    BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" ${INFOPLIST_FILE}`
    
    ## Re-sign every plugin and framework using the bundle id and code signing identity of the target
    ##
    ## You can use this script in a Run Script phase to ensure that all plugins and frameworks are signed consistently.
    
    echo "Signing PlugIns"
    for f in "${CODESIGNING_FOLDER_PATH}/Contents/PlugIns/"*
    do
        BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$f/Contents/Info.plist"`
        codesign -f -i ${BUNDLEID} -vv -s "${CODE_SIGN_IDENTITY}" "$f"
    done
    
    echo "Signing Frameworks"
    for f in "${CODESIGNING_FOLDER_PATH}/Contents/Frameworks/"*
    do
        BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$f/Resources/Info.plist"`
        codesign -f -i ${BUNDLEID} -vv -s "${CODE_SIGN_IDENTITY}" "$f"
    done
## test-common.sh:



    #!/usr/bin/env bash
    
    # Common code for test scripts
    
    if [[ $project == "" ]];
    then
        echo "Need to define project variable."
        exit 1
    fi
    
    echo "Setting up tests for $project"
    
    pushd "$base/.." > /dev/null
    build="$PWD/test-build"
    ocunit2junit="$PWD/ECUnitTests/Resources/Scripts/ocunit2junit/ocunit2junit.rb"
    popd > /dev/null
    
    sym="$build/sym"
    obj="$build/obj"
    
    rm -rf "$build"
    mkdir -p "$build"
    
    testout="$build/out.log"
    testerr="$build/err.log"
    
    #if [[ "$testMac" == "" ]]; then
    #    testMac=true
    #fi
    
    #if [[ "$testIOS" == "" ]]; then
    #    testIOS=true
    #if
    
    config="Debug"
    
    report()
    {
    #    pushd "$build" > /dev/null
        "$ocunit2junit" < "$testout" > /dev/null
        reportdir="$build/reports/$2/$1"
        mkdir -p "$reportdir"
        mv test-reports/* "$reportdir" 2> /dev/null
        rmdir test-reports
    #    popd > /dev/null
    }
    
    commonbuild()
    {
        echo "Building $1 for $3"
        xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "$3" $4 -config "$config" $2 OBJROOT="$obj" SYMROOT="$sym" > "$testout" 2> "$testerr"
        result=$?
        if [[ $result != 0 ]]; then
            cat "$testerr"
            echo
            echo "** BUILD FAILURES **"
            echo "Build failed for scheme $1"
            exit $result
        fi
    
        report "$1" "$3"
    
        failures=`grep failed "$testout"`
        if [[ $failures != "" ]]; then
            echo $failures
            echo
            echo "** UNIT TEST FAILURES **"
            echo "Tests failed for scheme $1"
            exit $result
        fi
    
    }
    
    macbuild()
    {
        if $testMac ; then
    
            commonbuild "$1" "$2" "macosx"
    
        fi
    }
    
    iosbuild()
    {
        if $testIOS; then
    
            if [[ $2 == "test" ]];
            then
                action="build TEST_AFTER_BUILD=YES"
            else
                action=$2
            fi
    
            commonbuild "$1" "$action" "iphonesimulator" "-arch i386"
    
        fi
    }
    
    iosbuildproject()
    {
    
        if $testIOS; then
    
            echo Building target $2 of project $1
    
            cd "$1"
            xcodebuild -project "$1.xcodeproj" -config "$config" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" > "$testout" 2> "$testerr"
            result=$?
            cd ..
            if [[ $result != 0 ]]; then
                cat "$testerr"
                echo
                echo "** BUILD FAILURES **"
                echo "Build failed for scheme $1"
            exit $result
            fi
    
        fi
    
    }
    
    iostestproject()
    {
    
        if $testIOS; then
    
            echo Testing target $2 of project $1
    
            cd "$1"
            xcodebuild -project "$1.xcodeproj" -config "$config" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" TEST_AFTER_BUILD=YES > "$testout" 2> "$testerr"
            result=$?
            cd ..
            if [[ $result != 0 ]]; then
                cat "$testerr"
                echo
                echo "** BUILD FAILURES **"
                echo "Build failed for scheme $1"
                exit $result
            fi
    
            report "$1" "iphonesimulator"
    
        fi
    
    }
## testflight-extract-url.py:
 Python script to extract the URL from the json results returned by TestFlight


    #!/usr/bin/env python
    
    ## Python script to extract the URL from the json results returned by TestFlight
    
    import json
    import sys
    
    result = json.load(sys.stdin)
    url = result['config_url']
    
    print url
## testflight-upload.sh:
 Script which uploads the target to Testflight.
 Use this script as a Post-Action script in the Archive phase of a Scheme.

 The API token to use is read from the defaults system. To set it use
     defaults write com.elegantchaos.testflight-upload API_TOKEN <token>

 The Team Token is passed in to the script as a first parameter, since it varies with each project.
 The second parameter should be the name of a TestFlight distribution list. All users in the list will be notified
 when the target has been uploaded.


    #!/bin/bash
    
    ## Script which uploads the target to Testflight.
    ## Use this script as a Post-Action script in the Archive phase of a Scheme.
    ##
    ## The API token to use is read from the defaults system. To set it use
    ##     defaults write com.elegantchaos.testflight-upload API_TOKEN <token>
    ##
    ## The Team Token is passed in to the script as a first parameter, since it varies with each project.
    ## The second parameter should be the name of a TestFlight distribution list. All users in the list will be notified
    ## when the target has been uploaded.
    
    rm /tmp/upload.log
    
    TMP=/tmp/testflight-upload
    LOG="${TMP}/upload.log"
    ERROR_LOG="${TMP}/error.log"
    
    rm "${LLOG}"
    rm "${ERROR_LOG}"
    
    mkdir -p "$TMP"
    echo "Uploading..." > "${LOG}"
    echo "" > "${ERROR_LOG}"
    
    GIT=/usr/bin/git
    
    APITOKEN=`defaults read com.elegantchaos.testflight-upload API_TOKEN`
    if [[ "${APITOKEN}" == "" ]]; then
        echo "Need to set the TestFlight API token using 'defaults write com.elegantchaos.testflight-upload API_TOKEN <token>'" >> "${ERROR_LOG}"
        open "${ERROR_LOG}"
        exit 1
    fi
    
    
    # team token and distribution list are per-project settings, so should be passed in
    TEAMTOKEN="$1"
    DISTRIBUTION="$2"
    
    # set this to true to show a confirmation dialog before doing the upload
    CONFIRM_MESSAGE=false
    
    # set this to true to use the git log as the default upload message
    DEFAULT_MESSAGE_IS_GIT_LOG=true
    
    MESSAGE=""
    
    if $DEFAULT_MESSAGE_IS_GIT_LOG; then
        # use the git log since the last upload as the upload message
        MESSAGE=`cd "$PROJECT_DIR"; $GIT log --oneline testflight-upload..HEAD`
        if [[ $? != 0 ]]; then
            MESSAGE="first upload"
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
    
    SCRIPT_DIR=`dirname $0`
    
    # make the ipa
    echo "Making $EXECUTABLE_NAME.ipa as ${CODE_SIGN_IDENTITY}" >> "${LOG}"
    APP="$ARCHIVE_PRODUCTS_PATH/Applications/$EXECUTABLE_NAME.app"
    DSYM="$ARCHIVE_DSYMS_PATH/$EXECUTABLE_NAME.app.dSYM"
    IPA="$TMPDIR/$EXECUTABLE_NAME.ipa"
    XCROOT=`/usr/bin/xcode-select -print-path`
    XCRUN="$XCROOT/usr/bin/xcrun"
    
    echo "$XCRUN" -sdk iphoneos PackageApplication "$APP" -o "$IPA" --sign "${CODE_SIGN_IDENTITY}" --embed "${APP}/${EMBEDDED_PROFILE_NAME}" &> "${TMP}/xcrun.txt"
    
    "$XCRUN" -sdk iphoneos PackageApplication "$APP" -o "$IPA" --sign "${CODE_SIGN_IDENTITY}" --embed "${APP}/${EMBEDDED_PROFILE_NAME}" &> "${TMP}/xcrun.log"
    
    if [[ $? == 0 ]] ; then
    
            CURLLOG="${TMP}/curl.log"
    
            echo "Uploading to Test Flight with notes:" >> "${LOG}"
            echo "\"${MESSAGE}\"" >> "${LOG}"
            echo "" >> "${LOG}"
            echo "Distribution list ${DISTRIBUTION} will be mailed." >> "${LOG}"
            echo "" >> "${LOG}"
    
            zip -q -r "${DSYM}.zip" "${DSYM}"
            rm "$CURLLOG"
            curl http://testflightapp.com/api/builds.json --form file="@${IPA}" --form dsym="@${DSYM}.zip" --form api_token="${APITOKEN}" --form team_token="${TEAMTOKEN}" --form notes="${MESSAGE}" --form notify=True --form distribution_lists="${DISTRIBUTION}" -o "${CURLLOG}"
            CONFIG_URL=`"${SCRIPT_DIR}/testflight-extract-url.py" < "${CURLLOG}"`
    
            if [[ $? == 0 ]] ; then
                echo "Upload done." >> "${LOG}"
                open "${CONFIG_URL}"
    
                # update the git tag
                cd "$PROJECT_DIR";
                $GIT tag -f testflight-upload
    
                # clean up if the upload worked
                rm "${DSYM}.zip"
                rm "${IPA}"
    
            else
                echo "Test Flight returned error:" > "${ERROR_LOG}"
                cat "${CURLLOG}" >> "${ERROR_LOG}"
                open "${ERROR_LOG}"
    
            fi
    else
    
        echo "Failed to build IPA"  >> "${ERROR_LOG}"
        open "${TMP}/xcrun.log"
        exit 1
    fi
    
    
## update-version.sh:
 Script which takes the line count of the git log and sets it as the CFBundleVersion number in the target's Info.plist

 The script also adds a ECVersionCommit key to the Info.plist with the full SHA1 hash of the current commit.

 To use this script, add a Run Script phase to a target, and include this line
     "${ECLOGGING_SCRIPTS_PATH}/update-version.sh"



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

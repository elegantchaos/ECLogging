 Re-sign every plugin and framework using the bundle id and code signing identity of the target

 You can use this script in a Run Script phase to ensure that all plugins and frameworks are signed consistently.

### sign-bundled.sh:
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

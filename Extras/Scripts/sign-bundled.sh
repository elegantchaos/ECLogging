
sign()
{
    BUNDLEID="$1"
    CODE_SIGN_IDENTITY="$2"
    FILE="$3"

    # get current signing details
    CURRENT=`codesign --verbose=2 -d "${FILE}" 2>&1`

#   echo "current:$CURRENT"

    # get current id
    PATTERN="Identifier=([a-zA-Z0-9.]*)"
    [[ "$CURRENT" =~ $PATTERN ]]
    CURRENT_IDENTIFIER=${BASH_REMATCH[1]}

    # get first authority - should match the code signing identity that we're using
    PATTERN="Authority=([a-zA-Z0-9: ]*)"
    [[ "$CURRENT" =~ $PATTERN ]]
    CURRENT_AUTHORITY=${BASH_REMATCH[1]}

#    echo "current:$CURRENT_IDENTIFIER required:$BUNDLEID"
#    echo "current:$CURRENT_AUTHORITY required:$CODE_SIGN_IDENTITY"

    NAME=`basename "$FILE"`
    echo

    # check if we need to resign (resigning can be slow, so we check first)
    if [[ ("$CURRENT_IDENTIFIER" != "$BUNDLEID") || ("$CURRENT_AUTHORITY" != "$CODE_SIGN_IDENTITY"*) ]] ; then
        echo "Resigning $NAME with id $BUNDLEID"
        codesign -f -i ${BUNDLEID} -vv -s "${CODE_SIGN_IDENTITY}" "${FILE}"
    else
        echo "Didn't need to sign $NAME - already signed correctly"
    fi
}

## Re-sign every plugin and framework using the bundle id and code signing identity of the target
##
## You can use this script in a Run Script phase to ensure that all plugins and frameworks are signed consistently.

APPID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" ${INFOPLIST_FILE}`
echo "Resigning bundles items."
echo "App bundle is $APPID."

if [[ "$CODE_SIGN_IDENTITY" == "" ]] ; then
	echo "App not signed, using default identity."
	CODE_SIGN_IDENTITY="3rd Party Mac Developer Application"
fi

# According to the codesign tool, Mac Developer is ambiguous (also matches 3rd Party Mac Developer)
# Mac Developer: shouldn't be, so we change it if necessary.
if [[ "$CODE_SIGN_IDENTITY" == "Mac Developer" ]] ; then
	CODE_SIGN_IDENTITY="Mac Developer:"
fi

echo "Using identity $CODE_SIGN_IDENTITY"

if [ -e "${CODESIGNING_FOLDER_PATH}/Contents/PlugIns/" ]; then
	echo "Signing PlugIns as: ${CODE_SIGN_IDENTITY}"
	for f in "${CODESIGNING_FOLDER_PATH}/Contents/PlugIns/"*
	do
	    BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$f/Contents/Info.plist"`
		if [[ "$BUNDLEID" == "" ]]; then
			BUNDLEID="$APPID"
		fi
	    sign "${BUNDLEID}" "${CODE_SIGN_IDENTITY}" "$f"
	done
fi

if [ -e "${CODESIGNING_FOLDER_PATH}/Contents/Frameworks/" ]; then
	echo "Signing Frameworks as: ${CODE_SIGN_IDENTITY}"
	for f in "${CODESIGNING_FOLDER_PATH}/Contents/Frameworks/"*
	do
	    BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$f/Resources/Info.plist" 2> /dev/null`
		if [[ $? != 0 ]]; then
			BUNDLEID="$APPID"
		fi
        sign "${BUNDLEID}" "${CODE_SIGN_IDENTITY}" "$f"
	done
fi

echo ""
echo "Resigning done."
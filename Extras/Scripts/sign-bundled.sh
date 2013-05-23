
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

if [ -e "${CODESIGNING_FOLDER_PATH}/Contents/PlugIns/" ]; then
	echo "Signing PlugIns as: ${CODE_SIGN_IDENTITY}"
	for f in "${CODESIGNING_FOLDER_PATH}/Contents/PlugIns/"*
	do
	    BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$f/Contents/Info.plist"`
		if [[ "$BUNDLEID" == "" ]]; then
			BUNDLEID="$APPID"
		fi
		NAME=`basename "$f"`
		echo
		echo "Resigning $NAME with id $BUNDLEID"
	    codesign -f -i ${BUNDLEID} -vv -s "${CODE_SIGN_IDENTITY}" "$f"
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
		NAME=`basename "$f"`
		echo " "
		echo "Resigning $NAME with id $BUNDLEID"
	    codesign -f -i ${BUNDLEID} -vv -s "${CODE_SIGN_IDENTITY}" "$f" > /dev/null
	done
fi

echo ""
echo "Resigning done."
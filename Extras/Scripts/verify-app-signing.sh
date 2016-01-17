#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## Verifies codesigning for an app and all embedded frameworks and plugins.
## Takes the path to the app as the first parameter.

app="$1"

appname=`basename "$app"`
base=`dirname "$app"`

cd "$base"

echo "Assessment (spctl):"
echo "(rejected is the expected result for a Mac App Store build)"
echo "-------------------"
echo ""

spctl --verbose=8 --assess --type execute "$appname"

items=( "$appname" )

if [[ -e "$appname/Contents/Frameworks/" ]]; then
    for f in "$appname/Contents/Frameworks/"*; do items+=("$f"); done
fi

if [[ -e "$appname/Contents/PlugIns/" ]]; then
    for f in "$appname/Contents/PlugIns/"*; do items+=("$f"); done
fi

if [[ -e "$appname/Contents/Library/Quicklook/" ]]; then
    for f in "$appname/Contents/Library/Quicklook/"*; do items+=("$f"); done
fi


echo ""
echo "Signing:"
echo "--------"
echo ""

for f in "${items[@]}"
do
    echo "Checking $f"
    codesign --verbose=5 --deep --verify "$f"
    echo ""
done

echo ""
echo "Entitlements:"
echo "-------------"
echo ""

for f in "${items[@]}"
do
    echo "Entitlements for $f"
    codesign -vvv --display --entitlements :- "$f"
    echo ""
done

#codesign --display --entitlements :- "$app" $opts
#codesign -v "$app/Contents/Frameworks/"* $opts
#if [[ -e "$app/Contents/PlugIns/" ]]
#then
#codesign -v "$app/Contents/PlugIns/"* $opts
#fi


#codesign -dvvv --entitlements :- executable_path
#!/usr/bin/env bash

## Verifies codesigning for an app and all embedded frameworks and plugins.
## Takes the path to the app as the first parameter.

app="$1"

echo "spctl:"
spctl --verbose=8 --assess --type execute "$app"

local -a items=( "$app" )
echo $items
for f in "$app/Contents/Frameworks/"*; do items+=("$f"); done

if [[ -e "$app/Contents/PlugIns/" ]]; then
    for f in "$app/Contents/PlugIns/"*; do items+=("$f"); done
fi

if [[ -e "$app/Contents/Library/Quicklook/" ]]; then
    for f in "$app/Contents/Library/Quicklook/"*; do items+=("$f"); done
fi

echo ${items[@]}


echo ""
echo "Signing:"
echo "--------"
echo ""

for f in ${items[@]}
do
    echo "Checking $f"
    codesign --verbose=5 --deep --verify "$f"
    echo ""
done

echo "Entitlements:"
echo "-------------"
echo ""

for f in ${items[@]}
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
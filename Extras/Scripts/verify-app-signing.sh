#!/usr/bin/env bash

## Verifies codesigning for an app and all embedded frameworks and plugins.
## Takes the path to the app as the first parameter.

app="$1"
opts="--verbose --deep"

echo "spctl:"
spctl --verbose=8 --assess --type execute "$app"

echo "codesign:"
codesign -v "$app" $opts
codesign -v "$app/Contents/Frameworks/"* $opts
if [[ -e "$app/Contents/PlugIns/" ]]
then
    codesign -v "$app/Contents/PlugIns/"* $opts
fi
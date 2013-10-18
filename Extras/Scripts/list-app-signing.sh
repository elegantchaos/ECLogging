#!/usr/bin/env bash

## Verifies codesigning for an app and all embedded frameworks and plugins.
## Takes the path to the app as the first parameter.

app="$1"
opts="--deep --verbose=2"
codesign -d "$app" $opts
#codesign -d "$app/Contents/Frameworks/"* $opts
#codesign -d "$app/Contents/PlugIns/"* $opts
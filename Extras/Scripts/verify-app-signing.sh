#!/usr/bin/env bash

## Verifies codesigning for an app and all embedded frameworks and plugins.
## Takes the path to the app as the first parameter.

app="$1"
opts=""
codesign -v "$app" $opts
codesign -v "$app/Contents/Frameworks/"* $opts
codesign -v "$app/Contents/PlugIns/"* $opts
#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## Verifies codesigning for an app and all embedded frameworks and plugins.
## Takes the path to the app as the first parameter.

app="$1"
opts="--deep --verbose=2"
codesign -d "$app" $opts
#codesign -d "$app/Contents/Frameworks/"* $opts
#codesign -d "$app/Contents/PlugIns/"* $opts
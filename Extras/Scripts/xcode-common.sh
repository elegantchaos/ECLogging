#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

# Common code for scripts that use xcode

checkerror()
{
result="$1"
message="$2"
log="$3"

if [[ $result != 0 ]]; then
cat "$log"
echo
echo "ERROR: $message"
exit $result
fi
}

build()
{
workspace="$1"
scheme="$2"
sdk="$3"
actions="$4"
config="$5"
arch="$6"
dest="$7"
log="$8"
echo "Building $workspace for $sdk $config $arch"

#echo "Workspace:$workspace"
#echo "Scheme:$scheme"
#echo "SDK:$sdk"
#echo "Actions:$actions"
#echo "Config:$config"
#echo "Arch:$arch"
#echo "Build to:$dest"
#echo "Log to:$dest"

outlog="${log}/out.log"
errlog="${log}/error.log"

xcodebuild -workspace "$workspace" -scheme "$scheme" -sdk "$sdk" $actions -config "$config" -arch "$arch" OBJROOT="$dest/obj/" SYMROOT="$dest/sym" >> "$outlog" 2>> "$errlog"
checkerror $? "Build failed for scheme $scheme" "$errlog"

failures=`grep failed "$outlog"`
if [[ $failures != "" ]]; then
echo $failures
echo
echo "** UNIT TEST FAILURES **"
echo "Tests failed for scheme $scheme"
exit $result
fi

}

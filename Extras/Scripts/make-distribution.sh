#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

## Make a distributable version of ECLogging
##

echo "Making distribution"

base=`dirname $0`

pushd "$base" > /dev/null
full="$PWD"
cd ../..
root="$PWD"
popd > /dev/null

dist="$root/Distribution"
build="$dist/build"

sym="$build/sym"
obj="$build/obj"

source "$base/xcode-common.sh"

rm -rf "$dist"
mkdir -p "$build"

buildios () {
    config="$1"
    build "ECLogging.xcworkspace" "ECLogging iOS" "iphoneos" "build" "$config" "armv7" "$build" "$build"
    build "ECLogging.xcworkspace" "ECLogging iOS" "iphoneos" "build" "$config" "armv7s" "$build/armv7s" "$build"
    build "ECLogging.xcworkspace" "ECLogging iOS" "iphonesimulator" "build" "$config" "i386" "$build" "$build"

    mkdir -p "$dist/iOS/$config"
    cp -Rf "$build/sym/$config-iphoneos/ECLogging.bundle" "$dist/iOS/$config"
    cp -Rf "$build/sym/$config-iphoneos/ECLogging.framework" "$dist/iOS/$config"

    armv7="$build/sym/$config-iphoneos/ECLogging.framework/Versions/A/ECLogging"
    armv7s="$build/armv7s/sym/$config-iphoneos/ECLogging.framework/Versions/A/ECLogging"
    sim="$build/sym/$config-iphonesimulator/ECLogging.framework/Versions/A/ECLogging"
    fat="$dist/iOS/$config/ECLogging.framework/Versions/A/ECLogging"

    outlog="${build}/out.log"
    errlog="${build}/error.log"

    lipo -create -output "$fat" "$armv7" "$armv7s" "$sim" >> "$outlog" 2>> "$errlog"
    checkerror $? "lipo failed" "$errlog"

}

buildmac () {
    config="$1"
    build "ECLogging.xcworkspace" "ECLogging Mac" "macosx" "build" "$config" "x86_64" "$build" "$build"

    mkdir -p "$dist/Mac/$config"
    cp -Rf "$build/sym/$config/ECLogging.framework" "$dist/Mac/$config"

}

cd "$root"

cp -Rf "$root/Source/Configuration" "$dist"
cp -Rf "$root/Extras/Scripts" "$dist"

buildios "Debug"
buildios "Release"

buildmac "Debug"
buildmac "Release"


rm -rf "$build"

open "$dist"

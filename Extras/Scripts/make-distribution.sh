#!/usr/bin/env bash

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
    build "ECLogging.xcworkspace" "ECLogging iOS" "iphoneos" "build" "$config" "armv7 armv7s i386" "$build" "$build"

    mkdir -p "$dist/iOS/$config"
    cp -Rf "$build/sym/$config-iphoneos/ECLogging.bundle" "$dist/iOS/$config"
    cp -Rf "$build/sym/$config-iphoneos/ECLogging.framework" "$dist/iOS/$config"

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

buildmac "Debug"
buildmac "Release"

buildios "Debug"
buildios "Release"

rm -rf "$build"

open "$dist"

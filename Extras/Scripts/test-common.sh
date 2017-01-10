#!/usr/bin/env bash

# --------------------------------------------------------------------------
#  Copyright 2013-2016 Sam Deane, Elegant Chaos. All rights reserved.
#  This source code is distributed under the terms of Elegant Chaos's
#  liberal license: http://www.elegantchaos.com/license/liberal
# --------------------------------------------------------------------------

# Common code for test scripts
if [[ $project == "" ]];
then
    echo "Need to define project variable."
    exit 1
fi

if [[ $ecbase == "" ]];
then
echo "Need to set ecbase variable - assuming it's at $base/.. (which is probably wrong)."
ecbase="$base/.."
fi

echo "Preparing to build $project"

build="$PWD/test-build"

pushd "$ecbase" > /dev/null
wd=`pwd`
popd > /dev/null

derived="$build/derived"
archive="$build/archive"

rm -rfd "$build" 2> /dev/null
mkdir -p "$build"

config="Debug"

urlencode()
{
    encoded="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$1")"
}

cleanbuild()
{
    # ensure a clean build every time
    rm -rfd "~/Library/Developer/Xcode/DerivedData"
    rm -rfd "$derived" 2> /dev/null
    rm -rfd "$archive" 2> /dev/null
}

cleanoutput()
{
    logdir="$build/logs/$2-$1"
    mkdir -p "$logdir"
    testout="$logdir/out.log"
    testjson="$logdir/out.json"
    testerr="$logdir/err.log"
    stamplog="$logdir/timestamps.log"
    statusfile="$build/status.txt"
}

setup()
{
    local TOOL="$1"
    shift

    local SCHEME="$1"
    shift

    local PLATFORM="$1"
    shift

    ARCHIVE_PATH=""
    if [[ "$1" == "archive" ]]
    then
      echo "Archiving"
      shift
      ACTIONS="archive -archivePath $archive $@"
    else
      ACTIONS="$@"
    fi

    echo "Building $SCHEME for $PLATFORM with $TOOL"
    echo "Actions: $ACTIONS"
    cleanoutput "$SCHEME" "$PLATFORM"
}

commonbuild()
{
    local PLATFORM="$1"
    shift

    local SCHEME="$1"
    shift

    setup "xctool" "$SCHEME" "$PLATFORM" "$@"

    echo "BUILDING" > "$statusfile"
    echo "Started $(date)" > "$stamplog"

    reportdir="$build/reports/$PLATFORM-$SCHEME"
    mkdir -p "$reportdir"


    xctool -workspace "$project.xcworkspace" -scheme "$SCHEME" -sdk "$PLATFORM" -derivedDataPath "$derived" $ACTIONS -reporter "junit:$reportdir/report.xml" -reporter "json-compilation-database:$testjson" -reporter "plain:$testout" 2>> "$testerr"
    result=$?

    echo "Finished $(date)" >> "$stamplog"

    if [[ $result != 0 ]]
    then
        echo "Build Failed:"
        cat "$testerr" >&2
        tail -n 20 "$testout"
        echo
        echo $'\n** BUILD FAILURES **\n'
        echo "Build failed for scheme $SCHEME (xctool returned $result)"
        LOG_PATH="test-build/logs/$PLATFORM-$SCHEME"
        if [[ "$JOB_URL" != "" ]]
        then
            LOG_URL="${JOB_URL}/${LOG_PATH}"
            urlencode "${LOG_URL}"
        else
            LOG_URL="$LOG_PATH"
        fi
        echo "Full log: $LOG_URL"
        echo "FAILED-BUILD" > "$statusfile"

        exit $result
    fi

    # grep the build output for warnings that didn't cause it to fail
    # these are likely to be analyser warnings
    buildWarnings=`grep --only-matching -E "\w+.m:\d+:\d+: warning:.*" "$testout"`
    if [[ $buildWarnings != "" ]]
    then
        echo "** ANALYSER WARNINGS **"
        echo "Found analyser warnings in log:"
        echo "$buildWarnings"
        echo
        echo "Analyser failed for scheme $SCHEME"
        echo "FAILED-ANALYSER" > "$statusfile"
        exit 1
    fi

    echo "BUILT" > "$statusfile"
}

macbuild()
{
    if $testMac ; then
        if [[ $1 != "--dontclean" ]]
        then
            cleanbuild
        else
            echo "Suppressing cleaning - will reuse the same build products"
            shift
        fi

        commonbuild "macosx" "$@"
    fi
}

iosbuild()
{
    if $testIOS; then

        local SCHEME=$1
        shift

        local ACTIONS=$1
        shift

        cleanbuild
        commonbuild "iphonesimulator" "$SCHEME" "$ACTIONS" -arch i386 ONLY_ACTIVE_ARCH=NO "$@"
    fi
}

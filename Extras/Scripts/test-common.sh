#!/usr/bin/env bash

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
ocunit2junit="$wd/ocunit2junit/bin/ocunit2junit"
popd > /dev/null

derived="$build/derived"

rm -rfd "$build" 2> /dev/null
mkdir -p "$build"

config="Debug"

urlencode()
{
    encoded="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$1")"
}

report()
{
    pushd "$build" > /dev/null 2>> "$testerr"
    "$ocunit2junit" < "$testout" > /dev/null 2>> "$testerr"
    reportdir="$build/reports/$2-$1"
    mkdir -p "$reportdir"
    mv test-reports/* "$reportdir" 2>> "$testerr"
    rmdir test-reports 2>> "$testerr"
    popd > /dev/null 2>> "$testerr"
}

cleanbuild()
{
    # ensure a clean build every time
    rm -rfd "~/Library/Developer/Xcode/DerivedData"
    rm -rfd "$derived" 2> /dev/null
}

cleanoutput()
{
    logdir="$build/logs/$2-$1"
    mkdir -p "$logdir"
    testout="$logdir/out.log"
    testpretty="$logdir/pretty.log"
    testerr="$logdir/err.log"

    # make empty output files
    echo "" > "$testout"
    echo "" > "$testpretty"
    echo "" > "$testerr"
}

setup()
{
    local TOOL="$1"
    shift

    local SCHEME="$1"
    shift

    local PLATFORM="$1"
    shift

    echo "Building $SCHEME for $PLATFORM with $TOOL"
    echo "Actions: $@"
    cleanoutput "$SCHEME" "$PLATFORM"
}

commonbuild()
{
    local PLATFORM="$1"
    shift

    local SCHEME="$1"
    shift

    setup "xctool" "$SCHEME" "$PLATFORM" "$@"

    reportdir="$build/reports/$PLATFORM-$SCHEME"
    mkdir -p "$reportdir"

    xctool -workspace "$project.xcworkspace" -scheme "$SCHEME" -sdk "$PLATFORM" "$@" -derivedDataPath "$derived" -reporter "junit:$reportdir/report.xml" -reporter "pretty:$testpretty" -reporter "plain:$testout" 2>> "$testerr"
    result=$?

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
        exit 1
    fi

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
        if ! $use_xctool
        then
          if [[ $ACTIONS == "test" ]];
          then
              ACTIONS="build TEST_AFTER_BUILD=YES"
          fi
        fi
        cleanbuild
        commonbuild "iphonesimulator" "$SCHEME" "$ACTIONS" -arch i386 ONLY_ACTIVE_ARCH=NO "$@"
    fi
}

iosbuildproject()
{

    if $testIOS; then

        cleanbuild
        cleanoutput "$1" "$2"

        cd "$1"
        echo Building debug target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Debug" -target "$2" -arch i386 -sdk "iphonesimulator" build -derivedDataPath "$derived" >> "$testout" 2>> "$testerr"
        echo Building release target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Release" -target "$2" -arch i386 -sdk "iphonesimulator" build -derivedDataPath "$derived" >> "$testout" 2>> "$testerr"
        result=$?
        cd ..
        if [[ $result != 0 ]]; then
            cat "$testerr"
            echo
            echo "** BUILD FAILURES **"
            echo "Build failed for scheme $1"
        exit $result
        fi

    fi

}

iostestproject()
{

    if $testIOS; then

        cleanoutput "$1" "$2"
        cleanbuild

        cd "$1"
        echo Testing debug target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Debug" -target "$2" -arch i386 -sdk "iphonesimulator" build -derivedDataPath "$derived" TEST_AFTER_BUILD=YES >> "$testout" 2>> "$testerr"
        echo Testing release target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Release" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" -derivedDataPath "$derived" TEST_AFTER_BUILD=YES >> "$testout" 2>> "$testerr"
        result=$?
        cd ..
        if [[ $result != 0 ]]; then
            cat "$testerr"
            echo
            echo "** BUILD FAILURES **"
            echo "Build failed for scheme $1"
            exit $result
        fi

        report "$1" "iphonesimulator"

    fi

}

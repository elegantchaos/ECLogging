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

echo "Setting up tests for $project"

build="$PWD/test-build"

pushd "$ecbase" > /dev/null
wd=`pwd`
ocunit2junit="$wd/ocunit2junit/bin/ocunit2junit"
popd > /dev/null

sym="$build/sym"
obj="$build/obj"
precomp="$build/precomp"

rm -rf "$build"
mkdir -p "$build"

config="Debug"

report()
{
    pushd "$build" > /dev/null
    "$ocunit2junit" < "$testout" > /dev/null 2>&1
    reportdir="$build/reports/$2-$1"
    mkdir -p "$reportdir"
    mv test-reports/* "$reportdir" 2> /dev/null
    rmdir test-reports
    popd > /dev/null
}

cleanbuild()
{
    # ensure a clean build every time
    rm -rf "$obj"
    rm -rf "$sym"
    rm -rf "$precomp"
}

cleanoutput()
{
    logdir="$build/logs/$2-$1"
    mkdir -p "$logdir"
    testout="$logdir/out.log"
    testerr="$logdir/err.log"

    # make empty output files
    echo "" > "$testout"
    echo "" > "$testerr"
}

commonbuild()
{
    echo "Building $1 for $3 $2"
    cleanoutput "$1" "$3"

    # build it
    xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "$3" $4 $2 OBJROOT="$obj" SYMROOT="$sym" SHARED_PRECOMPS_DIR="$precomp" >> "$testout" 2>> "$testerr"

    # we don't entirely trust the return code from xcodebuild, so we also scan the output for "failed"
    result=$?
    buildfailures=`grep failed "$testerr"`
    if [[ $result != 0 ]] || [[ $buildfailures != "" ]]; then
        # if it looks like the build failed, output everything to stdout
        echo "Build Failed"
        #cat "$testout"
        cat "$testerr" >&2
        echo
        echo "** BUILD FAILURES **"
        if [[ $result != 0 ]]; then
          echo "xcodebuild returned $result"
        fi

        if [[ $buildfailures != "" ]]; then
          echo "Found failure in log:$buildfailures"
        fi
        echo "Build failed for scheme $1"
        echo "Full log: $JOB_URL/ws/test-build/logs/$1-$3"
        if [[ $result == 0 ]]; then
            result=1
        fi
        exit $result
    fi

    report "$1" "$3"

    testfailures=`grep failed "$testout"`
    if [[ $testfailures != "" ]] && [[ $testfailures != "error: failed to launch"* ]]; then
        echo "** UNIT TEST FAILURES **"
        echo "Found failure in log:$testfailures"
        echo
        echo "Tests failed for scheme $1"
        exit 1
    fi

}

macbuild()
{
    if $testMac ; then

        cleanbuild
        commonbuild "$1" "$2" "macosx" ""

    fi
}

iosbuild()
{
    if $testIOS; then

        if [[ $2 == "test" ]];
        then
            action="build TEST_AFTER_BUILD=YES"
        else
            action=$2
        fi

        cleanbuild
        commonbuild "$1" "$action" "iphonesimulator" "-arch i386 ONLY_ACTIVE_ARCH=NO"

    fi
}

iosbuildproject()
{

    if $testIOS; then

        cleanbuild
        cleanoutput "$1" "$2"

        cd "$1"
        echo Building debug target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Debug" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" SHARED_PRECOMPS_DIR="$precomp" >> "$testout" 2>> "$testerr"
        echo Building release target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Release" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" SHARED_PRECOMPS_DIR="$precomp" >> "$testout" 2>> "$testerr"
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
        xcodebuild -project "$1.xcodeproj" -config "Debug" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" SHARED_PRECOMPS_DIR="$precomp" TEST_AFTER_BUILD=YES >> "$testout" 2>> "$testerr"
        echo Testing release target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Release" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" SHARED_PRECOMPS_DIR="$precomp" TEST_AFTER_BUILD=YES >> "$testout" 2>> "$testerr"
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
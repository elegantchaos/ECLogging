#!/usr/bin/env bash

# Common code for test scripts

if [[ `which xctool` == "" ]]
then
  use_xctool=false
else
  use_xctool=true
fi

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
dst="$build/dst"
precomp="$build/precomp"

rm -rf "$build"
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
    rm -rf "$obj"
    rm -rf "$dst"
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

commonbuildxctool()
{
  echo "Building $1 for $3 $2 with xctool"
  cleanoutput "$1" "$3"

  reportdir="$build/reports/$3-$1"
  mkdir -p "$reportdir"

    xctool -workspace "$project.xcworkspace" -scheme "$1" -sdk "$3" $4 $2 OBJROOT="$obj" SYMROOT="$sym" DSTROOT="$dst" SHARED_PRECOMPS_DIR="$precomp" -reporter "junit:$reportdir/report.xml" -reporter "pretty:$testout" 2>> "$testerr"
    result=$?


    if [[ $result != 0 ]]
    then
        echo "Build Failed"
        #cat "$testout"
        cat "$testerr" >&2
        tail "$testout"
        echo
        echo "** BUILD FAILURES **"
        echo "xxctool returned $result"

        echo "Build failed for scheme $1"
        urlencode "${JOB_URL}ws/test-build/logs/$1-$3"
        echo "Full log: $encoded"

        exit $result
    fi

}

commonbuildxcbuild()
{
    echo "Building $1 for $3 $2 with xcodebuild"
    cleanoutput "$1" "$3"

    # build it
    xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "$3" $4 $2 OBJROOT="$obj" SYMROOT="$sym" DSTROOT="$dst" SHARED_PRECOMPS_DIR="$precomp" >> "$testout" 2>> "$testerr"

    result=$?

    report "$1" "$3"

    # we don't entirely trust the return code from xcodebuild, so we also scan the output for "failed"
    buildfailures=`grep failed "$testerr"`
    if ([[ $result != 0 ]] && [[ $result != 65 ]]) || [[ $buildfailures != "" ]]; then
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
          echo "Found failure in log: $buildfailures"
        fi
        echo "Build failed for scheme $1"
        urlencode "${JOB_URL}ws/test-build/logs/$1-$3"
        echo "Full log: $encoded"
        if [[ $result == 0 ]]; then
            result=1
        fi
        exit $result
    fi


    testfailures=`grep failed "$testout"`
    if [[ $testfailures != "" ]] && [[ $testfailures != "error: failed to launch"* ]]; then
        echo "** UNIT TEST FAILURES **"
        echo "Found failure in log:$testfailures"
        echo
        echo "Tests failed for scheme $1"
        exit 1
    fi

}

commonbuild()
{
  if $use_xctool
  then
    commonbuildxctool "$1" "$2" "$3" "$4" "$5"
  else
    commonbuildxcbuild "$1" "$2" "$3" "$4" "$5"
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

        if ! $use_xctool
        then
          if [[ $2 == "test" ]];
          then
              action="build TEST_AFTER_BUILD=YES"
          else
              action=$2
          fi
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
        xcodebuild -project "$1.xcodeproj" -config "Debug" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" DSTROOT="$dst" SHARED_PRECOMPS_DIR="$precomp" >> "$testout" 2>> "$testerr"
        echo Building release target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Release" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" DSTROOT="$dst" SHARED_PRECOMPS_DIR="$precomp" >> "$testout" 2>> "$testerr"
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
        xcodebuild -project "$1.xcodeproj" -config "Debug" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" DSTROOT="$dst" SHARED_PRECOMPS_DIR="$precomp" TEST_AFTER_BUILD=YES >> "$testout" 2>> "$testerr"
        echo Testing release target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Release" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" DSTROOT="$dst" SHARED_PRECOMPS_DIR="$precomp" TEST_AFTER_BUILD=YES >> "$testout" 2>> "$testerr"
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
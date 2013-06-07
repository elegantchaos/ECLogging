#!/usr/bin/env bash

# Common code for test scripts

if [[ $project == "" ]];
then
    echo "Need to define project variable."
    exit 1
fi

echo "Setting up tests for $project"

pushd "$base/.." > /dev/null
build="$PWD/test-build"
ocunit2junit="$PWD/ECLogging/Extras/Scripts/ocunit2junit/bin/ocunit2junit"
popd > /dev/null

sym="$build/sym"
obj="$build/obj"

rm -rf "$build"
mkdir -p "$build"

testout="$build/out.log"
testerr="$build/err.log"

#if [[ "$testMac" == "" ]]; then
#    testMac=true
#fi

#if [[ "$testIOS" == "" ]]; then
#    testIOS=true
#if

config="Debug"

report()
{
#    pushd "$build" > /dev/null
    "$ocunit2junit" < "$testout" > /dev/null
    reportdir="$build/reports/$2/$1"
    mkdir -p "$reportdir"
    mv test-reports/* "$reportdir" 2> /dev/null
    rmdir test-reports
#    popd > /dev/null
}

makeoutput()
{
    echo "" > "$testout"
    echo "" > "$testerr"
}

commonbuild()
{
    echo "Building $1 for $3 $5"
    rm -rf "$obj"
    rm -rf "$sym"
    xcodebuild -workspace "$project.xcworkspace" -scheme "$1" -sdk "$3" $4 -config "$5" $2 OBJROOT="$obj" SYMROOT="$sym" >> "$testout" 2>> "$testerr"
    result=$?
    if [[ $result != 0 ]]; then
        cat "$testerr"
        echo
        echo "** BUILD FAILURES **"
        echo "Build failed for scheme $1"
        exit $result
    fi

    report "$1" "$3"

    failures=`grep failed "$testout"`
    if [[ $failures != "" ]]; then
        echo $failures
        echo
        echo "** UNIT TEST FAILURES **"
        echo "Tests failed for scheme $1"
        exit $result
    fi

}

macbuild()
{
    if $testMac ; then

        makeoutput
        commonbuild "$1" "$2" "macosx" "" "Debug"
        commonbuild "$1" "$2" "macosx" "" "Release"

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

        makeoutput
        commonbuild "$1" "$action" "iphonesimulator" "-arch i386" "Debug"
        commonbuild "$1" "$action" "iphonesimulator" "-arch i386" "Release"

    fi
}

iosbuildproject()
{

    if $testIOS; then

        rm -rf "$obj"
        rm -rf "$sym"
        makeoutput

        cd "$1"
        echo Building debug target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Debug" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" >> "$testout" 2>> "$testerr"
        echo Building release target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Release" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" >> "$testout" 2>> "$testerr"
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


        makeoutput

        cd "$1"
        echo Testing debug target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Debug" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" TEST_AFTER_BUILD=YES >> "$testout" 2>> "$testerr"
        echo Testing release target $2 of project $1
        xcodebuild -project "$1.xcodeproj" -config "Release" -target "$2" -arch i386 -sdk "iphonesimulator" build OBJROOT="$obj" SYMROOT="$sym" TEST_AFTER_BUILD=YES >> "$testout" 2>> "$testerr"
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
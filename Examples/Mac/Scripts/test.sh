echo Testing Mac ECLoggingSample xx

base=`dirname $0`
source "$base/../../../Tests/ECUnitTests/Scripts/test-common.sh"

# build the framework

xcodebuild -workspace "ECLoggingSample.xcworkspace" -scheme "ECLoggingSample"
# xcodebuild -target "ECLoggingSample" -configuration $testConfig -sdk "$testSDKMac" $testOptions

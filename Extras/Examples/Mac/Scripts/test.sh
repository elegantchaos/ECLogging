echo Testing ECLoggingSampleMac

base=`dirname $0`
source "$base/../../../Tests/ECUnitTests/Scripts/test-common.sh"

xcodebuild -workspace "ECLoggingSample.xcworkspace" -scheme "ECLoggingMac" -sdk "$testSDKMac"
xcodebuild -workspace "ECLoggingSample.xcworkspace" -scheme "ECLoggingSampleMac" -sdk "$testSDKMac"

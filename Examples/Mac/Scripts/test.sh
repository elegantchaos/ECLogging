echo Testing Mac ECLoggingSample xx

base=`dirname $0`
source "$base/../../../Tests/ECUnitTests/Scripts/test-common.sh"

xcodebuild -workspace "ECLoggingSample.xcworkspace" -scheme "ECLoggingMac"
xcodebuild -workspace "ECLoggingSample.xcworkspace" -scheme "ECLoggingSample"
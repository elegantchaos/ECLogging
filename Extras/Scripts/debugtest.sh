otool -L "$1/Contents/MacOS/*"

export DYLD_PRINT_LIBRARIES=YES
export DYLD_PREBIND_DEBUG=YES
export DYLD_PRINT_ENV=YES
export DYLD_PRINT_APIS=YES
export OBJC_DISABLE_GC=YES

xcrun otest "$1"

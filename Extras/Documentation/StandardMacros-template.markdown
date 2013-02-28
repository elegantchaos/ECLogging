ECLogging defines some standard macros and compiler variables which can be used by other code.

Two macros `EC_DEBUG` and `EC_RELEASE` control the definition of many of the other macros and much of the logging code.

One of these two must be defined. 

If you use the <StandardConfigFiles>, `EC_DEBUG` will be defined for Debug configurations, and `EC_RELEASE` for Release configurations.

If you don't use the standard config files, you need to ensure that you #define one or other of these in your prefix file, before including <ECLogging/ECLogging.h>.


# Macros

### EC_DEPRECATED

This is used internally to indicate deprecated methods.

### ECUnused()

This is used to mark unused variables or return values.

### EC_HINT_UNUSED

This is used to hint to the compiler that a variable or argument is unused.


### EC_EXPORTED

This is used to indicate that a method or class should be exported.


### ECUnusedInDebug()

This is used to mark variables or return values that are unused in debug builds.

### ECUnusedInRelease()

This is used to mark variables or return values that are unused in release builds.

### ECDebugOnly()

This is used to wrap code that should only be defined in debug builds.

    ECDebugOnly(my_func(1));

is a quick way of doing

    #ifdef EC_DEBUG
        my_func(1);
    #endif

### ECReleaseOnly()

This is used to wrap code that should only be defined in release builds.

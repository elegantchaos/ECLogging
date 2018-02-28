Prefix Files
------------

The ECFrameworks all use a pattern of having two main configurations - Debug and Release, with corresponding
xcconfig files for each one, which include a shared file.

Previously a different precompiled prefix file was then included, based on the configuration
(eg ECLoggingDebug.pch or ECLoggingRelease.pch), and this prefix file defined one of the macros
EC_DEBUG or EC_RELEASE, depending on the configuration.

With the advant of Swift and Clang modules, it's necessary to have these macros defined by the xcconfig files
and passed in to the compiler. Because of this there is now generally only a single prefix file required (eg ECLogging.pch).

Typically the only purpose of this file is to @import the required frameworks.

The intention is that you set up your own project to have xcconfig files using the same pattern, and then
to use a single prefix file.

If you have more than two configurations, that's fine - just choose to #define either EC_DEBUG or EC_RELEASE in the xcconfig for
each one.

An easy way to set this sort of thing up in your project is to have a use a build setting like this:

    GCC_PREFIX_HEADER = Source/Prefix/$(PROJECT_NAME).pch

If your project is called "Blah" this will automatically use the prefix file "Source/Prefix/Blah.pch".
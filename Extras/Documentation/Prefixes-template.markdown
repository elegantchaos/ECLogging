Prefix Files
------------

The ECFrameworks all use a pattern of having two main configurations - Debug and Release - and having a different prefix (pch) file for each configuration.

The intention is that you set up your own project to have prefixe files using the same pattern, and then #import either <ECConfig/ECConfigDebug.pch> or <ECConfig/ECConfigRelease.pch> from each one as appropriate.

If you have more than two configurations, that's fine - just choose to #import either the ECConfigDebug or ECConfigRelease pch from each one.

Typically you'll want to also have a shared prefix file that all your other prefix files #import, in which you put all definitions that are shared between all configurations (ECConfig does this itself internally, with both ECConfigDebug and ECConfigRelease importing ECConfigShared).

An easy way to set this sort of thing up in your project is to have a use a build setting like this:

    GCC_PREFIX_HEADER = Source/Prefix/$(PROJECT_NAME)$(CONFIGURATION).pch

If your project is called "Blah", and you have Debug, Release and AppStore configurations, this will automatically use the prefix files "Source/Prefix/BlahDebug.pch", "Source/Prefix/BlahRelease.pch", and  "Source/Prefix/BlahAppStore.pch" respectively.

You can then create these files and set them up like this:

BlahDebug.pch:

    #import <ECConfig/ECConfigDebug.pch>
    #import "BlahShared.pch"
    
    #define SOME_DEBUG_SETTING_HERE
    // etc...

BlahRelease.pch:

    #import <ECConfig/ECConfigRelease.pch>
    #import "BlahShared.pch"

    #define SOME_RELEASE_SETTING_HERE
    // etc...

BlahAppStore.pch:

    #import <ECConfig/ECConfigRelease.pch>
    #import "BlahShared.pch"
    
    #define SOME_APP_STORE_SETTING_HERE
    // etc...


BlahAppShared.pch:

    #define SOME_SHARED_SETTING_HERE
    #import <ECLogging/ECLogging.h> // for example, let's use the ECLogging framework
    #import <SomeOtherFramework/SomeOtherFramework.h>
    // etc...



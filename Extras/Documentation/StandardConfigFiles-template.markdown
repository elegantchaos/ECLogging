Configuration Files
===================

ECLogging contains some standard Xcode configuration files.

These help to ensure that all of the EC frameworks are built with the same settings. 

They can also simplify the process of setting up a new project.

Finally, in a sense they serve as a way for me to document the settings that each kind of project needs, since they give a definitive place to put the essential settings!

Organisation
------------

### Core Configs

The files are layered. At the bottom are the core configs. These are typically included by other configs, so you don't need to include them directly.

The bottom layer contains settings for any project.

There are two variations, one for each of the Debug and Release configurations: 

- ECDebug.xcconfig
- ECRelease.xcconfig

These define extra settings to be used by all projects when built in Debug or Release respectively. Both of these also include another file:

- ECShared.xcconfig

This defines settings that _all_ projects should have.


### Platform Configs

The next layer consists of per-platform configs. These are typically the ones that you'll actually include:

- ECIOSDebug.xcconfig
- ECIOSRelease.xcconfig
- ECMacDebug.xcconfig
- ECMacRelease.xcconfig

Again, these also include a shared file for each platform:

- ECIOSShared.xcconfig
- ECMacShared.xcconfig

These shared files define settings to be shared by both the Debug and Release configurations on each platform.


### Mix-in Configs

In addition there are some "mix-in" configs that can be included. These typically define the standard settings required for different kinds of target - eg frameworks, applications, unit tests.

Current mix-in configs include:

- ECUnitTests.xcconfig -- for oncunit unit test bundles
- ECPseudoFramework.xcconfig -- for 'fake' frameworks on iOS
- ECFramework.xcconfig -- for proper frameworks on the Mac


Usage
-----

Annoyingly, Xcode doesn't look in the build products folder when searching for files included in xcconfig files.

This means that we can't include things from the XCConfig framework in a totally portable way, by doing

    #include <ECLogging/ECMacDebug.xcconfig>

Instead, we have to assume that the framework's source folder is actually at a known relative location.

See <ImportNote> for more details on how to import the xcconfigs into your project.

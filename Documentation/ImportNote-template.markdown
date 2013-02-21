Finding The Standard Config Files
---------------------------------

Annoyingly, Xcode doesn't look in the build products folder when searching for files included in xcconfig files.

This means that in a project's xcconfig files, we can't include things from the ECConfig framework in a totally portable way.

If we could look in the build products, we could arrange for the standard xcconfig files to get copied into the ECConfig framework, then include them from there by doing:

    #include <ECConfig/ECMacDebug.xcconfig>


Unfortunately, this doesn't work. Instead, we have to assume that the framework's source folder is actually at a known relative location.

In the other EC frameworks, we assume that they are all in the same folder in the host project, for example, they might be arranged like this:

    myproj/
      myproj.xcodeproj
      source/
      frameworks/
        ECConfig/
        ECUnitTest/
        ECLogging/
        ... and so on
        
        
By making this assumption, the other frameworks know the relative path of the ECConfig xcconfig files, and thus can include them like this:

    #include "../ECConfig/Source/Configuration/ECIOSDebug.xcconfig"
    #include "../ECConfig/Source/Configuration/ECPseudoFramework.xcconfig"


If you don't set things up this way, you'll probably get a build warning like this:

    ECMacDebug.xcconfig line 8: Unable to find included file...


If you don't want to actually put them all in the same place, you can fake it by adding a symbolic link called ECConfig that points to the right place.

Of course, in your own project, if you want to include ECConfig xcconfig files, you can simply use a relative link to wherever you located them.


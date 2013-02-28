Finding The Standard Config Files
---------------------------------

Annoyingly, Xcode doesn't look in the build products folder when searching for files included in xcconfig files.

This means that in a project's xcconfig files, we can't include things from the ECLogging framework in a totally portable way.

If we could look in the build products, we could arrange for the standard xcconfig files to get copied into the ECLogging framework, then include them from there by doing:

    #include <ECLogging/ECMacDebug.xcconfig>


Unfortunately, this doesn't work. Instead, we have to assume that the framework's source folder is actually at a known relative location.

In the other EC frameworks, we assume that they are all in the same folder in the host project, for example, they might be arranged like this:

    myproj/
      myproj.xcodeproj
      source/
      frameworks/
        ECLogging/
        ECCore/
        ... and so on
        
        
By making this assumption, the other frameworks know the relative path of the ECLogging xcconfig files, and thus can include them from their own xcconfig files, like this:

    #include "../ECLogging/Source/Configuration/ECIOSDebug.xcconfig"
    #include "../ECLogging/Source/Configuration/ECPseudoFramework.xcconfig"


If you don't set things up this way, you'll probably get a build warning like this:

    ECMacDebug.xcconfig line 8: Unable to find included file...

This may well then confuse Xcode further, if you're using things that are defined in the standard configs.


If you're using more than one EC framework in a project and you don't want to actually them in the same place, you can fake it by adding a symbolic link called ECLogging that points to the right place. This will allow the other EC frameworks to find ECLogging.

Of course, in your own project, if you want to include ECLogging xcconfig files from your xcconfig files, you will know where you've put ECLogging, so you don't need to worry about this - you can simply use a relative link to them in your #include statement.


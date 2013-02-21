Project Organisation
====================

All of the EC frameworks and example projects follow some standard organisational conventions.

Typically, the project structure is as follows:

    project/
      project.xcproj
      Source/
        Configuration
        Prefix
        Generic
        Mac
        IOS
      Resources/
        Info.plist
        
      

The Configuration folder contains xcconfig files (<Configs>). 

Typically there is one file per configuration/target combination, and the project settings will be set to use these files. As many settings as possible will be deleted from the project and target panels, and instead defined in these files or the files that they include.

The Prefix folder contains pch files (<Prefixes>). If it uses the standard xcconfig files, each target will automatically look for a prefix file called Debug.pch or Release.pch (depending on the selected configuration). Both of these files will typically include another, called "Shared.pch", containing shared settings. 
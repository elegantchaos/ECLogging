By "installation" in this context I mean: "how can you use this thing in your project?"

There are essentially three answers.

##Drop In The Source#####

You can just grab the repo (or add it to your project as a submodule), and drop the source code into your project.

If you do this, you will want the following folders:

- Source/Generic/
- Source/Prefix/

and one of:

- Source/iOS/ (on iOS)
- Source/Mac/ (on the Mac)

My goal is for it to all just compile, so please let me know if there are problems (or fork it and fix them then send me a pull request!).

##Drop In The Project######

There is a workspace and project file included along with the code. This project builds Mac and iOS shared libraries. You can either build these as a standalone step and just use the built libraries, or you can drop the project into your own project or workspace, and link to the relevant targets.

If you do this, don't forget that you'll need Xcode to be able to find the headers. The libraries build them to a folder called includes/eclogging/ inside the build products folder, so you can add that to your include paths. Alternatively, you can adopt some sort of hybrid option where you link to the built library but also drop the headers into your project so that Xcode can see them.

##ECFoundation Framework######

ECLogging is also still part of the [ECFoundation](http://github.com/elegantchaos/ECFoundation) framework.

The point of this framework is as an umbrella wrapper for all of my major modules of open source code. As such, the goal is to make sure that it contains versions of everything that work nicely together.

ECFoundation builds as an actual framework (or a static linked pseudo-framework on iOS), so one option is to grab ECLogging this way.

One downside of ECFoundation though is that the modules do lots of different things, and thus need quite a few system frameworks. So if you link to ECFoundation, you'll find that you need to link to quite a few optional system frameworks too. You'll only need to weak link to the ones you aren't using, but still - it's a bit of a hassle.

If you choose to go down the ECFoundation route, you'll need to qualify your import statements accordingly.

So rather than

    #import "ECLogging."

you'd do:

   #import <ECFoundation/ECLogging.h>


Other than that, it should all work the same way - it is, after all, the same code.


##Other Things You Need To Do#####

###Defines

One other thing you need to do is to #define either EC_DEBUG 1, or EC_RELEASE 1, to tell ECLogging what to do with debug channels, assertions, and so on.

There are some handy prefix files that do this for you, so one way to do it is to #import them from within your own precompiled headers.

Alternatively, add the definition to your project file, your own prefix file, or an xcconfig file - just make sure that one of the symbols is defined before you include any ECLogging header files. If you don't, it should generate a compiler error to let you know!

###Submodules

Also, I lied slightly when I said that ECLogging has no dependencies on any other ECFoundation modules.

Some test scripts in the Extras/ folder rely on ECUnitTests, which is linked in as a submodule. There's also a link in Extras/Documentation/ to this wiki, so that you can grab a text copy of the content.

If you want to use either of these things, you'll need to do the normal git submodule dance:

    > git submodule init
    > git submodule update

Or use a nice graphical git client which might well do it for you.

----

Back to [[Home]]

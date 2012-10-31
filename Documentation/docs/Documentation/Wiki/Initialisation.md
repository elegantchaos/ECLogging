Before using the engine, you need to start it up and install the log handlers that you're going to use.

This doesn't require much code. A typical place to do it would be at the top of applicationWillFinishLaunching, before doing anything else:

(apologies for the weird spacing in the code below - the github markdown parser gets confused by multiple square brackets and thinks that they are links!)


    // initialise log manager
    ECLogManager* lm = [ECLogManager sharedInstance];
    [lm startup];
    
    // install some handlers
    [lm registerHandler:[ [ [ECLogHandlerNSLog alloc] init] autorelease] ];
    [lm registerHandler:[ [ [ECLogHandlerFile alloc] init] autorelease] ];


You should also shut the log manager down before terminating. This ensures that it gets a chance to save out any settings changes you've made. On the mac, you might put this in applicationWillTerminate:

    [ [ECLogManager sharedInstance] shutdown];


Finally, it's not a bad idea to explicitly save the settings when your application goes into the background - just in case it gets abruptly terminated by something. For example, in applicationWillResignActive you might do:

    [ [ECLogManager sharedInstance] saveChannelSettings];



This will ensure that your current setup is restored next time.


***

Back to [[Home]]
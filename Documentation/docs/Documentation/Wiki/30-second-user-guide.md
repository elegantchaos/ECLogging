This is the 30 second introduction...


Most of the commands have a Log and a Debug variant. The Log version always works. The Debug version only works in debug builds, and does nothing in release builds.

Before you can log to a channel, you need to define it:

    ECDefineLogChannel(SomeChannel);
    ECDefineDebugChannel(AnotherChannel);

Logging something to a channel is very like NSLog, except that you also pass the channel in:

    ECLog(SomeChannel, @"some text %d", someInt);
    ECDebug(AnotherChannel, @"my array looks like this %@", someArray);

You can also log arbitrary objects, for example:

    NSImage* image = [NSImage imageNamed:@"image.png"];
    ECDebug(AnotherChannel, image);

The default log handlers deal with arbitrary objects by logging their description, but custom handlers can do more clever things like actually displaying images.

The channels all default to off, so that the log isn't spammed. You can turn individual channels on using the various UI classes that you can integrate with your iOS / Mac application.

The channel settings will persist, so each user/tester can set it up to only view the channels they need right now.

You can also turn channels on in code, using ECEnableChannel(c) / ECDisableChannel(c). That's not generally the way to do it though, because you're forcing everyone to use the same channel setting, which is what the system is designed to avoid. It's helpful if you've not yet integrated the UI though.

ECDebug channels compile out completely at runtime, so anything in an ECDebug() call doesn't happen. ECLog calls don't.

There are some basic log handlers: ECLogHandlerNSLog, ECLogHandlerStdOut, etc. You can write log handlers to do more interesting things. You could integrate with asl, or log4j. You could send the log output to a socket. You could keep it in memory and display it in a UIView, or email it back to yourself after the user gave you permission. And so on...


----

Back to [[Home]]

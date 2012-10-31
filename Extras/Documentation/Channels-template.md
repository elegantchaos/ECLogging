A log channel is a place to send log messages to.

You get to define as many channels as you like, organised in whatever way makes sense. 

This allows you to turn most logging off most of the time, and just enable the bits that you happen to be interested in right now.

Log and Debug
-------------

Channels come in two flavours, log and debug.

Log channels are always available. 

Debug channels are only available in debug targets (ones where EC_DEBUG is defined). In non-debug builds, debug channels don't exist. Anything inside ECDebug() messages won't get compiled or executed at all. This allows you to put potentially time-consuming logging code into these calls, safe in the knowledge that it won't affect the final performance of your app.

Defining Channels
-----------------

Channels must be defined before use. This is done once for each channel, in a .m file. For example:

    ECDefineLogChannel(MyLogChannel);
    ECDefineDebugChannel(MyDebugChannel);

If you want to share a channel between multiple files, you can also declare it in a .h file:

    ECDeclareLogChannel(MyLogChannel);
    ECDeclareDebugChannel(MyDebugChannel);

Using Channels
--------------

To use a channel, you send stuff to it with ECLog or ECDebug:

    ECLog(MyLogChannel, @"this is a test %@ %d", @"blah", 123);

    ECDebug(MyDebugChannel, @"doodah");

As mentioned above, ECLog statements will always be compiled, so you need to use them with channels defined by ECDefineLogChannel.

You can use ECDebug with channels that were defined with either ECDefineLogChannel or ECDefineDebugChannel. Any ECDebug statements will be compiled in debug builds, but not in release builds.

Logging Objects
---------------

As well as the more usual text logging, you can also send arbitrary objects to a log channel.

    NSImage* image = [NSImage imageNamed:@"blah.png"];
    ECDebug(MyLogChannel, image);

What the log handlers do with objects that you log is up to them. The default behaviour for simple text-based log handlers is just to call [object description] on the object and log that. 

However, custom log handlers can do anything that they want. For example, you might have a log handler which takes any images that you log and displays them in a scrolling window.

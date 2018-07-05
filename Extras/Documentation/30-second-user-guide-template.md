This is the 30 second introduction...

## Usage

Most of the commands have a Log and a Debug variant. The Log version always works. The Debug version only works in debug builds, and does nothing in release builds.

Before you can log to a channel, you need to define it:

    ECDefineLogChannel(SomeChannel);
    ECDefineDebugChannel(AnotherChannel);

Logging something to a channel is very like NSLog, except that you also pass the channel in:

    ECLog(SomeChannel, @"some text %d", someInt);

You can also log arbitrary objects, for example:

    NSImage* image = [NSImage imageNamed:@"image.png"];

The default log handlers deal with arbitrary objects by logging their description, but custom handlers can do more clever things like actually displaying images.

## Configuration

Configuration information is stored using NSUserDefaults, so that you can change channel and handler settings during a debug session and they will remain the same next time.

Initial values are loaded from an ECLogging.plist (or ECLoggingDebug.plist) file, which you add to your app. If this file is missing, a basic NSLog-based log handler will be registered with the system so that you still get to see some output.

Channels generally default to off, so that the log isn't spammed. 

You can turn individual channels on:

- using supplied UI classes that you can add to your app's debug builds
- in the ECLogging.plist file
- using ECEnableChannel(c) / ECDisableChannel(c) in code

Using the UI is the best way, since the changes will only apply to the machine you're on (so each user can enable a different set of channels).

## Release Builds

ECLog calls don't - this allows you to leave some logging in to your release, default it to off, but allow a user to turn it on to help you track down bugs.

Default settings are read from ECLogging.plist in release builds, or from ECLoggingDebug.plist (if it exists) in debug builds - thus you can have different defaults for either.

There are some basic log handlers: ECLogHandlerNSLog, ECLogHandlerStdOut, etc. You can write log handlers to do more interesting things. You could integrate with asl, or log4j. You could send the log output to a socket. You could keep it in memory and display it in a UIView, or email it back to yourself after the user gave you permission. And so on...

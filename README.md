What's This?
------------

ECLogging provides a flexible logging system for iOS and MacOS X software to use.

Essentially, it's a smarter replacement for "printf" or "NSLog" style debug output.

The problem with simply using something like NSLog is that you either end up with reams of debug output, in which case you can't see the wood for the trees, or you end up with messy source code where you're endlessly commenting logging statements in/out. This is especially bad if you work on a big project and/or with lots of developers.

What all my various implementations of a logging system share is the ability to define named channels, and log handlers. These named channels can be organised functionally, rather than by "level". You don't just have to have "warning", "error", or "really bad error". You can have a channel like "stuff related to application notifications", or even "stuff relating to fixing bug #321".

You can direct logging output to a particular channel. All channels are off by default, so you can add detailed logging support to any file or module without spamming the log. If I make a channel, you won't see it in your log unless you choose to turn it on. When you need to, you can turn a particular channel or group of channels on. For release versions, you can compile away all logging completely, for top performance. Or you can choose to leave some log channels in the release build.

The output of log channels is directed through one or more log handlers. What log handlers give you is the ability to globally direct log output into alternative destinations. The console is one option, but you can also write a handler to log to the disk, or a remote machine, or a custom ui, or wherever.

For More Information
--------------------

See the wiki: https://github.com/samdeane/ECLogging/wiki/Home
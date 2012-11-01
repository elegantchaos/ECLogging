##Levels######

Channels are named, and generally the idea is that you use a channel to group together related log messages, then you turn that channel on when you want to focus on that area.

However, some other logging systems have the concept of a log level - for example error, debug, warning, info, and so on.

Whilst ECLogging doesn't particularly encourage this way of working with logging (I think that it's very limiting to classify log messages so crudely), log channels do support the concept of a level that you can assign them to.

Log handlers can then read the channel's level and use it to determine the level of the messages that get logged from that channel.

Currently the only way to set the level for a channel is using the ECLogging.plist (or directly, in code). At some point I hope to add a UI for this too.

Currently the only log handler that uses the level is the ASL handler.

##To Do List######

There's lot of stuff that I plan to add to ECLogging, but it generally gets done on an ad-hoc basis as and when I need it.

As an experiment, I've created a Trello board to track [ECLogging To Do tasks](https://trello.com/board/eclogging/4ec67791b475c76d723cad97).


----

Back to [[Home]]

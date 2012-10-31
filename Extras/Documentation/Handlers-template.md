Log handlers are responsible for taking the text and objects that you log, and, well, logging them...

How they do this depends on the handler in question. ECLogging comes with built in handlers to:

- log to NSLog
- log to stdout (with printf)
- log to stderr (with fprintf)
- log to the Apple System Log (ASL)
- log to a file

You can easily write your own handlers. Some ideas (that might one day make it into the core of ECLogging) include:

- log to Log4J
- log to a window in the app itself
- draw logged image objects
- play logged sound objects or movies
- log to an sql database
- log over a port or socket for viewing on a viewer application

Using Handlers
--------------

Any handler that you want to use need to be registered with ECLogging when the application starts up.

Initially, all channels will use the default handler set - which by default is all registered handlers. 

However, you can configure a log channel to tell it to just use certain handlers. You can also configure the default handler set to narrow it down.

This configuration is done using the provided user interface support classes, or with an accompanying plist file that you add to your project.

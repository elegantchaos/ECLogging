By default, all channels are disabled, and they are all set to use the default set of log handlers.

There are two main ways to configure channels:

- with the UI support classes (see [[User Interface]])
- with the ECLogging.plist file


## ECLogging.plist

When the logging system starts up, it looks for its settings, saved with the NSUserDefaults system. 

If it doesn't find them (because this is the first time you've run this particular application), it tries to read the default settings instead from a file called ECLogging.plist in the application resources.

By adding one of these files to your application and configuring it, you can determine default settings for your channels.

The [[ECLoggingSample|https://github.com/elegantchaos/ECLogging/tree/master/Extras/Examples]] projects illustrate how to do this.

Note that it's not a good idea to enable channels by default, it's far better to set the application up to use the UI so that each user can enable their own set of channels.



----

Back to [[Home]]
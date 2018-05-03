// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLoggingMacros.h"
#import "ECLogContext.h"

EC_ASSUME_NONNULL_BEGIN

@class ECLogChannel;

/**
 Base class for all log handlers. 
 
 This isn't a class you typically interact with directly. The methods in the class are generally used by the logging system itself, or subclasses of ECLogChannel.
 
 ### About
 
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

 ### Usage

 Any handler that you want to use need to be registered with ECLogging when the application starts up.

 You do this by adding an entry to the Handlers dictionary in the ECLogging.plist file.

 Initially, all channels will use the default handler set - which by default is all registered handlers.

 However, you can configure a log channel to tell it to just use certain handlers. You can also configure the default handler set to narrow it down.

 This configuration is done using the provided user interface support classes, or with an accompanying plist file that you add to your project.

 */

@interface ECLogHandler : NSObject

@property (strong, nonatomic) NSString* name;

/**
 Called by the log manager for each message/object sent to a channel.
 
 @param channel The channel that the log message was sent to.
 @param object The object/message being logged.
 @param arguments Additional arguments to the log command.
 @param context The context in which the object/message is being logged.
 */

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context;



/**
 Helper method to perform a case insensitive comparison with another handler - can be used to sort handlers by name.
 
 @param other The other handler to compare against.

 */

- (NSComparisonResult)caseInsensitiveCompare:(ECLogHandler*)other;



/**
 Returns a simple composed string with output a logged object, using the given context and channel settings.
 
 Can be used by text-based log handlers which simply want to output text.
 
 @param channel The channel being logged to.
 @param object The object being logged.
 @param arguments Additional arguments to the logging command.
 @param context The context in which the object is being logged.
 */

- (NSString*)simpleOutputStringForChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context;



/**
 Called by the log manager to indicate that the handler was enabled for a channel.

 @param channel The channel that is now using the handler.
 */

- (void)wasEnabledForChannel:(ECLogChannel*)channel;



/**
 Called by the log manager to indicate that the handler was disabled for a channel.
 
 @param channel The channel that has stopped using the handler.
 */

- (void)wasDisabledForChannel:(ECLogChannel*)channel;
@end

EC_ASSUME_NONNULL_END

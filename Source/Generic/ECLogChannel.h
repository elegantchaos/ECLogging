// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogContext.h"

EC_ASSUME_NONNULL_BEGIN

@class ECLogHandler;

/**
 These log levels correspond to those used by ASL, and are used by anything that
 wants to set the log level of a channel.
 
 Log levels aren't really a concept that's fully embraced by ECLogging - you are
 much better off just making separate log channels for the various levels of 
 logging/notification that you want to differentiate. However, level support is provided
 for compatibility with os_log() / asl.
 */

typedef NS_ENUM(NSUInteger, ECSystemLogLevel) {
	ECSystemLogLevelEmergency,
	ECSystemLogLevelAlert,
	ECSystemLogLevelCritical,
	ECSystemLogLevelError,
	ECSystemLogLevelWarning,
	ECSystemLogLevelNotice,
	ECSystemLogLevelInfo,
	ECSystemLogLevelDebug
};


/**
 
 This isn't a class you typically interact with directly. The methods in the class are generally used by the logging system itself.

 ## About
 
 A **channel** is a place to send log messages to.

 You get to define as many channels as you like, organised in whatever way makes sense.

 This allows you to turn most logging off most of the time, and just enable the bits that you happen to be interested in right now.

 ### Log and Debug

 Channels come in two flavours, log and debug.

 Log channels are always available.

 Debug channels are only available in debug targets (ones where EC_DEBUG is defined). In non-debug builds, debug channels don't exist. Anything inside ECDebug() messages won't get compiled or executed at all. This allows you to put potentially time-consuming logging code into these calls, safe in the knowledge that it won't affect the final performance of your app.

 ### Defining Channels

 Channels must be defined before use. This is done once for each channel, in a .m file. For example:

	ECDefineLogChannel(MyLogChannel);
	ECDefineDebugChannel(MyDebugChannel);

 If you want to share a channel between multiple files, you can also declare it in a .h file:

	ECDeclareLogChannel(MyLogChannel);
	ECDeclareDebugChannel(MyDebugChannel);

 ### Usage

 To use a channel, you send stuff to it with ECLog or ECDebug:

	 ECLog(MyLogChannel, @"this is a test %@ %d", @"blah", 123);

	 ECDebug(MyDebugChannel, @"doodah");

 As mentioned above, ECLog statements will always be compiled, so you need to use them with channels defined by ECDefineLogChannel.

 You can use ECDebug with channels that were defined with either ECDefineLogChannel or ECDefineDebugChannel. Any ECDebug statements will be compiled in debug builds, but not in release builds.

 ### Logging Objects

 As well as the more usual text logging, you can also send arbitrary objects to a log channel.

	 NSImage* image = [NSImage imageNamed:@"blah.png"];
	 ECDebug(MyLogChannel, image);

 What the log handlers do with objects that you log is up to them. The default behaviour for simple text-based log handlers is just to call [object description] on the object and log that.

 However, custom log handlers can do anything that they want. For example, you might have a log handler which takes any images that you log and displays them in a scrolling window.

 */

@interface ECLogChannel : NSObject

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

/**
 Context flags that apply to any message sent to the channel.
 */

@property (assign, nonatomic) ECLogContextFlags context;


/**
 Is the channel enabled?
 */

@property (assign, nonatomic) BOOL enabled;


/**
 Has the channel been set up?
 */

@property (assign, nonatomic) BOOL setup;


/**
 Log level of the channel.
 */

@property (strong, nonatomic) NSNumber* level;


/**
 Name of the channel.
 */

@property (strong, nonatomic) NSString* name;


/**
 Handlers that the channel's output will be sent to.
 */

@property (strong, nonatomic, ec_nullable) NSMutableSet* handlers;

/**
 Parent channel. 
 Any message logged to this channel will also be logged to the parent channel.
 If the parent channel is disabled, this channel will be, too.
 */

@property (strong, nonatomic, readonly, ec_nullable) ECLogChannel* parent;

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

/**
 Enable the channel.
 */

- (void)enable;


/**
 Disable the channel. Any output sent to the channel will be ignored whilst it is disabled.
 */

- (void)disable;


/**
 Set up a channel with a given name.
 
 @param name The name of the channel.
 */

- (instancetype)initWithName:(NSString*)name;

/**
 Set up a channel with a given name.

 @param name The name of the channel.
 @param parent The parent channel. Can be nil, indicating that the channel has no parent.

 */

- (instancetype)initWithName:(NSString*)name parent:(ec_nullable ECLogChannel*)parent NS_DESIGNATED_INITIALIZER;

/**
 Comparison function to sort channels by name.
 @param other The other channel to compare against.
 @return Comparison result.
 */

- (NSComparisonResult)caseInsensitiveCompare:(ECLogChannel*)other;


/**
 Enable a handler for this channel.
 @param handler The handler to enable. Any output sent to this channel will get passed to the enabled handler.
 */

- (void)enableHandler:(ECLogHandler*)handler;


/**
 Disable a handler for this channel.
 @param handler The handler to disable. Any output sent to this channel will no longer get passed to the disabled handler.
 */

- (void)disableHandler:(ECLogHandler*)handler;


/**
 Will this channel pass output to a given handler?
 @param handler The handler to check for.
 @return YES if the handler is enabled for this channel.
 */

- (BOOL)isHandlerEnabled:(ECLogHandler*)handler;


/**
 Should any log output for this channel include context information for the given context flags?
 @param flags Flags we're checking.
 @return YES if context information should be shown.
 */

- (BOOL)showContext:(ECLogContextFlags)flags;


/**
 Return a formatted string giving the file name and line number from a
 context structure.
 @param context The context information
 @return String with the file name and line number.
 */

- (NSString*)fileFromContext:(ECLogContext*)context;


/**
 Return a formatted string describing a context structure, based on our
 context flags.
 
 @param context The context.
 @return String describing the context.
 */


- (NSString*)stringFromContext:(ECLogContext*)context;


/**
 UI helper - should we tick a menu item for a given flag index?
 
 @param index The index of the flag.
 @return YES if it should be ticked.
 */


- (BOOL)tickFlagWithIndex:(NSUInteger)index;


/**
 UI helper - respond to a context flag being selected.
 
 We respond by toggling the flag on/off.

 @param index The index of the flag.
*/

- (void)selectFlagWithIndex:(NSUInteger)index;


/**
 UI helper - should we tick a menu item for a given handler index?

 @param index The index of the handler.
 @return YES if it should be ticked.
 */

- (BOOL)tickHandlerWithIndex:(NSUInteger)index;


/**
 UI helper - respond to a handler being selected.

 We respond by enabling/disabling the handler for this channel.

 @param index The index of the handler.
 */

- (void)selectHandlerWithIndex:(NSUInteger)index;


/**
 Return a cleaned up version of a raw channel name.
 
 Removes "Channel" from the end, and splits up MixedCaps words by inserting spaces.
 
 @param name Raw c-style name string.
 @return Cleaned up name.
 */

+ (NSString*)cleanName:(const char*)name;

/**
 Returns the channel name with the application name appended: "<name> (<app name>)".
 Generally for use when logging to the console.
 */

- (NSString*)nameIncludingApplication;

/**
 Disables some flags.
 Returns the previous version of the flags.
 */

- (ECLogContextFlags)disableFlags:(ECLogContextFlags)flags;

/**
 Returns our context flags, with a given flag removed.
 */

- (ECLogContextFlags)flagsExcluding:(ECLogContextFlags)flags;

@end

EC_ASSUME_NONNULL_END

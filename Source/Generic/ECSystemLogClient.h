// --------------------------------------------------------------------------
//  Copyright 2016 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

/**
 These log levels correspond to those used by ASL.
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
 Abstract class which represents an ASL-style logger.

 This isn't particularly an abstraction we want to continue to support, long-term,
 but for now it's useful to be able to work with ASL on 10.11 and os_log on 10.12 using
 approximately the same interface.
 
 The 10.12 docs claim to shim the asl interface and do this for us, but they don't actually seem to
 (for our use case, at least).
 */

@interface ECSystemLogClient : NSObject

- (instancetype)initWithName:(NSString*)name NS_DESIGNATED_INITIALIZER;

- (void)logAtLevel:(ECSystemLogLevel)level withFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(2, 3);
- (void)log:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);
- (void)error:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

@end

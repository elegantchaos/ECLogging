// --------------------------------------------------------------------------
//
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <asl.h>

@interface ECASLClient : NSObject

+ (ECASLClient*)sharedInstance;
- (instancetype)initWithName:(NSString*)name NS_DESIGNATED_INITIALIZER;

- (void)logAtLevel:(int)level withFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(2, 3);
- (void)log:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);
- (void)error:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

@end

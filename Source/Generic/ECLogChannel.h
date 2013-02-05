// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogContext.h"

@class ECLogHandler;

@interface ECLogChannel : NSObject
{
@private
	BOOL enabled;
	BOOL setup;
	NSString* name;
	NSMutableSet* handlers;
    ECLogContextFlags context;
}

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

@property (assign, nonatomic) ECLogContextFlags context;
@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL setup;
@property (strong, nonatomic) NSNumber* level;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSMutableSet* handlers;

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (void) enable;
- (void) disable;
- (id) initWithName: (NSString*) name;
- (NSComparisonResult) caseInsensitiveCompare: (ECLogChannel*) other;
- (void) enableHandler: (ECLogHandler*) handler;
- (void) disableHandler: (ECLogHandler*) handler;
- (BOOL) isHandlerEnabled:( ECLogHandler*) handler;
- (BOOL) showContext:(ECLogContextFlags)flags;
- (NSString*) fileFromContext:(ECLogContext*)context;
- (NSString*) stringFromContext:(ECLogContext*)context;
- (BOOL)tickFlagWithIndex:(NSUInteger)index;
- (void)selectFlagWithIndex:(NSUInteger)index;
- (BOOL)tickHandlerWithIndex:(NSUInteger)index;
- (void)selectHandlerWithIndex:(NSUInteger)index;
+ (NSString*) cleanName:(const char *) name;

@end


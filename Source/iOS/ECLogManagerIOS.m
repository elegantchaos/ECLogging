// --------------------------------------------------------------------------
//  Copyright 2012 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManagerIOS.h"

@implementation ECLogManager(PlatformSpecific)

static ECLogManager* gSharedInstance = nil;

// --------------------------------------------------------------------------
//! Return the shared instance.
// --------------------------------------------------------------------------

+ (ECLogManager*)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [[ECLogManagerIOS alloc] init];
	});

	return gSharedInstance;
}

@end

@implementation ECLogManagerIOS

@end

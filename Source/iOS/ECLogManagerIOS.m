//
//  ECLogManagerIOS.m
//  ECLogging
//
//  Created by Sam Deane on 31/10/2012.
//  Copyright (c) 2012 Elegant Chaos. All rights reserved.
//

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

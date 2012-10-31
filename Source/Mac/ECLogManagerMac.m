//
//  ECLogManagerMac.m
//  ECLogging
//
//  Created by Sam Deane on 31/10/2012.
//  Copyright (c) 2012 Elegant Chaos. All rights reserved.
//

#import "ECLogManagerMac.h"

@implementation ECLogManager(PlatformSpecific)

static ECLogManager* gSharedInstance = nil;

// --------------------------------------------------------------------------
//! Return the shared instance.
// --------------------------------------------------------------------------

+ (ECLogManager*)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [[ECLogManagerMac alloc] init];
	});

	return gSharedInstance;
}

@end

@implementation ECLogManagerMac

@end

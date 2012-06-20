//
//  ECErrorAndMessage.m
//  ECLogging
//
//  Created by Sam Deane on 10/04/2012.
//  Copyright (c) 2012 Elegant Chaos. All rights reserved.
//

#import "ECErrorAndMessage.h"

@implementation ECErrorAndMessage

@synthesize message = _message;
@synthesize error = _error;

- (void)dealloc
{
	[_error release];
	[_message release];
	
	[super dealloc];
}

- (NSString*)description
{
	NSString* result;
	if (self.error)
	{
		result = [NSString stringWithFormat:@"%@\n%@\n\n%@", self.message, self.error.localizedDescription, self.error.userInfo];
	}
	else
	{
		result = self.message;
	}
	
	return result;
}
@end

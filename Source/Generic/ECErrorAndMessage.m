// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

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

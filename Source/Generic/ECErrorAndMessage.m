// --------------------------------------------------------------------------
//  Copyright 2016 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECErrorAndMessage.h"

@implementation ECErrorAndMessage

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

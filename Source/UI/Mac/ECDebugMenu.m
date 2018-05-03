// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDebugMenu.h"
#import "NSMenu+ECLogging.h"

@implementation ECDebugMenu


#pragma mark - Lifecycle

// --------------------------------------------------------------------------
//! Set up after creation from a nib.
// --------------------------------------------------------------------------

- (void)awakeFromNib
{
	if (![ECLogManager sharedInstance].showMenu)
	{
		[self removeFromParentEC];
	}
}

@end

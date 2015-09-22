// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogViewHandler.h"
#import "ECLogViewHandlerItem.h"
#import "ECLogManager.h"
#import "ECLogChannel.h"

@implementation ECLogViewHandler

NSString* const LogItemsUpdated = @"LogItemsUpdated";

// --------------------------------------------------------------------------
//! Singleton instance.
// --------------------------------------------------------------------------

- (id)init
{
	if ((self = [super init]) != nil)
	{
		self.name = @"View";
	}

	return self;
}

// --------------------------------------------------------------------------
//! Log.
// --------------------------------------------------------------------------

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context
{
	NSMutableArray* itemList = self.items;
	if (!itemList)
	{
		itemList = [NSMutableArray array];
		self.items = itemList;
	}

	ECLogViewHandlerItem* item = [[ECLogViewHandlerItem alloc] init];
	if ([object isKindOfClass:[NSString class]])
	{
		item.message = [[NSString alloc] initWithFormat:object arguments:arguments];
	}
	else
	{
		item.message = [object description];
	}

	item.context = [channel stringFromContext:context];

	[itemList addObject:item];

	[[NSNotificationCenter defaultCenter] postNotificationName:LogItemsUpdated object:self.items];
}

@end

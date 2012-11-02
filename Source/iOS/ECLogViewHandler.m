//
//  ECLogViewHandler.m
//  ECLoggingSample
//
//  Created by Sam Deane on 02/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECLogViewHandler.h"
#import "ECLogViewController.h"
#import "ECLogViewHandlerItem.h"
#import "ECLogManager.h"
#import "ECLogChannel.h"

@implementation ECLogViewHandler

@synthesize items = _items;

NSString *const LogItemsUpdated = @"LogItemsUpdated";

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

- (void)dealloc 
{
    [_items release];
    
    [super dealloc];
}

// --------------------------------------------------------------------------
//! Log.
// --------------------------------------------------------------------------

- (void) logFromChannel: (ECLogChannel*) channel withObject:(id)object arguments: (va_list) arguments context:(ECLogContext *)context
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
		item.message = [[[NSString alloc] initWithFormat:object arguments:arguments] autorelease];
	}
	else
	{
		item.message = [object description];
	}

    item.context = [channel stringFromContext:context];
    
    [itemList addObject:item];
    [item release];

	[[NSNotificationCenter defaultCenter] postNotificationName:LogItemsUpdated object:self.items];
}

@end

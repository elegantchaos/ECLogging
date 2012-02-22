// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 11/08/2010
//
//  Created by Sam Deane on 11/08/2010.
//  Copyright 2011 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "NSString+ECLogging.h"

@implementation NSString(ECCore)


- (NSArray*)componentsSeparatedByMixedCaps
{
	NSMutableArray* result = [NSMutableArray array];
	NSUInteger count = [self length];
	NSMutableString* word = [[NSMutableString alloc] init];
	BOOL wasLower = NO;
	for (NSUInteger n = 0; n < count; ++n)
	{
		UniChar c = [self characterAtIndex: n];
		BOOL isLower = islower(c);
		if (wasLower && !isLower)
		{
			[result addObject:[NSString stringWithString:word]];
			[word deleteCharactersInRange:NSMakeRange(0, [word length])];
		}
		[word appendString:[NSString stringWithCharacters: &c length:1]];
		wasLower = isLower;
	}
	if ([word length])
	{
		[result addObject:word];
	}
	[word release];
	
	return result;
}


- (NSString*) stringBySplittingMixedCaps
{
	NSUInteger count = [self length];
	NSMutableString* result = [[NSMutableString alloc] init];
	BOOL wasLower = NO;
	for (NSUInteger n = 0; n < count; ++n)
	{
		UniChar c = [self characterAtIndex: n];
		BOOL isLower = islower(c);
		if (wasLower && !isLower)
		{
			[result appendString: @" "];
		}
		[result appendString: [NSString stringWithCharacters: &c length:1]];
		wasLower = isLower;
	}
	
	return [result autorelease];
}

@end

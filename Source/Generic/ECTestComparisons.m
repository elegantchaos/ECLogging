//
//  ECTestComparisons.m
//  ECLogging
//
//  Created by Sam Deane on 21/11/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECTestComparisons.h"

@implementation NSObject(ECTestComparisons)

- (BOOL)matches:(id)item2  block:(ECTestComparisonBlock)block
{
	Class c1 = [self class];
	Class c2 = [item2 class];
	NSString* context = nil;
	if (c1 == c2)
		context = [NSString stringWithFormat:@"%@", c1];
	else
		context = [NSString stringWithFormat:@"%@ vs %@", c1, c2];
	
	return [self matches:item2 context:context level:0 block:block];
}

- (BOOL)matches:(id)item2 context:(NSString *)context level:(NSUInteger)level block:(ECTestComparisonBlock)block
{
	BOOL matches = [self isKindOfClass:[item2 class]];
	if (matches)
	{
		matches = [self isEqual:item2];
	}

	if (!matches)
		block(context, level, self, item2);

	return matches;
}

@end

@implementation NSArray(ECTestComparisons)

- (BOOL)matches:(id)item2 context:(NSString *)context level:(NSUInteger)level block:(ECTestComparisonBlock)block
{
	BOOL matches = [self isKindOfClass:[NSArray class]];
	if (!matches)
	{
		NSString* newContext = [NSString stringWithFormat:@"%@ NSArray compared with %@", context, [item2 class]];
		block(newContext, level, self, item2);
	}
	else
	{
		NSUInteger c1 = [self count];
		NSUInteger c2 = [item2 count];
		NSUInteger min = MIN(c1, c2);

		for (NSUInteger n = 0; n < min; ++n)
		{
			NSString* itemContext = [NSString stringWithFormat:@"%@[%ld]", context, n];
			matches = [self[n] matches:item2[n] context:itemContext level:level+1 block:block] && matches;
		}

		if (c1 < c2)
		{
			matches = NO;
			for (NSUInteger n = min; n < c2; ++n)
			{
				NSString* itemContext = [NSString stringWithFormat:@"%@[%ld] extra item", context, n];
				block(itemContext, level, nil, item2[n]);
			}
		}

		else if (c2 < c1)
		{
			matches = NO;
			for (NSUInteger n = min; n < c1; ++n)
			{
				NSString* itemContext = [NSString stringWithFormat:@"%@[%ld] missing item", context, n];
				block(itemContext, level, self[n], nil);
			}
		}
	}
	
	return matches;
}

@end

@implementation NSDictionary(ECTestComparisons)

- (BOOL)matches:(id)item2 context:(NSString *)context level:(NSUInteger)level block:(ECTestComparisonBlock)block
{
	BOOL matches = [self isKindOfClass:[NSDictionary class]];
	if (!matches)
	{
		NSString* newContext = [NSString stringWithFormat:@"%@ NSDictionary compared with %@", context, [item2 class]];
		block(newContext, level, self, item2);
	}
	else
	{
		NSMutableArray* keys2 = [NSMutableArray arrayWithArray:[item2 allKeys]];
		for (NSString* key in self)
		{
			id v1 = self[key];
			id v2 = item2[key];
			if (v2)
			{
				NSString* itemContext = [NSString stringWithFormat:@"%@[@\"%@\"]", context, key];
				matches = [v1 matches:v2 context:itemContext level:level+1 block:block] && matches;
			}
			else
			{
				NSString* itemContext = [NSString stringWithFormat:@"%@[@\"%@\"] missing key", context, key];
				block(itemContext, level, v1, nil);
				matches = NO;
			}
			[keys2 removeObject:key];
		}
		
		for (NSString* key in keys2)
		{
			NSString* itemContext = [NSString stringWithFormat:@"%@[@\"%@\"] extra key", context, key];
			block(itemContext, level, nil, item2[key]);
			matches = NO;
		}
	}
	
	return matches;
}

@end
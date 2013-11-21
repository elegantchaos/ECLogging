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
		context = NSStringFromClass(c1);
	else
		context = [NSString stringWithFormat:@"%@ vs %@", c1, c2];
	
	return [self matches:item2 context:context indent:@"" block:block];
}

- (BOOL)matches:(id)item2 context:(NSString *)context indent:(NSString*)indent block:(ECTestComparisonBlock)block
{
	BOOL matches = [self isKindOfClass:[item2 class]];
	if (matches)
	{
		matches = [self isEqual:item2];
	}

	if (!matches)
		block(context, self, item2);

	return matches;
}

@end

@implementation NSArray(ECTestComparisons)

- (BOOL)matches:(id)item2 context:(NSString *)context indent:(NSString *)indent block:(ECTestComparisonBlock)block
{
	indent = [indent stringByAppendingString:@"\t"];
	NSString* newContext = [NSString stringWithFormat:@"%@\n%@array", context, indent];
	
	BOOL matches = [self isKindOfClass:[NSArray class]];
	if (!matches)
	{
		newContext = [NSString stringWithFormat:@"%@ compared with %@", newContext, [item2 class]];
		block(newContext, self, item2);
	}
	else
	{
		NSUInteger c1 = [self count];
		NSUInteger c2 = [item2 count];
		NSUInteger min = MIN(c1, c2);

		for (NSUInteger n = 0; n < min; ++n)
		{
			NSString* itemContext = [NSString stringWithFormat:@"%@ item %ld", newContext, n];
			matches = [self[n] matches:item2[n] context:itemContext indent:indent block:block] && matches;
		}

		if (c1 < c2)
		{
			matches = NO;
			for (NSUInteger n = min; n < c2; ++n)
			{
				newContext = [NSString stringWithFormat:@"%@ extra item %ld", newContext, n];
				block(newContext, nil, item2[n]);
			}
		}

		else if (c2 < c1)
		{
			matches = NO;
			for (NSUInteger n = min; n < c1; ++n)
			{
				newContext = [NSString stringWithFormat:@"%@ missing item %ld", newContext, n];
				block(newContext, self[n], nil);
			}
		}
	}
	
	return matches;
}

@end
// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestComparisons.h"

@implementation NSObject (ECTestComparisons)

- (BOOL)matches:(id)item2 options:(ECTestComparisonOptions)options block:(ECTestComparisonBlock)block
{
	Class c1 = [self class];
	Class c2 = [item2 class];
	NSString* context = nil;
	if (c1 == c2)
		context = [NSString stringWithFormat:@"%@", [self nameForMatching]];
	else
		context = [NSString stringWithFormat:@"%@ vs %@", [self nameForMatching], [item2 nameForMatching]];
	
	return [self matches:item2 context:context level:0 options:options block:block];
}

- (BOOL)matches:(id)item2 context:(NSString*)context level:(NSUInteger)level options:(ECTestComparisonOptions)options block:(ECTestComparisonBlock)block
{
	BOOL matches = [self isEqual:item2];
	if (!matches)
		block(context, level, self, item2);

	return matches;
}

- (NSString*)nameForMatching
{
	return NSStringFromClass([self class]);
}

@end

@implementation NSString (ECTestComparisons)

- (NSString*)nameForMatching
{
	return @"string";
}

@end

@implementation NSNumber (ECTestComparisons)

- (NSString*)nameForMatching
{
	return @"number";
}

// Returns YES if both numbers are doubles which only differ in the last couple of digits.
// This could happen if we convert a double to a string and then re-interpret it.
- (BOOL)matchesAsNearAsDamnIt:(NSNumber*)other {
    if ( strcmp(self.objCType,"d") == 0 && strcmp(other.objCType,"d") == 0) {
		double a = self.doubleValue;
	 	double b = other.doubleValue;
		return (fabs(a - b) <= ((fabs(a) > fabs(b)) ? fabs(b) : fabs(a)) * DBL_EPSILON * 4.0);
	} else {
		return NO;
	}
}

- (BOOL)matches:(id)item2 context:(NSString*)context level:(NSUInteger)level options:(ECTestComparisonOptions)options block:(ECTestComparisonBlock)block {
    BOOL matches = [self isEqualTo:item2];
    if (!matches) {
        if ((options & ECTestComparisonDoubleFuzzy) && [item2 isKindOfClass:[NSNumber class]]) {
            matches = [self matchesAsNearAsDamnIt:item2];
	    }
    }

    if (!matches) {
        block(context, level, self, item2);
    }
    return  matches;
}

@end

@implementation NSArray (ECTestComparisons)

- (BOOL)matches:(id)item2 context:(NSString*)context level:(NSUInteger)level options:(ECTestComparisonOptions)options block:(ECTestComparisonBlock)block
{
	BOOL matches = [item2 isKindOfClass:[NSArray class]];
	if (!matches)
	{
		NSString* newContext = [NSString stringWithFormat:@"%@ %@ compared with %@", context, [self nameForMatching], [item2 nameForMatching]];
		block(newContext, level, self, item2);
	}
	else
	{
		NSUInteger c1 = [self count];
		NSUInteger c2 = [(NSArray*)item2 count];
		NSUInteger min = MIN(c1, c2);

		for (NSUInteger n = 0; n < min; ++n)
		{
			NSString* itemContext = [NSString stringWithFormat:@"%@[%ld]", context, (long)n];
			matches = [self[n] matches:item2[n] context:itemContext level:level + 1 options:options block:block] && matches;
		}

		if (c1 < c2)
		{
			matches = NO;
			for (NSUInteger n = min; n < c2; ++n)
			{
				NSString* itemContext = [NSString stringWithFormat:@"%@[%ld] extra item", context, (long)n];
				block(itemContext, level, nil, item2[n]);
			}
		}

		else if (c2 < c1)
		{
			matches = NO;
			for (NSUInteger n = min; n < c1; ++n)
			{
				NSString* itemContext = [NSString stringWithFormat:@"%@[%ld] missing item", context, (long)n];
				block(itemContext, level, self[n], nil);
			}
		}
	}
	
	return matches;
}

- (NSString*)nameForMatching
{
	return @"array";
}

@end

@implementation NSDictionary (ECTestComparisons)

- (BOOL)matches:(id)item2 context:(NSString*)context level:(NSUInteger)level options:(ECTestComparisonOptions)options block:(ECTestComparisonBlock)block
{
	BOOL matches = [item2 isKindOfClass:[NSDictionary class]];
	if (!matches)
	{
		NSString* newContext = [NSString stringWithFormat:@"%@ %@ compared with %@", context, [self nameForMatching], [item2 nameForMatching]];
		block(newContext, level, self, item2);
	}
	else
	{
		NSDictionary* dictionary2 = item2;
		NSMutableArray* keys2 = [NSMutableArray arrayWithArray:[dictionary2 allKeys]];
		for (NSString* key in self)
		{
			id v1 = self[key];
			id v2 = item2[key];
			if (v2)
			{
				NSString* itemContext = [NSString stringWithFormat:@"%@[@\"%@\"]", context, key];
				matches = [v1 matches:v2 context:itemContext level:level + 1 options:options block:block] && matches;
			}
			else
			{
				NSString* itemContext = [NSString stringWithFormat:@"%@[@\"%@\"] missing key %@", context, key, key];
				block(itemContext, level, v1, nil);
				matches = NO;
			}
			[keys2 removeObject:key];
		}
		
		for (NSString* key in keys2)
		{
			NSString* itemContext = [NSString stringWithFormat:@"%@[@\"%@\"] extra key %@", context, key, key];
			block(itemContext, level, nil, item2[key]);
			matches = NO;
		}
	}
	
	return matches;
}

- (NSString*)nameForMatching
{
	return @"dictionary";
}

@end

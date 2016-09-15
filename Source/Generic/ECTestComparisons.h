// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

// Property list, dictionary, etc. test comparison options
typedef NS_OPTIONS(NSUInteger, ECTestComparisonOptions)
{
	ECTestComparisonNone = 0,
	
	// If this option is set then any NSNumber double values will be compared with a fudge factor.
	ECTestComparisonDoubleFuzzy = 0x0001
};

typedef void (^ECTestComparisonBlock)(NSString* context, NSUInteger level, id item1, id item2);

@interface NSObject (ECTestComparisons)

/// Is item2 equal to the current object with option for a fuzzy compare of double values
- (BOOL)matches:(id)item2 options:(ECTestComparisonOptions)options block:(ECTestComparisonBlock)block;

/// Is item2 equal to the current object with option for a fuzzy compare of double values and a string context for differences to be reported.
- (BOOL)matches:(id)item2 context:(NSString*)context level:(NSUInteger)level options:(ECTestComparisonOptions)options block:(ECTestComparisonBlock)block;

- (NSString*)nameForMatching;
@end

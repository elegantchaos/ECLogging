// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ECTestComparisonDoubleType)
{
	ECTestComparisonDoubleExact,
	ECTestComparisonDoubleFuzzy
};

typedef void (^ECTestComparisonBlock)(NSString* context, NSUInteger level, id item1, id item2);

@interface NSObject (ECTestComparisons)
- (BOOL)matches:(id)item2 options:(ECTestComparisonDoubleType)options block:(ECTestComparisonBlock)block;
- (BOOL)matches:(id)item2 context:(NSString*)context level:(NSUInteger)level options:(ECTestComparisonDoubleType)options block:(ECTestComparisonBlock)block;
- (NSString*)nameForMatching;
@end

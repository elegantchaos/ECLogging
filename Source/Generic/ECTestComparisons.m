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
	BOOL matches = [self isEqual:item2];
	if (!matches)
		block(self, item2);
	
	return matches;
}

@end
//
//  ECTestComparisons.h
//  ECLogging
//
//  Created by Sam Deane on 21/11/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ECTestComparisonBlock)(id item1, id item2);

@interface NSObject(ECTestComparisons)
- (BOOL)matches:(id)item2 block:(ECTestComparisonBlock)block;
@end


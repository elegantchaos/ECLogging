// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface ECTestPerformanceCounter : NSObject

+ (BOOL)updateWithValue:(CGFloat)average key:(NSString*)key threshold:(CGFloat)threshold;
+ (NSTimeInterval)performIterations:(NSUInteger)iterations label:(NSString*)label key:(NSString*)key block:(void (^)())block;

@end

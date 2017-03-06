// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@interface ECTestPerformanceCounter : NSObject

+ (BOOL)updateWithValue:(CGFloat)average key:(NSString*)key threshold:(CGFloat)threshold;
+ (NSTimeInterval)performIterations:(NSUInteger)iterations label:(NSString*)label block:(void (^)())block;

@end

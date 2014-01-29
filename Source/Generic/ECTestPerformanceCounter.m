//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestPerformanceCounter.h"
#import "ECTestCase.h"

@implementation ECTestPerformanceCounter

+ (BOOL)updateWithValue:(CGFloat)average key:(NSString*)key threshold:(CGFloat)threshold
{
	BOOL result = YES;
	NSString* resultsKey = [NSString stringWithFormat:@"%@Results", key];
	NSString* totalKey = [NSString stringWithFormat:@"%@Total", key];
	
	// load the previous results from the user defaults
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSArray* previousResults = [defaults objectForKey:resultsKey];
	CGFloat previousTotal = [defaults doubleForKey:totalKey];
	if (previousResults) {
		NSUInteger runs = [previousResults count];
		CGFloat previousAverage = previousTotal / runs;
		// has the performance got worse by more than 10%?
		if (average > (previousAverage * 1.1)) {
			result = NO;
			NSLog(@"Performance %lfs was at least %lf times worse than the previous average %lfs", average, threshold, previousAverage);
		}
	} else {
		previousResults = @[];
		previousTotal = 0;
	}
	
	// record results
	[defaults setObject:[previousResults arrayByAddingObject:@(average)] forKey:resultsKey];
	[defaults setDouble:previousTotal + average forKey:totalKey];
	
	return result;
}

+ (NSTimeInterval)performIterations:(NSUInteger)iterations label:(NSString*)label key:(NSString*)key block:(void (^)())block
{
	NSTimeInterval total = 0;
	
	for (NSUInteger i = 0; i < iterations; ++i) {
		NSTimeInterval before = [NSDate timeIntervalSinceReferenceDate];
		block();
		NSTimeInterval after = [NSDate timeIntervalSinceReferenceDate];
		NSTimeInterval difference = after-before;
		NSLog(@"%@ #%ld took %fs", label, i + 1, difference);
		total += difference;
	}
	
	NSTimeInterval average = total / iterations;
	return average;
}

@end

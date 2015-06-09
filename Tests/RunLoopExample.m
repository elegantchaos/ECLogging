// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------



#import <ECUnitTests/ECUnitTests.h>

@interface RunLoopExample : ECTestCase
@end

@implementation RunLoopExample

#pragma mark - Tests

// --------------------------------------------------------------------------
//! This is an example of a test that does something which requires
//! the run loop.
//! We schedule a block on a timer, then wait until it has run.
// --------------------------------------------------------------------------

- (void)testTimer
{
	__block BOOL timerRan = NO;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self timeToExitRunLoop];
		timerRan = YES;
	});
	
	[self runUntilTimeToExit];
	ECTestAssertTrue(timerRan);
}

@end

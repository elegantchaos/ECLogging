// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------


@interface RunLoopExample : ECTestCase
@end

@implementation RunLoopExample

#pragma mark - Tests

// --------------------------------------------------------------------------
//! This is an example of a test that does something which requires
//! the run loop.
//! We schedule a block on a background queue, then wait until it has run.
// --------------------------------------------------------------------------

- (void)testTimer
{
	__block BOOL asyncBlockRan = NO;
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
		[self timeToExitRunLoop];
		asyncBlockRan = YES;
	});

	[self runUntilTimeToExit];
	ECTestAssertTrue(asyncBlockRan);
}

@end

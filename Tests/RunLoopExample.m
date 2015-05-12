// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------



#import <ECUnitTests/ECUnitTests.h>

@interface RunLoopExample : ECTestCase
@property (strong, nonatomic) NSMutableData* data;
@end

@implementation RunLoopExample

#pragma mark - Tests

// --------------------------------------------------------------------------
//! This is an example of a test that does something which requires
//! the run loop.
//! We fetch a web page using NSURLConnection, and wait
//! for it to load.
//! NSURLConnection works asynchronously and relies the run
//! loop for calling its delegate methods.
// --------------------------------------------------------------------------

- (void)testLoadPage
{
	// set up the connection
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.elegantchaos.com"]];
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection)
	{
		// make some data to store the results in
		self.data = [NSMutableData data];

		// run the runloop until - the delegate methods will cause this to exit once we've had a result
		[self runUntilTimeToExit];

		// test to see if we got something back
		ECTestAssertNotNil(self.data);
		ECTestAssertIntegerIsGreater([self.data length], 0);
	}
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	// reset the data when we get a response
	NSLog(@"got response");
	[self.data setLength:0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)dataIn
{
	// store the received data
	NSLog(@"got data");
	[self.data appendData:dataIn];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	NSLog(@"failed with error %@ %@", [error localizedDescription], [error userInfo][NSURLErrorFailingURLStringErrorKey]);

	// failed - signal that we want to exit the run loop
	[self timeToExitRunLoop];
	self.data = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	// done - signal that we want to exit the run loop
	NSLog(@"finished loading");
	[self timeToExitRunLoop];
}

@end

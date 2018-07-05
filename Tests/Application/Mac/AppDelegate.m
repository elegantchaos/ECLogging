// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "AppDelegate.h"

@interface AppDelegate()
@property (strong, nonatomic) ECLogManagerMacUISupport* logSupport;
@end

@implementation AppDelegate

#pragma mark - Channels

// these get used in Debug only
ECDefineDebugChannel(ObjectChannel);

// these channels get used in Debug and Release
ECDefineLogChannel(TestChannel);
ECDefineLogChannel(OtherChannel);

#pragma mark - Properties

#pragma mark - Application Lifecycle

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	ECLogManager* lm = [ECLogManager sharedInstance];
	ECLogManagerMacUISupport* logSupport = [ECLogManagerMacUISupport new];
	lm.delegate = logSupport;
	self.logSupport = logSupport;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (void)applicationWillHide:(NSNotification *)notification
{
}

- (void)applicationDidHide:(NSNotification *)notification
{
}

- (void)applicationWillUnhide:(NSNotification *)notification
{
}

- (void)applicationDidUnhide:(NSNotification *)notification
{
}

- (void)applicationWillBecomeActive:(NSNotification *)notification

{
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
}

- (void)applicationWillResignActive:(NSNotification *)notification
{

	// save current log channels state
	[[ECLogManager sharedInstance] saveChannelSettings];
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
}

- (void)applicationWillUpdate:(NSNotification *)notification
{
}

- (void)applicationDidUpdate:(NSNotification *)notification
{
}

- (void)applicationWillTerminate:(NSNotification *)notification
{

	[[ECLogManager sharedInstance] shutdown];
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification
{
}

#pragma mark - Actions

- (IBAction)clickedLogToTestChannel:(id)sender
{
	ECLog(TestChannel, @"This message is being logged to the test channel");
}

- (IBAction)clickedLogToOtherChannel:(id)sender
{
	ECLog(OtherChannel, @"This message is being logged to the other channel");
}

- (IBAction)clickedTestError:(id)sender
{
	NSError* error = [NSError errorWithDomain:@"Test Error" code:123 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Test Error Description", NSLocalizedDescriptionKey, nil]];
	[ECErrorReporter reportError:error message:@"Test Message"];
}

- (IBAction)clickedTestAssertion:(id)sender
{
	ECAssert(1 < 0);
}

- (IBAction)clickedRevealLogFiles:(id)sender
{
	NSError* error = nil;
	NSFileManager* fm = [NSFileManager defaultManager];
	NSURL* libraryFolder = [fm URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
	NSURL* logsFolder = [libraryFolder URLByAppendingPathComponent:@"Logs"];
	NSURL* logFolder = [logsFolder URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];

	[[NSWorkspace sharedWorkspace] selectFile:[logFolder path] inFileViewerRootedAtPath:@""];
}




@end

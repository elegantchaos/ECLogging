//
//  AppDelegate.m
//  ECLoggingSampleMac
//
//  Created by Sam Deane on 29/09/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ECLogManager.h"
#import "ECLogHandlerNSLog.h"
#import "ECLogHandlerFile.h"
#import "ECLogHandlerStdout.h"
#import "ECLogHandlerStderr.h"
#import "ECLogHandlerASL.h"
#import "ECErrorReporter.h"
#import "ECErrorPresenterHandler.h"

@implementation AppDelegate

#pragma mark - Channels

ECDefineDebugChannel(ApplicationChannel);
ECDefineDebugChannel(ApplicationUpdateChannel);
ECDefineDebugChannel(ObjectChannel);
ECDefineDebugChannel(TestChannel);
ECDefineDebugChannel(OtherChannel);

#pragma mark - Properties

@synthesize window = _window;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - Application Lifecycle

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    // initialise log manager
    [ECLogManager startupWithHandlerNames:@"ECLogHandlerNSLog", @"ECLogHandlerFile", @"ECLogHandlerStdout", @"ECLogHandlerStderr", @"ECLogHandlerASL", @"ECErrorPresenterHandler", nil];

    ECDebug(ApplicationChannel, @"will finish launching");

    // example of logging a non-string object
    ECDebug(ObjectChannel, self);
    ECDebug(ObjectChannel, [NSImage imageNamed:NSImageNameActionTemplate]);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ECDebug(ApplicationChannel, @"did finish launching");
}

- (void)applicationWillHide:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"will hide");
}

- (void)applicationDidHide:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"did hide");
}

- (void)applicationWillUnhide:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"will unhide");
}

- (void)applicationDidUnhide:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"did unhide");
}

- (void)applicationWillBecomeActive:(NSNotification *)notification

{
    ECDebug(ApplicationChannel, @"will become active");
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"did become active");
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"will resign active");
    
    // save current log channels state
    [[ECLogManager sharedInstance] saveChannelSettings];
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"did resign active");
}

- (void)applicationWillUpdate:(NSNotification *)notification
{
    ECDebug(ApplicationUpdateChannel, @"will update");
}

- (void)applicationDidUpdate:(NSNotification *)notification
{
    ECDebug(ApplicationUpdateChannel, @"did update");
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"will terminate");
    
    [[ECLogManager sharedInstance] shutdown];
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification
{
    ECDebug(ApplicationChannel, @"did change screen parameters");
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
    
}

- (IBAction)clickedRevealLogFiles:(id)sender
{
    NSError* error = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* libraryFolder = [fm URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    NSURL* logsFolder = [libraryFolder URLByAppendingPathComponent:@"Logs"];
    NSURL* logFolder = [logsFolder URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];

    [[NSWorkspace sharedWorkspace] selectFile:[logFolder path] inFileViewerRootedAtPath:nil];
}




@end

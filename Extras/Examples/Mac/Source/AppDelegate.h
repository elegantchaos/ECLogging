//
//  AppDelegate.h
//  ECLoggingSampleMac
//
//  Created by Sam Deane on 29/09/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction)clickedLogToTestChannel:(id)sender;
- (IBAction)clickedLogToOtherChannel:(id)sender;
- (IBAction)clickedTestError:(id)sender;
- (IBAction)clickedTestAssertion:(id)sender;
- (IBAction)clickedRevealLogFiles:(id)sender;

@end

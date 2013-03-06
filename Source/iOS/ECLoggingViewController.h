// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class ECLogViewController;

@interface ECLoggingViewController : UIViewController

@property (strong, nonatomic) IBOutlet ECLogViewController* logView;

- (IBAction)tappedShowDebugView:(id)sender;
- (IBAction)tappedTestOutput:(id)sender;

@end

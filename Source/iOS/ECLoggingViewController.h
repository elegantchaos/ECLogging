// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class ECLogTranscriptViewController;
@class ECLoggingSettingsViewController;

typedef void (^ECLoggingSettingsViewControllerDoneBlock) ();

@interface ECLoggingViewController : UIViewController

@property (strong, nonatomic) IBOutlet ECLoggingSettingsViewController* oSettingsController;
@property (strong, nonatomic) IBOutlet ECLogTranscriptViewController* oTranscriptController;

- (void)showInController:(UIViewController*)controller doneBlock:(ECLoggingSettingsViewControllerDoneBlock)doneBlock;

@end

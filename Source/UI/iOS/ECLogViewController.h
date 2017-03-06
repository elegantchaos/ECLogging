// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class ECLogTranscriptViewController;
@class ECLogSettingsViewController;

typedef void (^ECLoggingSettingsViewControllerDoneBlock) ();

@interface ECLogViewController : UIViewController

@property (strong, nonatomic) IBOutlet ECLogSettingsViewController* oSettingsController;
@property (strong, nonatomic) IBOutlet ECLogTranscriptViewController* oTranscriptController;

- (void)showInController:(UIViewController*)controller doneBlock:(ECLoggingSettingsViewControllerDoneBlock)doneBlock;

@end

// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class ECLogManager;

@interface ECOptionsMenu : NSMenu

- (void)setupAsRootMenu;

- (IBAction)optionSelected:(id)sender;

@end

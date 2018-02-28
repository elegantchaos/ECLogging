// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDebugMenu.h"

@class ECLogManager;

/**
 A utility menu which lists configuration options.
 
 The options to show are read from the ECLogging/ECLoggingDebug.plist file.

 The values are read from the NSUserDefaults system.

 */

@interface ECOptionsMenu : ECDebugMenu

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (void)setupAsRootMenu;

- (IBAction)optionSelected:(id)sender;

@end

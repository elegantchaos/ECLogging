// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDebugMenu.h"

@class ECLogManager;

/**
 A utility menu containing various items for configuration of the logging system.
 
 If you place one of these in your menu in MainMenu.xib, it will automatically populate a Debug menu with lots of options that let you control your channels.

 Note that the menu is only intended for use with debug builds - in fact it automatically removes itself from release builds.
 
 ![Mac debug ui](Screenshots/mac%20debug%20menu.png)

 The [sample application](https://github.com/elegantchaos/ECLoggingExamples) illustrates how to use this class.

 */

@interface ECLoggingMenu : ECDebugMenu

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (IBAction)channelSelected:(id)sender;

@end

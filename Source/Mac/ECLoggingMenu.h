// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDebugMenu.h"

@class ECLogManager;

/**
 * A utility menu containing various items for configuration of the logging system.
 *
 * Note that the menu is only intended for use with debug builds - in fact it automatically
 * removes itself from release builds.
 */

@interface ECLoggingMenu : ECDebugMenu
{
    ECLogManager* mLogManager;
}

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (IBAction) channelSelected: (id) sender;

@end

// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

/**
 * A menu subclass that you can use to house debug related items, including
 * an instance of ECLoggingMenu.
 *
 * The menu automatically removes itself (and everything it contains) from release
 * builds, so that you don't have to maintain separate MainMenu.xib files for debug and release.
 */

@interface ECDebugMenu : NSMenu

@end

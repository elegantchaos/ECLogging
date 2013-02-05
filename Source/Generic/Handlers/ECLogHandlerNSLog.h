// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandler.h"

/**
 * Handler which logs to the console using NSLog calls.
 *
 * If you don't add an ECLogging.plist file to the application, this log handler will 
 * automatically be registered and will be set as the default.
 */

@interface ECLogHandlerNSLog : ECLogHandler 
{

}

- (void) logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context;

@end

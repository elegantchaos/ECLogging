// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandler.h"

EC_ASSUME_NONNULL_BEGIN

/**
 * Handler which logs via ASL.
 */

@interface ECLogHandlerASL : ECLogHandler 
{

}

- (void) logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context;

@end

EC_ASSUME_NONNULL_END

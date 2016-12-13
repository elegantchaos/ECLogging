// --------------------------------------------------------------------------
//  Copyright 2016 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandler.h"

/**
 * Handler which logs to a mutable string.
 *
 * Each logged message is appended to the string on a new line (messages that
 * span multiple lines are logged unmodified, so you can't necessarily rely
 * on there being a one-to-one mapping between lines and messages.
 *
 * Contextual information for a message (such as the file that generated it) is
 * appended to the end of the line, inside « and » characters.
 *
 *
 */

@interface ECLogHandlerString : ECLogHandler

@property (strong, nonatomic, readonly) NSMutableString* buffer;

- (void) logFromChannel:(ECLogChannel*)channel withObject:(id)format arguments:(va_list)arguments context:(ECLogContext *)context;

@end

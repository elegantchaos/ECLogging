// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

/**
 A log handler which displays an alert with a message, details of the place that the log came from, and
 some buttons to allow the user to contine, break, or abort.
 
 This is intended to be used with the Assertion channel, but could be used for other channels too.
 */

@interface ECAssertionHandler : ECLogHandler

@end

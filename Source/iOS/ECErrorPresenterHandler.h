// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandler.h"

//! Log handler which presents the logged object as an error using [NSApplication presentError:]
//! If it's not sent an actual error to log, it makes one from the default string value of whatever it was sent.

extern NSString *const ECLoggingErrorDomain;
extern const NSInteger ECLoggingUnknownError;

@interface ECErrorPresenterHandler : ECLogHandler

@end

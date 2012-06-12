//
//  ECErrorPresenterHandler.h
//  ECLogging
//
//  Created by Sam Deane on 10/04/2012.
//  Copyright (c) 2012 Elegant Chaos. All rights reserved.
//

#import "ECLogHandler.h"

//! Log handler which presents the logged object as an error using [NSApplication presentError:]
//! If it's not sent an actual error to log, it makes one from the default string value of whatever it was sent.

extern NSString *const ECLoggingErrorDomain;
extern const NSInteger ECLoggingUnknownError;

@interface ECErrorPresenterHandler : ECLogHandler

@end

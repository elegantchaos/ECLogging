// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandler.h"

@class ECLogViewController;

/** 
 * Handler which stores up log items for display by an ECLogView.
 *
 * Each time a message is logged to the handler, it adds it to its
 * stored items, and posts a notification so that any visible log views
 * can update themselves.
 *
 * By default this handler keeps a copy of every log message sent to it,
 * so it has potential memory implications.
 *
 */

@interface ECLogViewHandler : ECLogHandler

@property (strong, nonatomic) NSMutableArray* items;

@end

extern NSString *const LogItemsUpdated;

//
//  ECLogViewHandler.h
//  ECLoggingSample
//
//  Created by Sam Deane on 02/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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

@property (nonatomic, retain) NSMutableArray* items;

@end

extern NSString *const LogItemsUpdated;

// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@class ECLogChannel;

@interface ECLogViewHandlerItem : NSObject

@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* context;

@end

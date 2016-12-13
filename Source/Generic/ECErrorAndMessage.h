// --------------------------------------------------------------------------
//  Copyright 2016 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@interface ECErrorAndMessage : NSObject

@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSError* error;

@end

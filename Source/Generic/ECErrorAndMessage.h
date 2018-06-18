// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

EC_ASSUME_NONNULL_BEGIN

@interface ECErrorAndMessage : NSObject

@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSError* error;

@end

EC_ASSUME_NONNULL_END

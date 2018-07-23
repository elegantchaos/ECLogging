// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ECLogManager : NSObject
@property (strong, nonatomic, readonly) NSDictionary* options;

+ (ECLogManager*)sharedInstance;

@end

NS_ASSUME_NONNULL_END

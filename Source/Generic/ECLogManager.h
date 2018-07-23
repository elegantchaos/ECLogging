// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

NS_ASSUME_NONNULL_BEGIN

@class ECLogChannel;
@class ECLogHandler;
@class ECLogManager;

@protocol ECLogManagerDelegate <NSObject>
@optional
- (void)logManagerDidStartup:(ECLogManager*)manager;
- (void)showUIForLogManager:(ECLogManager*)manager;
@end


@interface ECLogManager : NSObject


+ (ECLogManager*)sharedInstance;


@property (strong, nonatomic, readonly) NSDictionary* options;

@property (weak, nonatomic) id<ECLogManagerDelegate> delegate;

- (void)showUI;

@end

NS_ASSUME_NONNULL_END

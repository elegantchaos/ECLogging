// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ECLogging)

- (NSString*)stringBySplittingMixedCaps;
- (NSArray*)componentsSeparatedByMixedCaps;
- (NSString*)lastLines:(NSUInteger)count;
- (NSString*)firstLines:(NSUInteger)count;
- (BOOL)matchesString:(NSString*)string divergingAfter:(NSString* _Nonnull * _Nonnull)prefix atIndex:(NSUInteger*)index divergentChar:(UniChar*)divergentChar expectedChar:(UniChar*)expectedChar;
- (BOOL)matchesString:(NSString*)string divergingAtLine:(NSUInteger*)divergingLine after:(NSString* _Nonnull * _Nonnull)after diverged:(NSString* _Nonnull * _Nonnull)diverged expected:(NSString* _Nonnull * _Nonnull)expected;
- (BOOL)matchesString:(NSString*)string divergingAtLine1:(NSUInteger*)line1 andLine2:(NSUInteger*)line2 diverged:(NSString* _Nonnull * _Nonnull)diverged expected:(NSString* _Nonnull * _Nonnull)expected;
- (BOOL)matchesString:(NSString*)string divergingAtLine1:(NSUInteger*)line1 andLine2:(NSUInteger*)line2 diverged:(NSString* _Nonnull * _Nonnull)diverged expected:(NSString* _Nonnull * _Nonnull)expected window:(NSInteger)window;

@end

NS_ASSUME_NONNULL_END

// --------------------------------------------------------------------------
//
//  Created by Sam Deane on 11/08/2010.
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>


@interface NSString(ECLogging)

- (NSString*)stringBySplittingMixedCaps;
- (NSArray*)componentsSeparatedByMixedCaps;
- (NSString*)lastLines:(NSUInteger)count;
- (NSString*)firstLines:(NSUInteger)count;
- (BOOL)matchesString:(NSString*)string divergingAfter:(NSString**)prefix atIndex:(NSUInteger*)index divergentChar:(UniChar*)divergentChar expectedChar:(UniChar*)expectedChar;
- (BOOL)matchesString:(NSString *)string divergingAtLine:(NSUInteger*)divergingLine after:(NSString**)after diverged:(NSString**)diverged expected:(NSString**)expected;
- (BOOL)matchesString:(NSString *)string divergingAtLine1:(NSUInteger*)line1 andLine2:(NSUInteger*)line2 diverged:(NSString**)diverged expected:(NSString**)expected;

@end

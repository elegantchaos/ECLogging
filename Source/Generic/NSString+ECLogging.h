// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ECLogging)

/**
 Returns a string which inserts spaces into mixed caps text to make it read as individual words.
 
 For example: "mixedCapTest" is returned as "mixed Cap Test".

 */

- (NSString*)stringBySplittingMixedCaps;

/**
 Returns an array of sub-strings, spltting by mixed caps.
 */

- (NSArray*)componentsSeparatedByMixedCaps;

/**
 Return the last n lines of the string.
 */

- (NSString*)lastLines:(NSUInteger)count;

/**
 Return the first n lines of the string.
 */

- (NSString*)firstLines:(NSUInteger)count;

/**
 Check that two strings match. If they don't, return some information about the point where they diverged:
 - the text preceding the divergence
 - the index of the first divergent character
 - the first divergent character
 - the character that was expected
 
 @discussion For ruggedness, we allow nil to be passed in as the string to test. It is treated as the empty string for the purposes of comparison.
 */

- (BOOL)matchesString:(nullable NSString*)string divergingAfter:(NSString* _Nonnull * _Nonnull)prefix atIndex:(NSUInteger*)index divergentChar:(UniChar*)divergentChar expectedChar:(UniChar*)expectedChar;

/**
 Check that two strings match. If they don't, return some information about the point where they diverged:
 - the line number they diverged at
 - the text preceding the divergence
 - the divergent remainder of the line
 - the expected remainder of the line

 @discussion For ruggedness, we allow nil to be passed in as the string to test. It is treated as the empty string for the purposes of comparison.
 */

- (BOOL)matchesString:(nullable NSString*)string divergingAtLine:(NSUInteger*)divergingLine after:(NSString* _Nonnull * _Nonnull)after diverged:(NSString* _Nonnull * _Nonnull)diverged expected:(NSString* _Nonnull * _Nonnull)expected;

/**
 Check that two strings match, ignoring extra lines in either string that only consist of whitespace.
 
 If they don't, match, return some information about the point where they diverged:
 - the line numbers in both strings that they diverged at
 - the divergent text within +/- 5 lines of the divergence
 - the expected text within +/- 5 lines of the divergence

 @discussion For ruggedness, we allow nil to be passed in as the string to test. It is treated as the empty string for the purposes of comparison.
 */

- (BOOL)matchesString:(nullable NSString*)string divergingAtLine1:(NSUInteger*)line1 andLine2:(NSUInteger*)line2 diverged:(NSString* _Nonnull * _Nonnull)diverged expected:(NSString* _Nonnull * _Nonnull)expected;

/**
 Check that two strings match, ignoring extra lines in either string that only consist of whitespace.

 If they don't, match, return some information about the point where they diverged:
 - the line numbers in both strings that they diverged at
 - the divergent text within the specified window of the divergence
 - the expected text within the specified window of the divergence

 @discussion For ruggedness, we allow nil to be passed in as the string to test. It is treated as the empty string for the purposes of comparison.
 */

- (BOOL)matchesString:(nullable NSString*)string divergingAtLine1:(NSUInteger*)line1 andLine2:(NSUInteger*)line2 diverged:(NSString* _Nonnull * _Nonnull)diverged expected:(NSString* _Nonnull * _Nonnull)expected window:(NSInteger)window;

@end

NS_ASSUME_NONNULL_END

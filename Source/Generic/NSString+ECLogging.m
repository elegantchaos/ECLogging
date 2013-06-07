// --------------------------------------------------------------------------
//
//  Created by Sam Deane on 11/08/2010.
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "NSString+ECLogging.h"

@implementation NSString(ECCore)


- (NSArray*)componentsSeparatedByMixedCaps
{
	NSMutableArray* result = [NSMutableArray array];
	NSUInteger count = [self length];
	NSMutableString* word = [[NSMutableString alloc] init];
	BOOL wasLower = NO;
	for (NSUInteger n = 0; n < count; ++n)
	{
		UniChar c = [self characterAtIndex: n];
		BOOL isLower = islower(c) != 0;
		if (wasLower && !isLower)
		{
			[result addObject:[NSString stringWithString:word]];
			[word deleteCharactersInRange:NSMakeRange(0, [word length])];
		}
		[word appendString:[NSString stringWithCharacters: &c length:1]];
		wasLower = isLower;
	}
	if ([word length])
	{
		[result addObject:word];
	}
	[word release];
	
	return result;
}


- (NSString*) stringBySplittingMixedCaps
{
	NSUInteger count = [self length];
	NSMutableString* result = [[NSMutableString alloc] init];
	BOOL wasLower = NO;
	for (NSUInteger n = 0; n < count; ++n)
	{
		UniChar c = [self characterAtIndex: n];
		BOOL isLower = islower(c) != 0;
		if (wasLower && !isLower)
		{
			[result appendString: @" "];
		}
		[result appendString: [NSString stringWithCharacters: &c length:1]];
		wasLower = isLower;
	}
	
	return [result autorelease];
}

- (NSString*)lastLines:(NSUInteger)count
{
    NSArray* lines = [self componentsSeparatedByString:@"\n"];
    NSUInteger lineCount = [lines count];
    NSUInteger n = MIN(lineCount, count);

    NSArray* linesToReturn = [lines subarrayWithRange:NSMakeRange(lineCount - n, n)];
    return [linesToReturn componentsJoinedByString:@"\n"];
}

- (NSString*)firstLines:(NSUInteger)count
{
    NSArray* lines = [self componentsSeparatedByString:@"\n"];
    NSUInteger lineCount = [lines count];
    NSUInteger n = MIN(lineCount, count);

    NSArray* linesToReturn = [lines subarrayWithRange:NSMakeRange(0, n)];
    return [linesToReturn componentsJoinedByString:@"\n"];
}

- (BOOL)matchesString:(NSString*)string divergingAfter:(NSString**)prefix atIndex:(NSUInteger*)index divergentChar:(UniChar*)divergentChar expectedChar:(UniChar*)expectedChar
{
	BOOL result = [self isEqualToString:string];
    if (!result)
    {
		*prefix = [self commonPrefixWithString:string options:0];
        *index = [*prefix length];
        *divergentChar = [self characterAtIndex:*index];
        *expectedChar = [string characterAtIndex:*index];
    }

	return result;
}

- (BOOL)matchesString:(NSString *)string divergingAtLine:(NSUInteger*)divergingLine after:(NSString**)after diverged:(NSString**)diverged expected:(NSString**)expected
{
	BOOL result = [self isEqualToString:string];
    if (!result)
	{
		NSString* common = [self commonPrefixWithString:string options:0];
		*divergingLine = [[common componentsSeparatedByString:@"\n"] count];
		*after = [common lastLines:2];
		*diverged = [[self substringFromIndex:[common length]] firstLines:2];
		*expected = [[string substringFromIndex:[common length]] firstLines:2];
	}

	return result;
}

- (BOOL)matchesString:(NSString *)string divergingAtLine1:(NSUInteger*)line1 andLine2:(NSUInteger*)line2 diverged:(NSString**)diverged expected:(NSString**)expected
{
	BOOL result = [self isEqualToString:string];
    if (!result)
	{
		*line1 = *line2 = 0;
		*diverged = *expected = @"";
		NSCharacterSet* ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		NSArray* lines1 = [self componentsSeparatedByString:@"\n"];
		NSArray* lines2 = [string componentsSeparatedByString:@"\n"];
		NSUInteger count1 = [lines1 count];
		NSUInteger count2 = [lines2 count];
		NSUInteger n1 = 0;
		NSUInteger n2 = 0;
		while ((n1 < count1) && (n2 < count2))
		{
			NSString* trimmed1 = [lines1[n1] stringByTrimmingCharactersInSet:ws];
			NSString* trimmed2 = [lines2[n2] stringByTrimmingCharactersInSet:ws];
			if ([trimmed1 isEqualToString:trimmed2])
			{
				++n1;
				++n2;
			}
			else if ([trimmed1 length] == 0)
			{
				++n1;
			}
			else if ([trimmed2 length] == 0)
			{
				++n2;
			}
			else
			{
				*line1 = n1;
				*line2 = n2;
				*expected = trimmed2;
				*diverged = trimmed1;
				break;
			}
		}
	}

	return result;
}

@end

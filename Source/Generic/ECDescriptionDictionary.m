// --------------------------------------------------------------------------
//
//  Created by Sam Deane on 11/08/2010.
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDescriptionDictionary.h"

@implementation NSObject(DescriptionDictionary)

- (id)descriptionDictionary
{
	return [self description];
}

@end

@implementation NSArray(DescriptionDictionary)

- (id)descriptionDictionary
{
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self count]];
	for (id item in self)
		[result addObject:[item descriptionDictionary]];

	return result;
}

@end

@implementation NSDictionary(DescriptionDictionary)

- (id)descriptionDictionary
{
	NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	for (NSString* key in self)
		result[key] = [self[key] descriptionDictionary];

	return result;
}

@end

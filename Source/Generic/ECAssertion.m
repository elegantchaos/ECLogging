// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#include "ECAssertion.h"
#include "ECLogChannel.h"
#include "ECLoggingMacros.h"

ECDefineLogChannel(AssertionChannel);

@implementation ECAssertion

+ (id)assertObject:(id)object isOfClass:(Class)c
{
	ECAssert((object == nil) || [object isKindOfClass:c]);

	return object;
}

@end

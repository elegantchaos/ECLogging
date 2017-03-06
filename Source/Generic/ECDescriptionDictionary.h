// --------------------------------------------------------------------------
//
//  Created by Sam Deane on 11/08/2010.
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

/**
 Variant of description, which maintains some structure.
 Called on a normal object, it returns the same as description.
 Called on an NSDictionary it returns a dictionary containing the result of descriptionDictionary for each key.
 Called on an NSArray it returns an array containing the result of descriptionDictionary for each item.

 It lets you get a structured description of a collection which you can then compare with another, without worrying
 about the order that the keys appear in.
 */

@interface NSObject (DescriptionDictionary)
- (id)descriptionDictionary;
@end

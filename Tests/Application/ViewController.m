// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	ECLogManager* lm = [ECLogManager sharedInstance];
	NSString* debugText = [NSString stringWithFormat:@"Debug %@. ", lm.debugChannelsAreEnabled ? @"enabled" : @"disabled"];
	NSString* assertionsText = [NSString stringWithFormat:@"Assertions %@. ", lm.assertionsAreEnabled ? @"enabled" : @"disabled"];
	self.status.stringValue = [assertionsText stringByAppendingString:debugText];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

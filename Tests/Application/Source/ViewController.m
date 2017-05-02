//
//  ViewController.m
//  ECLoggingMacAppTest
//
//  Created by Sam Deane on 02/05/2017.
//  Copyright © 2017 Elegant Chaos. All rights reserved.
//

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

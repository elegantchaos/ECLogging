// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@class ECLogSettingsViewController;

@interface ECDebugHandlersViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray* handlers;
@property (strong, nonatomic) ECLogSettingsViewController* settingsViewController;

@end

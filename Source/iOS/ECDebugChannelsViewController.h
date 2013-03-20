// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@class ECLoggingSettingsViewController;

@interface ECDebugChannelsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> 

@property (strong, nonatomic) NSArray* channels;
@property (strong, nonatomic) ECLoggingSettingsViewController* debugViewController;

@end

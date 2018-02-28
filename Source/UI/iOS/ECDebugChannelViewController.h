// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@class ECLogChannel;

@interface ECDebugChannelViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) ECLogChannel* channel;

@end

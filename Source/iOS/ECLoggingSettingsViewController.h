// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

/**
 This class provides support for configuring ECLogging from within your application.
 
 If you push one of these onto a navigation controller, or show one modally, it will show an interface that lets you control your channels.

 ![iOS debug view](Screenshots/ios%20debug%20view.png)
 - ![iOS channels list view](Screenshots/ios%20channels%20view.png)
 - ![iOS channel configuration view](Screenshots/ios%20channel%20view.png)

 The [sample application](https://github.com/elegantchaos/ECLoggingExamples) illustrates how to use this class.
 */

@interface ECLoggingSettingsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UINavigationController* navController;

- (void)pushViewController:(UIViewController*)controller;

@end

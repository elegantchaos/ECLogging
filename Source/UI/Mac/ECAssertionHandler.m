//  Created by Sam Deane on 03/05/2017.
//  Copyright © 2017 Elegant Chaos. All rights reserved.
//

#import "ECAssertionHandler.h"

@import AppKit;

@implementation ECAssertionHandler

// --------------------------------------------------------------------------
//! Initialise.
// --------------------------------------------------------------------------

- (id)init
{
	if ((self = [super init]) != nil)
	{
		self.name = @"Assertion";
	}

	return self;
}

#pragma mark - Logging

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context
{
	// has this alert been suppressed?
	ECLogManager* lm = [ECLogManager sharedInstance];
	NSString* assertionKey = [NSString stringWithFormat:@"%s%s%u", context->function, context->file, context->line];
	if (![lm isAssertionSuppressedForKey:assertionKey]) {
		NSString* message;
		if ([object isKindOfClass:[NSString class]])
		{
			NSString* format = object;
			message = [[NSString alloc] initWithFormat:format arguments:arguments];
		}
		else
		{
			message = [object description];
		}
		
		NSAlert* alert = [NSAlert new];
		alert.alertStyle = NSAlertStyleCritical;
		alert.showsSuppressionButton = YES;
		alert.messageText = [NSString stringWithFormat:@"Assertion failed: %@", message];
		alert.informativeText = [NSString stringWithFormat:@"%s\n\n%@, %u",
								 context->function,
								 [[NSString stringWithUTF8String:context->file] lastPathComponent],
								 context->line];

		NSArray* buttons = @[@"Continue", @"Pause", @"Abort"];
		for (NSString* title in buttons) {
			[alert addButtonWithTitle:title];
		}

		NSModalResponse response = [alert runModal];
		switch (response) {
			case NSAlertThirdButtonReturn:
				abort();

			case NSAlertSecondButtonReturn:
				NSLog(@"set a breakpoint here if you want this to enter the debugger");
				break;

			default:
				break;
		}

		BOOL suppressed = alert.suppressionButton.integerValue != 0;
		if (suppressed) {
			[lm suppressAssertionForKey:assertionKey];
		}
	}
}

// --------------------------------------------------------------------------
//! Called to indicate that the handler was enabled for a given channel.
//! We don't want to do the default thing here - which would have been
//! to log the information to the channel, since that would cause us
//! to display an error alert which we only want to do for actual errors.
// --------------------------------------------------------------------------

- (void)wasEnabledForChannel:(ECLogChannel*)channel
{
}

// --------------------------------------------------------------------------
//! Called to indicate that the handler was disabled for a given channel.
//! We don't want to do the default thing here - which would have been
//! to log the information to the channel, since that would cause us
//! to display an error alert which we only want to do for actual errors.
// --------------------------------------------------------------------------

- (void)wasDisabledForChannel:(ECLogChannel*)channel
{
}

//
//+ (NSAlert*)alertWithMessage:(NSString*)message info:(NSString*)info buttons:(NSArray*)buttons {
//	if (!buttons) {
//		buttons = @[BCLocalizedString(@"general.buttons.ok-title")];
//	}
//	NSAlert* alert = [NSAlert new];
//	alert.messageText = message;
//	alert.informativeText = info;
//	for (NSString* title in buttons) {
//		[alert addButtonWithTitle:title];
//	}
//
//	return alert;
//}
@end

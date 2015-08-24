// --------------------------------------------------------------------------
//
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <ECLogging/ECLogging.h>
#import <ECUnitTests/ECUnitTests.h>

ECDefineLogChannel(TestChannel);

@interface ECLogManager (PrivateTestAccessOnly)
- (void)loadChannelSettings;
- (void)processForcedChannels;
@end

@interface TestHandler : ECLogHandler
@property (strong, nonatomic) NSMutableString* logged;
@end

@implementation TestHandler

- (instancetype)init
{
	if ((self = [super init]) != nil)
	{
		self.logged = [NSMutableString new];
		self.name = @"Test Handler";
	}

	return self;
}
- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context
{
	NSString* output = [self simpleOutputStringForChannel:channel withObject:object arguments:arguments context:context];
	[self.logged appendString:output];
}
@end

@interface BasicTests : ECTestCase
@property (strong, nonatomic) TestHandler* handler; // test handler we install in order to capture output of the channel
@property (strong, nonatomic) ECLogChannel* channel; // normally we wouldn't interact with a channel object directly, but having a reference is handy for the tests
@end

@implementation BasicTests

- (void)clearLoggedOutput
{
	self.handler.logged.string = @"";
}

- (void)setUp
{
	// grab a reference to the test channel - only something we need to do for test purposes
	ECLogChannel* channel = ECGetChannel(TestChannel);
	self.channel = channel;

	// install a custom handler and make the test channel use it, so that we can capture anything that was sent to it
	TestHandler* handler = [TestHandler new];
	[channel enableHandler:handler];
	[channel enable];

	// restore the default settings for the channel - again, not something we'd have to do in normal use, but in this case previous tests might have messed with it
	channel.context = ECLogContextDefault;
	self.handler = handler;

	// enabling the handler and the channel will have produced some output, so lets clear it to prevent it interfering with the tests
	[self clearLoggedOutput];
}

- (void)tearDown
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"ECLogging"];
	[defaults removeObjectForKey:@"ECLoggingEnableChannel"];
	[defaults removeObjectForKey:@"ECLoggingDisableChannel"];
}

#pragma mark - Tests

- (void)testLogging
{
	ECLog(TestChannel, @"hello world");
	ECTestAssertStringIsEqual(self.handler.logged, @"hello world «Test»");
}

- (void)testDisabling
{
	ECDisableChannel(TestChannel);
	[self clearLoggedOutput];
	ECLog(TestChannel, @"hello world");
	ECTestAssertStringIsEqual(self.handler.logged, @"");
}

- (void)testContextFlags
{
	self.channel.context = ECLogContextNone;
	ECLog(TestChannel, @"hello world");
	ECTestAssertStringIsEqual(self.handler.logged, @"");

	[self clearLoggedOutput];
	self.channel.context = ECLogContextMessage;
	ECLog(TestChannel, @"hello world");
	ECTestAssertStringIsEqual(self.handler.logged, @"hello world");

	[self clearLoggedOutput];
	self.channel.context = ECLogContextMessage | ECLogContextName;
	ECLog(TestChannel, @"hello world");
	ECTestAssertStringIsEqual(self.handler.logged, @"hello world «Test»");

	[self clearLoggedOutput];
	self.channel.context = ECLogContextMessage | ECLogContextFunction;
	ECLog(TestChannel, @"hello world");
	ECTestAssertStringIsEqual(self.handler.logged, @"hello world «-[BasicTests testContextFlags]»");

	[self clearLoggedOutput];
	self.channel.context = ECLogContextMessage | ECLogContextName | ECLogContextFunction | ECLogContextFile | ECLogContextDate;
	ECLog(TestChannel, @"hello world");
	NSError* error;

	// line number can obviously change in the output (when we change the code!), so match with a regexp
	NSRegularExpression* exp = [NSRegularExpression regularExpressionWithPattern:@"hello world «Test BasicTests.m, \\d+ -\\[BasicTests testContextFlags\\] ... +\\d+ \\d+»" options:NSRegularExpressionCaseInsensitive error:&error];
	__block NSUInteger matches = 0;
	[exp enumerateMatchesInString:self.handler.logged options:0 range:NSMakeRange(0, [self.handler.logged length]) usingBlock:^(NSTextCheckingResult* result, NSMatchingFlags flags, BOOL* stop) {
		ECTestAssertIntegerIsEqual(result.range.location, 0);
		++matches;
	}];
	ECTestAssertIntegerIsEqual(matches, 1);
	if (matches != 1)
	{
		NSLog(@"failed with %ld matches, output was '%@'", matches, self.handler.logged);
	}
}

- (void)testForceEnableFromCommandLine
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	ECDisableChannel(TestChannel);
	[defaults setObject:@"Test" forKey:@"ECLoggingEnableChannel"];
	[[ECLogManager sharedInstance] processForcedChannels]; // TODO: this forces the log manager to re-processes the command line options, so it's a bit fragile; a better test would be to actually launch a test executable which used ECLogging
	[self clearLoggedOutput];
	ECLog(TestChannel, @"hello world");
	ECTestAssertStringIsEqual(self.handler.logged, @"hello world «Test»");
}

- (void)testForceDisableFromCommandLine
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:@"Test" forKey:@"ECLoggingDisableChannel"];
	[[ECLogManager sharedInstance] processForcedChannels]; // TODO: this forces the log manager to re-processes the command line options, so it's a bit fragile; a better test would be to actually launch a test executable which used ECLogging
	[self clearLoggedOutput];
	ECLog(TestChannel, @"hello world");
	ECTestAssertStringIsEqual(self.handler.logged, @"");
}

@end

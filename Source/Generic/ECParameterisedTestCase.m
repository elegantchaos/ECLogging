// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECParameterisedTestCase.h"
#import "ECParameterisedTestSuite.h"

#import <objc/runtime.h>


NSString* const TestItemsKey = @"ECTestItems";
NSString* const SuiteItemsKey = @"ECTestSuites";
NSString* const SettingsKey = @"settings";
NSString* const IncludesKey = @"includes";
NSString* const DataURLKey = @"ECTestSuiteDataURL";

NSString* const SuiteExtension = @"testsuite";

@interface XCTestSuite (ProbeExtensions)
- (void)removeTestsWithNames:(NSArray*)names;
@end

@implementation ECParameterisedTestCase

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
	// for a parameterised test called parameterisedTestBlah,
	// if there are two bits of test data "foo" and "bar"
	// the methods that are actually called on the tests will be parameterisedTestBlah-foo and parameterisedTestBlah-bar.
	// these methods won't actually exist, so we need to add them
	// we just want them to be aliases for parameterisedTestBlah, as they're only there to fool Xcode into reporting each
	// invocation of the test properly
	NSString* selectorName = NSStringFromSelector(sel);
	NSRange range = [selectorName rangeOfString:ParameterisedTestSeparator];
	if (range.location != NSNotFound)
	{
		NSString* shortSelectorName = [selectorName substringToIndex:range.location];
		NSString* stub = [shortSelectorName substringFromIndex:[ParameterisedTestShortPrefix length]];
		NSString* baseSelectorName = [NSString stringWithFormat:@"%@%@", ParameterisedTestMethodPrefix, stub];
		SEL baseSelector = NSSelectorFromString(baseSelectorName);
		IMP baseImplementation = [self instanceMethodForSelector:baseSelector];
		class_addMethod([self class], sel, baseImplementation, "v@:");
		return YES;
	}
	else
	{
		return [super resolveInstanceMethod:sel];
	}
}

// --------------------------------------------------------------------------
//! Build up data for an item from a folder
// --------------------------------------------------------------------------

+ (NSDictionary*)parameterisedTestDataFromItem:(NSURL*)folder settings:(NSDictionary*)settings
{
	// if there's a testdata.plist here, add values from it
	NSMutableDictionary* result = nil;
	NSFileManager* fm = [NSFileManager defaultManager];
	BOOL isDirectory;

	if ([fm fileExistsAtPath:[folder path] isDirectory:&isDirectory] && isDirectory)
	{
		result = [NSMutableDictionary dictionary];
		NSError* error = nil;
		NSArray* itemURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folder includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
		for (NSURL* item in itemURLs)
		{
			NSString* fullName = [item lastPathComponent];
			NSString* name = [fullName stringByDeletingPathExtension];
			if ([fullName isEqualToString:@"testdata.plist"])
			{
				NSDictionary* entries = [NSDictionary dictionaryWithContentsOfURL:item];
				[result addEntriesFromDictionary:entries];
			}
			else
			{
				NSStringEncoding encoding = NSUTF8StringEncoding;
				id value = [NSString stringWithContentsOfURL:item usedEncoding:&encoding error:&error];
				if (!value)
				{
					value = [NSString stringWithContentsOfURL:item encoding:NSISOLatin1StringEncoding error:&error];
				}
				if (!value)
				{
					value = item;
				}
				result[name] = value;
			}
		}

		result[DataURLKey] = folder;
	}

	if (settings)
	{
		NSMutableDictionary* temp = [NSMutableDictionary dictionaryWithDictionary:result[SettingsKey]];
		[temp addEntriesFromDictionary:settings];
		result[SettingsKey] = temp;
	}

	return result;
}

// --------------------------------------------------------------------------
//! Recurse through a directory structure building up a dictionary
//! of data items (and sub-suites) from it.
// --------------------------------------------------------------------------

+ (NSDictionary*)parameterisedTestDataFromFolder:(NSURL*)folder settings:(NSDictionary*)settings
{
	// if there's a testdata.plist here, add values from it
	NSMutableDictionary* result = nil;
	NSFileManager* fm = [NSFileManager defaultManager];
	BOOL isDirectory;

	if ([fm fileExistsAtPath:[folder path] isDirectory:&isDirectory] && isDirectory)
	{
		result = [NSMutableDictionary dictionary];
		NSError* error = nil;
		NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folder includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
		NSMutableArray* childrenURLs = [NSMutableArray array];
		NSMutableArray* itemURLs = [NSMutableArray array];
		for (NSURL* item in contents)
		{
			NSString* fullName = [item lastPathComponent];
			NSString* extension = [fullName pathExtension];
			if ([extension isEqualToString:SuiteExtension])
			{
				[childrenURLs addObject:item];
			}
			else if ([fullName isEqualToString:@"testdata.plist"])
			{
				NSDictionary* entries = [NSDictionary dictionaryWithContentsOfURL:item];
				[result addEntriesFromDictionary:entries];
				NSArray* includes = result[IncludesKey];
				if (includes)
				{
					NSURL* parent = [folder URLByDeletingLastPathComponent];
					for (NSString* include in includes)
					{
						[childrenURLs addObject:[parent URLByAppendingPathComponent:include]];
					}
				}
			}
			else
			{
				[itemURLs addObject:item];
			}
		}

		NSMutableDictionary* combinedSettings = [NSMutableDictionary dictionaryWithDictionary:result[SettingsKey]];
		[combinedSettings addEntriesFromDictionary:settings];

		NSMutableDictionary* children = [NSMutableDictionary dictionaryWithCapacity:[childrenURLs count]];
		for (NSURL* child in childrenURLs)
		{
			NSString* name = [[child lastPathComponent] stringByDeletingPathExtension];
			NSDictionary* itemData = [self parameterisedTestDataFromFolder:child settings:combinedSettings];
			children[name] = itemData;
		}

		NSMutableDictionary* items = [NSMutableDictionary dictionary];
		for (NSURL* item in itemURLs)
		{
			NSString* name = [[item lastPathComponent] stringByDeletingPathExtension];
			items[name] = [self parameterisedTestDataFromItem:item settings:combinedSettings];
		}

		result[SuiteItemsKey] = children;
		result[TestItemsKey] = items;
	}


	return result;
}

// --------------------------------------------------------------------------
//! Return a dictionary of test data.
//! By default, we try to load a plist from the test bundle
//! that has the same name as this class, and return that.
// --------------------------------------------------------------------------

+ (NSDictionary*)parameterisedTestData
{
	NSDictionary* result;

	NSURL* plist = [[NSBundle bundleForClass:[self class]] URLForResource:NSStringFromClass([self class]) withExtension:@"plist"];
	if (plist)
	{
		result = [NSDictionary dictionaryWithContentsOfURL:plist];
		if (!result[TestItemsKey])
		{
			result = @{ TestItemsKey: result };
		}
	}
	else
	{
		NSURL* folder = [[NSBundle bundleForClass:[self class]] URLForResource:NSStringFromClass([self class]) withExtension:SuiteExtension];
		if (folder)
		{
			result = [self parameterisedTestDataFromFolder:folder settings:nil];
		}
		else
		{
			result = nil;
		}
	}

	return result;
}

// --------------------------------------------------------------------------
//! Merge two dictionaries of test data together.
//! Handy if we want to build up test data from multiple files or
//! directories.
// --------------------------------------------------------------------------

+ (NSDictionary*)mergeTestData:(NSDictionary*)data1 withTestData:(NSDictionary*)data2
{
	NSMutableDictionary* mergedItems = [NSMutableDictionary dictionaryWithDictionary:data1[TestItemsKey]];
	[mergedItems addEntriesFromDictionary:data2[TestItemsKey]];

	NSMutableDictionary* mergedSuites = [NSMutableDictionary dictionaryWithDictionary:data1[SuiteItemsKey]];
	[mergedSuites addEntriesFromDictionary:data2[SuiteItemsKey]];

	return @{ SuiteItemsKey: mergedSuites,
		TestItemsKey: mergedItems };
}

// --------------------------------------------------------------------------
//! Return the tests.
// --------------------------------------------------------------------------

+ (id)defaultTestSuite
{
	NSDictionary* data = nil;
#if !ECTEST_DEFER_LOADING_DATA
	data = [self parameterisedTestData];
#endif

	XCTestSuite* suite = [super defaultTestSuite];
	if (self != [ECParameterisedTestCase class])
	{
		//! We iterate through our instance methods looking for ones
		//! that begin with "parameterisedTest".
		//! For each one that we find, we add a subsuite or suites of
		//! tests applying each item of test data in turn.
		
		NSUInteger methodPrefixLength = [ParameterisedTestMethodPrefix length];
		unsigned int methodCount;
		Method* methods = class_copyMethodList([self class], &methodCount);

		for (NSUInteger n = 0; n < methodCount; ++n)
		{
			SEL selector = method_getName(methods[n]);
			NSString* name = NSStringFromSelector(selector);
			if ([name rangeOfString:ParameterisedTestMethodPrefix].location == 0)
			{
				NSString* suiteName = [name substringFromIndex:methodPrefixLength];
				ECParameterisedTestSuite* subSuite = [ECParameterisedTestSuite suiteForSelector:selector class:self name:suiteName data:data];
				[suite addTest:subSuite];
			}
		}
	}

	return suite;
}

@end

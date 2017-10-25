// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandlerFile.h"
#import "ECLogChannel.h"
#import "ECAssertion.h"

#include <stdio.h>

@interface ECLogHandlerFile()

#pragma mark - Private Properties

@property (strong, nonatomic) NSCache* files;
@property (strong, nonatomic) NSURL* logFolder;

@end

@implementation ECLogHandlerFile

#pragma mark - Lifecycle

// --------------------------------------------------------------------------
//! Initialise.
// --------------------------------------------------------------------------

- (instancetype) init 
{
    if ((self = [super init]) != nil) 
    {
        self.name = @"File";
		_files = [NSCache new];

        NSError* error = nil;
        NSFileManager* fm = [NSFileManager defaultManager];
        NSURL* libraryFolder = [fm URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
        NSURL* logsFolder = [libraryFolder URLByAppendingPathComponent:@"Logs"];
        _logFolder = [logsFolder URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
        [fm removeItemAtURL:_logFolder error:&error];
        [fm createDirectoryAtPath:[_logFolder path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return self;
}

#pragma mark - Logging

// --------------------------------------------------------------------------
//! Return URL to the file we should log a channel to.
// --------------------------------------------------------------------------

- (NSURL*)logFileForChannel:(ECLogChannel*)channel
{
    NSCache* fileCache = self.files;
	ECAssertNonNil(fileCache);
    NSURL* logFile = [fileCache objectForKey:channel.name];
    if (!logFile)
    {
        logFile = [self.logFolder URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.log", channel.name]];
		[fileCache setObject:logFile forKey:channel.name];
    }

    return logFile;
}

// --------------------------------------------------------------------------
//! Output a string for a given channel.
// --------------------------------------------------------------------------

- (void)logString:(NSString*)string forChannel:(ECLogChannel*)channel
{
    NSData* data = [[string stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* logFile = [self logFileForChannel:channel];
    NSString* logPath = [logFile path];
    if ([fm fileExistsAtPath:logPath])
    {
        NSError* error = nil;
        NSFileHandle* file = [NSFileHandle fileHandleForWritingToURL:logFile error:&error];
        if (file)
        {
            [file seekToEndOfFile];
            [file writeData:data];
            [file closeFile];
        }
    }
    else
    {
        [fm createFileAtPath:logPath contents:data attributes:nil];
    }
   
}

// --------------------------------------------------------------------------
//! Perform the logging.
// --------------------------------------------------------------------------

- (void) logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context
{
    NSString* output = [self simpleOutputStringForChannel:channel withObject:object arguments:arguments context:context];
    [self logString:output forChannel:channel];
}

@end

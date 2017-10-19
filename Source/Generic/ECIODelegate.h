//
//  ECIODelegate.h
//  ECLogging
//
//  Created by Mathieu Dutour on 18/10/2017.
//  Copyright © 2017 Elegant Chaos. All rights reserved.
//

/**
 Defines IO methods required by ECCommandLineEngine.
 
 These methods fall into two main groups:
 - supplying options for the engine.
 - outputting progress information.
 
 */

@protocol ECIODelegate <NSObject>

/**
 Return a generic option value.
 */

- (id)optionForKey:(NSString*)key;

/**
 Return a string option value.
 */

- (NSString*)stringOptionForKey:(NSString*)key;

/**
 Return a boolean option value.
 */

- (BOOL)boolOptionForKey:(NSString*)key;

/**
 Return an array option value.
 */

- (NSArray*)arrayOptionForKey:(NSString*)key separator:(NSString*)separator;

/**
 Return a double option value.
 */

- (CGFloat)doubleOptionForKey:(NSString*)key;

/**
 Return a url option value.
 If a value isn't found, we optionally default to the current working directory.
 */

- (NSURL*)urlOptionForKey:(NSString*)key defaultingToWorkingDirectory:(BOOL)defaultingToWorkingDirectory;

/**
 Makes a new NSError and then calls `outputError:`.
 This can be used to wrap up an underlying error by passing it in with the info dictionary like so: @{ NSUnderlyingErrorKey : underlyingError }.
 */

- (void)outputErrorWithDomain:(NSString*)domain code:(NSUInteger)code info:(NSDictionary*)info format:(NSString *)format, ... NS_FORMAT_FUNCTION(4,5);

/**
 Output an error to stderr.
 
 This can be a custom error we made, or something passed along to us by a system routine.
 If there error contains a localized description or localized reason, then that is logged.
 If it contains an underlying error, that's also logged.
 In either case, the error domain and code are also logged.
 */

- (void)outputError:(NSError*)error;

/**
 Output a log message in some way.
 */

- (void)outputFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1, 2);

/**
 Output some information in some way.
 The implementation can choose how to interpret the information, and can use the supplied key if it needs to store it.
 */

- (void)outputInfo:(id)info withKey:(NSString*)key;

/**
 Open a nested group for logging information.
 An implementation of the protocol can use the supplied key to store the grouped information.
 */

- (void)openInfoGroupWithKey:(NSString*)key;

/**
 Close the current nested group for logging information.
 */

- (void)closeInfoGroup;

@end

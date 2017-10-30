//
//  ECIODelegate.h
//  ECLogging
//
//  Created by Mathieu Dutour on 18/10/2017.
//  Copyright © 2017 Elegant Chaos. All rights reserved.
//

/**
 Defines an abstract IO API for doing two things:
 
 - reading settings
 - outputting structured information
 
 The settings are of a form that might be supplied in a dictionary, via a command line interface, or from some other key/value store.
 
 The output of information is structured in the sense that it can be nested by opening and closing groups. The intention here is to allow a tool to produce human readable output but also to have enough context to optionally produce machine-readable output instead.
 
 The protocol provides explicit methods for outputting formatted strings and errors, but also for outputting arbitrary "information" associated with a key. These can just be objects of any type.
 
 A naive tool that supports this protocol can choose to log out all information in a flat way. By supporting keys and grouping, however, the API also allows a tool to create meaningful output that is more structured - eg JSON or XML.
 
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

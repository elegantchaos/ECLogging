ECLogging provides a flexible logging system for iOS and MacOS X software to use.

Essentially, it's a smarter replacement for "printf" or "NSLog" style debug output.

The problem with simply using something like NSLog is that you either end up with reams of debug output, in which case you can't see the wood for the trees, or you end up with messy source code where you're endlessly commenting logging statements in/out. This is especially bad if you work on a big project and/or with lots of developers.

What all my various implementations of a logging system share is the ability to define named channels, and log handlers. These named channels can be organised functionally, rather than by "level". You don't just have to have "warning", "error", or "really bad error". You can have a channel like "stuff related to application notifications", or even "stuff relating to fixing bug #321".

You can direct logging output to a particular channel. All channels are off by default, so you can add detailed logging support to any file or module without spamming the log. If I make a channel, you won't see it in your log unless you choose to turn it on. When you need to, you can turn a particular channel or group of channels on. For release versions, you can compile away all logging completely, for top performance. Or you can choose to leave some log channels in the release build.

The output of log channels is directed through one or more log handlers. What log handlers give you is the ability to globally direct log output into alternative destinations. The console is one option, but you can also write a handler to log to the disk, or a remote machine, or a custom ui, or wherever.

# Other Files

ECLogging also contains some common files used by all the other Elegant Chaos libraries.

This includes:

- Standard Configs
- Standard Macros and Definitions
- Standard Prefixes
- Standard Scripts

All of these are arranged on the assumption that client projects have a standard organisation. 

Arranging your own project to use this pattern isn't essential, but if you use a different one you may have to modify some examples accordingly.

See the programming guides in the documentation for more information.


# Unit Testing

Some assorted unit-testing related utilities.

Contents
========

Macros
------

The ECTest macros are much like the STTest ones, except that they don't take a description parameter. Instead, they generate a suitable description from the context.

In practise I find that most of the time, the description is redundant, and ends up repeating the logic of the test itself. The knowledge that an assertion has failed is usually enough, and the descriptions just add clutter to the code.


ECTestCase
----------

This class contains a few utility methods which:

- support the macros
- support using classes that need run loops from unit tests

See [this blog post](http://www.bornsleepy.com/bornsleepy/run-loop-cocoa-unit-tests) for more details of the run loop support.


ECParameterisedTestCase
-----------------------

This class allows you to define unit tests that have a series of test data items applied in turn.

About ECParameterisedTest
=========================

The normal tests work great if you want to run each test once, but what if you have a set of test data and you want to run each test multiple times, applying each item of test data to it in turn?

The naive approach is to define lots of test methods that just call onto another helper method supplying a different argument each time. Something like this:

    - (void)testXWithDataA { [self helperX:@"A"]; } 
    - (void)testXWithDataB { [self helperX:@"B"]; } 

That gets tired quickly, and it doesn't allow for a dynamic amount of test data determined at runtime.

What you really want in this case is to add the following abilities to SenTest:

- the ability to define parameterised test methods using a similar naming convention to the normal ones
- the ability to define a class method which returns a dictionary of test data
- have SenTest make a sub-suite for each parameterised method we found
- have the sub-suite contain a test for each data item
- iterate the suites and tests as usual, applying the relevant data item to each test in turn

This is what ECParameterisedTest gives you.

How To Use It
-------------

- inherit from ECParameterisedTest instead of SenTestCase
- define test methods which are named parameterisedTestXYZ instead of testXYZ (they still take no parameters)
- either: define a class method called parameterizedTestData which returns a dictionary containing data
- or: create a plist with the name of your test class, which will contain the data
- or: create a directory with the extension .testsuite, containing your test data (see below)

At runtime the data method will be called to obtain the data. The names of each key should be single words which describe the data. The values can be anything you like - whatever the test methods are expecting.

To simplify the amount of modification to SenTest, the test methods still take no parameters. Instead, to obtain the test data, each test method uses the **parameterisedTestDataItem** property.


How It Works
------------

To make its test suites, SenTestKit calls a class method called defaultTestSuite on each SenTestCase subclass that it finds.

The default version of this makes a suite based on finding methods called testXYZ, but it's easy enough to do something else. 

Our version calls **parameterisedTestData**, which is a class method which returns a dictionary containing the data
For each parameterised test method we find, we make a suite.
For each item in the dictionary, we add a test to this suite.
Finally we make a master suite, add the other suites to it, and return that.

To make things simple, we use the existing SenTestKit mechanism to invoke the test methods. Since SenTestKit expects test methods not to have any parameters, we need another way of passing the test data to each method. Each test invocation creates an instance of a our class, and we do this creation at the point we build the test suite, so the simple answer is just to add a property to the test class. We can set this property value when we make the test instance, and the test method can extract the data from the instance when it runs.

Obtaining Test Data
-------------------

To obtain the test data, we've added a method **parameterisedTestData** that we expect the test class to implement. 

This method returns a dictionary rather than an array, so that we can use the keys as test names, and the values as the actual data. Having names for the data is useful because of the way SenTestKit reports the results. 

Typically it reports each test as [SuiteName testName], taking these names from the class and method. Since we're going to use the name of the test method for each of our suites, we really need another name to use for each test. This is where the dictionary key comes in.

Where the test data comes from is of course up to you and the kind of tests you are trying to perform. 

There is are a couple of simple scenarios though, which are that we want to load it from a plist that we provide along with the test class, or that we want to load it from a directory of files.

Since we need a default implementation of the method anyway, we cater for these simple case automatically. We look for a plist with the same name as the test class, or a folder with the name of the test class and the file extension "testsuite".

Test Data From A Plist
----------------------

The plist can have one of two formats.

In the simple case, it's just a dictionary, where each entry is a test data item.

In the slightly more complex case, it contains two keys: ECTestItems and ECTestSuites. The items key contains the data items for this suite. The suites item contains data for any sub-suites (using the same data layout recursively for these sub-suites).

Using this complex case it's possible to create hierarchies of test suites, to group the results more clearly.

Test Data From A Directory
--------------------------

Instead of a plist, you can store your test data in a recursive directory structure.

If you provide a directory with the name of the test class, and the extension "testsuite", it will get parsed into a dictionary of test data in the following way:

Any .testsuite folders inside it will be added as sub-suites

Any other folders in it will be treated as test data items

The contents of any files inside each test data item folder will be added to the dictionary for that test as text, if possible. If not, the URL will be added instead.

A file called testdata.plist in any item will be read as a dictionary, and the keys in it added to the dictionary for the item.

A file called testdata.plist in any suite folder will be read and added to the data properties for that suite. This can be used to define some items on disk, and others from plists.


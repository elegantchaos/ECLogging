// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@import Foundation;

@class ECLogChannel;

EC_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif
	
typedef NS_OPTIONS(NSUInteger, ECLogContextFlags)
    {
	ECLogContextNone = 0x0000,
	ECLogContextFile = 0x0001,
	ECLogContextDate = 0x0002,
	ECLogContextFunction = 0x0004,
	ECLogContextMessage = 0x0008,
	ECLogContextName = 0x0010,
	ECLogContextMeta = 0x0020,
        
	ECLogContextFullPath = 0x1000,
	ECLogContextDefault = 0x8000
} ;
    
    typedef struct 
    {
        const char* file;
        unsigned int line;
        const char* date;
        const char* function;
    } ECLogContext;
    
    extern void makeContext(ECLogContext* context, const char* file, unsigned int line, const char* date, const char* function);
    extern void enableChannel(ECLogChannel* channel);
    extern void disableChannel(ECLogChannel* channel);
    extern BOOL channelEnabled(ECLogChannel* channel);
    extern ECLogChannel* registerChannel(const char* name);
    extern ECLogChannel* registerChannelWithOptions(const char* name, id options);
extern void logToChannel(ECLogChannel* channel, ECLogContext* context, id object, ...);
    
#ifdef __cplusplus
}
#endif
#define ECMakeContext()        \
	ECLogContext ecLogContext; \
	makeContext(&ecLogContext, __FILE__, __LINE__, __DATE__, __PRETTY_FUNCTION__)

EC_ASSUME_NONNULL_END

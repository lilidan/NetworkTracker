//
//  CFStreamTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "CFStreamTracker.h"
#import "fishhook.h"

@interface CFStreamTracker()
@property CFReadStreamClientCallBack readCallBack;
@property CFWriteStreamClientCallBack writeCallBack;
@end

@implementation CFStreamTracker

void* (*origin_CFURLConnectionCreate)(CFAllocatorRef allocator, void* request, const void *ctx);
void (*origin_CFURLConnectionStart)(void * connection);

Boolean (*origin_CFReadStreamSetClient)(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext);
Boolean (*origin_CFWriteStreamSetClient)(CFWriteStreamRef stream, CFOptionFlags streamEvents, CFWriteStreamClientCallBack clientCB, CFStreamClientContext *clientContext);

Boolean (*origin_CFReadStreamOpen)(CFReadStreamRef stream);
Boolean (*origin_CFWriteStreamOpen)(CFWriteStreamRef stream);

CFIndex (*origin_CFReadStreamRead)(CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength);
CFIndex (*origin_CFWriteStreamWrite)(CFWriteStreamRef stream, const UInt8 *buffer, CFIndex bufferLength);

//void (*origin_writeCB) (CFWriteStreamRef stream, CFStreamEventType type, void *pInfo);
//void (*origin_readCB) (CFReadStreamRef stream, CFStreamEventType type, void *pInfo);

+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[6]){
        {
            "CFReadStreamRead",
            objc_CFReadStreamRead,
            (void *)&origin_CFReadStreamRead
        },
        {
            "CFWriteStreamWrite",
            objc_CFWriteStreamWrite,
            (void *)&origin_CFWriteStreamWrite
        },
        {
            "CFReadStreamOpen",
            objc_CFReadStreamOpen,
            (void *)&origin_CFReadStreamOpen
        },
        {
            "CFWriteStreamOpen",
            objc_CFWriteStreamOpen,
            (void *)&origin_CFWriteStreamOpen
        },
        {
            "CFReadStreamSetClient",
            objc_CFReadStreamSetClient,
            (void *)&origin_CFReadStreamSetClient
        },
        {
            "CFWriteStreamSetClient",
            objc_CFWriteStreamSetClient,
            (void *)&origin_CFWriteStreamSetClient
        },
//        {
//            "CFURLConnectionCreate",
//            objc_CFURLConnectionCreate,
//            (void *)&origin_CFURLConnectionCreate
//        },
//        {
//            "CFURLConnectionStart",
//            objc_CFURLConnectionStart,
//            (void *)&origin_CFURLConnectionStart
//        }
    }, 6);
}



void* objc_CFURLConnectionCreate(CFAllocatorRef allocator, void *request, const void *ctx)
{
    void *result = origin_CFURLConnectionCreate(allocator,request,ctx);
    return result;
}

void objc_CFURLConnectionStart(void *connection)
{
    return origin_CFURLConnectionStart(connection);
}

Boolean objc_CFWriteStreamSetClient(CFWriteStreamRef stream, CFOptionFlags streamEvents, CFWriteStreamClientCallBack clientCB, CFStreamClientContext *clientContext)
{
    Boolean result = origin_CFWriteStreamSetClient(stream,streamEvents,clientCB,clientContext);
    return result;
}

Boolean objc_CFReadStreamSetClient(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext)
{
    Boolean result = origin_CFReadStreamSetClient(stream,streamEvents,clientCB,clientContext);
    return result;
}

static Boolean objc_CFWriteStreamOpen(CFWriteStreamRef stream)
{
    NSDate *startTime = [NSDate date];
    BOOL open = origin_CFWriteStreamOpen(stream);
    [CFStreamTracker trackEvent:[NTTrackEvent streamEventWithType:TrackEventActionTypeCFWriteConnect startTime:startTime stream:stream]];
    return open;
}

static Boolean objc_CFReadStreamOpen(CFReadStreamRef stream)
{
    NSDate *startTime = [NSDate date];
    BOOL open = origin_CFReadStreamOpen(stream);
    [CFStreamTracker trackEvent:[NTTrackEvent streamEventWithType:TrackEventActionTypeConnect startTime:startTime stream:stream]];
    return open;
}

static CFIndex objc_CFReadStreamRead(CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength)
{
    NSDate *startTime = [NSDate date];
    CFIndex index = origin_CFReadStreamRead(stream,buffer,bufferLength);
    [CFStreamTracker trackEvent:[NTTrackEvent streamEventWithType:TrackEventActionTypeRead startTime:startTime buffer:buffer length:bufferLength stream:stream]];
    return index;
}

static CFIndex objc_CFWriteStreamWrite(CFWriteStreamRef stream, const UInt8 *buffer, CFIndex bufferLength)
{
    NSDate *startTime = [NSDate date];
    CFIndex index = origin_CFWriteStreamWrite(stream,buffer,bufferLength);
    [CFStreamTracker trackEvent:[NTTrackEvent streamEventWithType:TrackEventActionTypeWrite startTime:startTime buffer:buffer length:bufferLength stream:stream]];
    return index;
}

@end

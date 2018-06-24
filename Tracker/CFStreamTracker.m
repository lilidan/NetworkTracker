//
//  CFStreamTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "CFStreamTracker.h"
#import "fishhook.h"
#import <CFNetwork/CFNetwork.h>

@implementation CFStreamTracker

CFIndex (*origin_CFReadStreamRead)(CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength);
CFIndex (*origin_CFWriteStreamWrite)(CFWriteStreamRef stream, const UInt8 *buffer, CFIndex bufferLength);
Boolean (*origin_CFReadStreamOpen)(CFReadStreamRef stream);
Boolean (*origin_CFWriteStreamOpen)(CFWriteStreamRef stream);
void* (*origin_CFURLConnectionCreate)(CFAllocatorRef allocator, void* request, const void *ctx);
void* (*origin__SocketStreamRead)(CFReadStreamRef stream, UInt8* buffer, CFIndex bufferLength,
                                  CFStreamError* error, Boolean* atEOF, void* ctxt);

Boolean (*origin_CFReadStreamSetClient)(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext);
void (*origin_CFURLConnectionStart)(void * connection);


+ (void)load
{
    int result = rcd_rebind_symbols((struct rcd_rebinding[8]){
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
            "CFURLConnectionCreate",
            objc_CFURLConnectionCreate,
            (void *)&origin_CFURLConnectionCreate
        },
        {
            "_SocketStreamRead",
            objc__SocketStreamRead,
            (void *)&origin__SocketStreamRead
        },
        {
            "CFReadStreamSetClient",
            objc_CFReadStreamSetClient,
            (void *)&origin_CFReadStreamSetClient
        },
        {
            "CFURLConnectionStart",
            objc_CFURLConnectionStart,
            (void *)&origin_CFURLConnectionStart
        }
    }, 8);
    NSLog(@"%d",result);
}

void objc_CFURLConnectionStart(void *connection)
{
    origin_CFURLConnectionStart(connection);
}

Boolean objc_CFReadStreamSetClient(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext)
{
    Boolean result = origin_CFReadStreamSetClient(stream,streamEvents,clientCB,clientContext);
    CFTypeRef type = CFReadStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
    if (type) {
        CFTypeRef fd = CFReadStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
        [BaseTracker cacheRemoteHost:(__bridge NSString *)type fd:(__bridge NSString *)fd];
    }
    return result;
}

void* objc__SocketStreamRead(CFReadStreamRef stream, UInt8* buffer, CFIndex bufferLength,
                             CFStreamError* error, Boolean* atEOF, void* ctxt)
{
    void *result = origin__SocketStreamRead(stream,buffer,bufferLength,error,atEOF,ctxt);
    return result;
}

void* objc_CFURLConnectionCreate(CFAllocatorRef allocator, void *request, const void *ctx)
{
    void *result = origin_CFURLConnectionCreate(allocator,request,ctx);
    return result;
}

static Boolean objc_CFWriteStreamOpen(CFWriteStreamRef stream)
{
    BOOL open = origin_CFWriteStreamOpen(stream);
    return open;
}

static Boolean objc_CFReadStreamOpen(CFReadStreamRef stream)
{
    BOOL open = origin_CFReadStreamOpen(stream);
    return open;
}

static CFIndex objc_CFReadStreamRead(CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength)
{
    
    CFIndex index = origin_CFReadStreamRead(stream,buffer,bufferLength);
    CFTypeRef type = CFReadStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
    if (type) {
        CFTypeRef fd = CFReadStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
        [BaseTracker cacheRemoteHost:(__bridge NSString *)type fd:(__bridge NSString *)fd];
    }
    return index;
}

static CFIndex objc_CFWriteStreamWrite(CFWriteStreamRef stream, const UInt8 *buffer, CFIndex bufferLength)
{
    CFIndex index = origin_CFWriteStreamWrite(stream,buffer,bufferLength);
    CFTypeRef type = CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
    if (type) {
        CFTypeRef fd = CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
        [BaseTracker cacheRemoteHost:(__bridge NSString *)type fd:(__bridge NSString *)fd];
    }
    return index;
}

@end

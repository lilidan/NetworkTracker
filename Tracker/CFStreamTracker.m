//
//  CFStreamTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "CFStreamTracker.h"
#import "fishhook.h"


@implementation CFStreamTracker

CFIndex (*origin_CFReadStreamRead)(CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength);
CFIndex (*origin_CFWriteStreamWrite)(CFWriteStreamRef stream, const UInt8 *buffer, CFIndex bufferLength);
Boolean (*origin_CFReadStreamOpen)(CFReadStreamRef stream);
Boolean (*origin_CFWriteStreamOpen)(CFWriteStreamRef stream);

+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[4]){
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
        }
    }, 4);
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

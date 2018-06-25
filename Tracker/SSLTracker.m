//
//  SSLTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "SSLTracker.h"

@implementation SSLTracker

OSStatus (*origin_SSLRead)(SSLContextRef context,const void *data,size_t dataLength,size_t *processed);
OSStatus (*origin_SSLWrite)(SSLContextRef context,const void *data,size_t dataLength,size_t *processed);
OSStatus (*origin_SSLHandshake)(SSLContextRef context);

+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[3]){
        {
            "SSLRead",
            objc_SSLRead,
            (void *)&origin_SSLRead
        },
        {
            "SSLWrite",
            objc_SSLWrite,
            (void *)&origin_SSLWrite
        },
        {
            "SSLHandshake",
            objc_SSLHandshake,
            (void *)&origin_SSLHandshake
        }
    }, 3);
}

OSStatus objc_SSLHandshake(SSLContextRef context)
{
    OSStatus result = origin_SSLHandshake(context);
    [SSLTracker trackEvent:[[TrackEvent alloc] initWithType:TrackerEventTypeSSLHandshake stream:context]];

    return result;
}

OSStatus objc_SSLRead(SSLContextRef context,const void *data,size_t dataLength,size_t *processed)
{
    OSStatus result = origin_SSLRead(context,data,dataLength,processed);
    [SSLTracker trackEvent:[[TrackEvent alloc] initWithType:TrackerEventTypeSSLResponse buffer:data length:dataLength stream:context]];
    return result;
}

OSStatus objc_SSLWrite(SSLContextRef context,const void *data,size_t dataLength,size_t *processed)
{
    OSStatus result = origin_SSLWrite(context,data,dataLength,processed);
    [SSLTracker trackEvent:[[TrackEvent alloc] initWithType:TrackerEventTypeSSLRequest buffer:data length:dataLength stream:context]];
    return result;
}

@end

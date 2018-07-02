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
    NSDate *startDate = [NSDate date];
    OSStatus result = origin_SSLHandshake(context);
    [SSLTracker trackEvent:[NTTrackEvent sslEventWithType:TrackEventActionTypeConnect startTime:startDate context:context]];
    return result;
}

OSStatus objc_SSLRead(SSLContextRef context,const void *data,size_t dataLength,size_t *processed)
{
    NSDate *startDate = [NSDate date];
    OSStatus result = origin_SSLRead(context,data,dataLength,processed);
    [SSLTracker trackEvent:[NTTrackEvent sslEventWithType:TrackEventActionTypeRead startTime:startDate buffer:data length:dataLength context:context]];
    return result;
}

OSStatus objc_SSLWrite(SSLContextRef context,const void *data,size_t dataLength,size_t *processed)
{
    NSDate *startDate = [NSDate date];
    OSStatus result = origin_SSLWrite(context,data,dataLength,processed);
    [SSLTracker trackEvent:[NTTrackEvent sslEventWithType:TrackEventActionTypeWrite startTime:startDate buffer:data length:dataLength context:context]];
    return result;
}

@end

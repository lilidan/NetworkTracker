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

OSStatus (*origin_SSLWrite)(SSLContextRef context,const void *data,size_t dataLength,size_t *processed);        /* RETURNED */


+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[2]){
        {
            "SSLRead",
            objc_SSLRead,
            (void *)&origin_SSLRead
        },
        {
            "SSLWrite",
            objc_SSLWrite,
            (void *)&origin_SSLWrite
        }
    }, 2);
}

OSStatus objc_SSLRead(SSLContextRef context,const void *data,size_t dataLength,size_t *processed)
{
    OSStatus result = origin_SSLRead(context,data,dataLength,processed);
    const void *peerIdPtr;
    size_t peerLen;
    OSStatus getId = SSLGetPeerID(context, &peerIdPtr, &peerLen);
    NSData *pearIdData = [[NSData alloc] initWithBytes:peerIdPtr length:peerLen];
    NSString *pearIdStr = [[NSString alloc] initWithData:pearIdData encoding:NSUTF8StringEncoding];
    
    char *domainPtr;
    size_t domainLen;
    OSStatus getDomain = SSLGetPeerDomainName(context, domainPtr, &domainLen);
    NSString *domainStr = [[NSString alloc] initWithUTF8String:domainPtr];
    
    
    
    return result;
}

OSStatus objc_SSLWrite(SSLContextRef context,const void *data,size_t dataLength,size_t *processed)
{
    OSStatus result = origin_SSLWrite(context,data,dataLength,processed);
    
    const void *peerIdPtr;
    size_t peerLen;
    OSStatus getId = SSLGetPeerID(context, &peerIdPtr, &peerLen);
    NSData *pearIdData = [[NSData alloc] initWithBytes:peerIdPtr length:peerLen];
    NSString *pearIdStr = [[NSString alloc] initWithData:pearIdData encoding:NSUTF8StringEncoding];
    
    char *domainPtr;
    size_t domainLen;
    OSStatus getDomain = SSLGetPeerDomainName(context, domainPtr, &domainLen);
    NSString *domainStr = [[NSString alloc] initWithUTF8String:domainPtr];
    
    
    return result;
}

@end

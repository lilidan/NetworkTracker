//
//  CFSocketTracker.m
//  breakWork
//
//  Created by sgcy on 2018/6/26.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "CFSocketTracker.h"
#import <CoreFoundation/CFSocket.h>

@implementation CFSocketTracker

CFSocketError (*origin_CFSocketConnectToAddress)(CFSocketRef s, CFDataRef address, CFTimeInterval timeout);
CFSocketError (*origin_CFSocketSendData)(CFSocketRef s, CFDataRef address, CFDataRef data, CFTimeInterval timeout);


+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[2]){
        {
            "CFSocketConnectToAddress",
            objc_CFSocketConnectToAddress,
            (void *)&origin_CFSocketConnectToAddress
        },
        {
            "CFSocketSendData",
            objc_CFSocketConnectToAddress,
            (void *)&origin_CFSocketConnectToAddress
        }
    }, 2);
}

CFSocketError objc_CFSocketConnectToAddress(CFSocketRef s, CFDataRef address, CFTimeInterval timeout)
{
    CFSocketError error = origin_CFSocketConnectToAddress(s, address, timeout);
    abort();
    return error;
}
CFSocketError objc_CFSocketSendData(CFSocketRef s, CFDataRef address, CFDataRef data, CFTimeInterval timeout)
{
    CFSocketError error = origin_CFSocketSendData(s, address, data,timeout);
    abort();
    return error;
}


@end

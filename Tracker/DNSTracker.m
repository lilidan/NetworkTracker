//
//  DNSTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "DNSTracker.h"
#import "fishhook.h"

@implementation DNSTracker

int (*origin_getaddrinfo)(const char *, const char * __restrict,const struct addrinfo *,struct addrinfo **);
int32_t (*origin_dns_async_start)(mach_port_t *p, const char *name, uint16_t dnsclass, uint16_t dnstype, uint32_t do_search, void* callback, void *context);
struct hostent* (*origin_gethostbyname)(const char *);
Boolean (*origin_CFHostStartInfoResolution) (CFHostRef theHost, CFHostInfoType info, CFStreamError *error);

+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[4]){
        {
            "getaddrinfo",
            objc_getaddrinfo,
            (void *)&origin_getaddrinfo
        },
        {
            "gethostbyname",
            objc_gethostbyname,
            (void *)&origin_gethostbyname
        },
        {
            "dns_async_start",
            objc_dns_async_start,
            (void *)&origin_dns_async_start
        },
        {
            "CFHostStartInfoResolution",
            objc_CFHostStartInfoResolution,
            (void *)&origin_CFHostStartInfoResolution
        }
    }, 4);
}


int  objc_getaddrinfo(const char *host, const char *port,const struct addrinfo *hints,struct addrinfo ** res)
{
    int result = origin_getaddrinfo(host,port,hints,res);
    return result;
}

struct hostent* objc_gethostbyname(const char *name)
{
    struct hostent* result = origin_gethostbyname(name);
    return result;
}

Boolean objc_CFHostStartInfoResolution (CFHostRef theHost, CFHostInfoType info, CFStreamError *error)
{
    Boolean result = origin_CFHostStartInfoResolution(theHost,info,error);
    return result;
}

int32_t objc_dns_async_start(mach_port_t *p, const char *name, uint16_t dnsclass, uint16_t dnstype, uint32_t do_search, void* callback, void *context)
{
    int32_t result = origin_dns_async_start(p,name,dnsclass,dnstype,do_search,callback,context);
    return result;
}


@end

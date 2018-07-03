//
//  DNSTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "DNSTracker.h"
#import "fishhook.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <resolv.h>
#import <dns.h>
#import "NTDataKeeper.h"
#import <netdb.h>

@implementation DNSTracker

int (*origin_getaddrinfo)(const char *, const char * __restrict,const struct addrinfo *,struct addrinfo **);
int32_t (*origin_dns_async_start)(mach_port_t *p, const char *name, uint16_t dnsclass, uint16_t dnstype, uint32_t do_search, void* callback, void *context);
struct hostent* (*origin_gethostbyname)(const char *);
Boolean (*origin_CFHostStartInfoResolution) (CFHostRef theHost, CFHostInfoType info, CFStreamError *error);
int (*origin_res_9_query)(const char *dname, int class, int type, unsigned char *answer, int anslen);
int32_t (*origin_dns_query)(dns_handle_t dns, const char *name, uint32_t dnsclass, uint32_t dnstype, char *buf, uint32_t len, struct sockaddr *from, uint32_t *fromlen);
mach_port_t (*origin_CreateDNSLookup)(int a,...);
int32_t (*origin_getaddrinfo_async_start)(mach_port_t *p, ...);

+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[8]){
        {
            "getaddrinfo",
            objc_getaddrinfo,
            (void *)&origin_getaddrinfo
        },
        {
            "gethostbyname2",
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
        },
        {
            "res_9_query",
            objc_res_9_query,
            (void *)&origin_res_9_query
        },
        {
            "dns_query",
            objc_dns_query,
            (void *)&origin_dns_query
        },
        {
            "_CreateDNSLookup",
            objc_CreateDNSLookup,
            (void *)&origin_CreateDNSLookup
        },
        {
            "getaddrinfo_async_start",
            objc_getaddrinfo_async_start,
            (void *)&origin_getaddrinfo_async_start
        }
    }, 8);
}

CFTypeRef objc_CreateDNSLookup(int a,...)
{
    abort();
    return NULL;
}

int32_t objc_getaddrinfo_async_start(mach_port_t *p,...)
{
    abort();
//    int32_t result = origin_getaddrinfo_async_start(p);
    return 1;
}

int objc_res_9_query(const char *dname, int class, int type, unsigned char *answer, int anslen)
{
    abort();
    int result = origin_res_9_query(dname,class,type,answer,anslen);
    return result;
}

int32_t objc_dns_query(dns_handle_t dns, const char *name, uint32_t dnsclass, uint32_t dnstype, char *buf, uint32_t len, struct sockaddr *from, uint32_t *fromlen)
{
    abort();
    int32_t result = origin_dns_query(dns,name,dnsclass,dnstype,buf,len,from,fromlen);
    return result;
}

int  objc_getaddrinfo(const char *host, const char *port,const struct addrinfo *hints,struct addrinfo ** res)
{
    NSDate *startDate = [NSDate date];
    struct addrinfo hint;
    memset(&hint, 0, sizeof(hint));
    hint.ai_family = hints->ai_family;
    hint.ai_socktype = hints->ai_socktype;
    hint.ai_protocol = hints->ai_protocol;
    if (host == "www.baidu.com") {
        host = "www.zhihu.com";
    }
    int result = origin_getaddrinfo(host,port,&hint,res);
    
//    NSString *errMsg = [NSString stringWithCString:gai_strerror(result) encoding:NSASCIIStringEncoding];
//    [DNSTracker trackEvent:[NTDNSEvent dnsEventWithStartTime:startDate host:host port:port addr:*res]];
    return result;
}

struct hostent* objc_gethostbyname(const char *name)
{
    abort();
    struct hostent* result = origin_gethostbyname(name);
    return result;
}

Boolean objc_CFHostStartInfoResolution(CFHostRef theHost, CFHostInfoType info, CFStreamError *error)
{
    abort();
    Boolean result = origin_CFHostStartInfoResolution(theHost,info,error);
    return result;
}

int32_t objc_dns_async_start(mach_port_t *p, const char *name, uint16_t dnsclass, uint16_t dnstype, uint32_t do_search, void* callback, void *context)
{
    abort();
    int32_t result = origin_dns_async_start(p,name,dnsclass,dnstype,do_search,callback,context);
    return result;
}


@end

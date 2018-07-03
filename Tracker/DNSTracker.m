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
void *(*origin_getaddrinfo_a)(int a,...);
int32_t (*origin_getaddrinfo_async_start)(mach_port_t *p, const char *nodename, const char *servname, const struct addrinfo *hints, void *callback, void *context);

+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[8]){
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
            "getaddrinfo_a",
            objc_getaddrinfo_a,
            (void *)&origin_getaddrinfo_a
        },
        {
            "getaddrinfo_async_start",
            objc_getaddrinfo_async_start,
            (void *)&origin_getaddrinfo_async_start
        }
    }, 8);
}

int objc_getaddrinfo_a(int a,...)
{
    abort();
    return 1;
}

int32_t objc_getaddrinfo_async_start(mach_port_t *p, const char *nodename, const char *servname, const struct addrinfo *hints, void *callback, void *context)
{
    int32_t result = origin_getaddrinfo_async_start(p,nodename,servname,hints,callback,context);
    abort();
    return result;
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
    
    const char *host1 = "www.baidu.com";
    const char *service = NULL;
    struct addrinfo hint, *result, *next;
    memset(&hint, 0, sizeof(hint));
    hint.ai_family = AF_UNSPEC;

    int resss = origin_getaddrinfo(host1,service,&hint,&result);
    
    
    NSString *errMsg = [NSString stringWithCString:gai_strerror(result) encoding:NSASCIIStringEncoding];
    [DNSTracker trackEvent:[NTDNSEvent dnsEventWithStartTime:startDate host:host port:port addr:*res]];
    return resss;
}

struct hostent* objc_gethostbyname(const char *name)
{
    abort();
    struct hostent* result = origin_gethostbyname(name);
    return result;
}

Boolean objc_CFHostStartInfoResolution (CFHostRef theHost, CFHostInfoType info, CFStreamError *error)
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

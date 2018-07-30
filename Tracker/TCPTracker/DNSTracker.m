//
//  DNSTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "DNSTracker.h"
#import "fishhook.h"
#import <netdb.h>
#import <arpa/inet.h>

@implementation DNSTracker

int (*origin_getaddrinfo)(const char *, const char * __restrict,const struct addrinfo *,struct addrinfo **);
int32_t (*origin_dns_async_start)(int,...);
struct hostent* (*origin_gethostbyname)(const char *);
Boolean (*origin_CFHostStartInfoResolution) (CFHostRef theHost, CFHostInfoType info, CFStreamError *error);
int (*origin_res_9_query)(const char *dname, int class, int type, unsigned char *answer, int anslen);
//int32_t (*origin_dns_query)(dns_handle_t dns, const char *name, uint32_t dnsclass, uint32_t dnstype, char *buf, uint32_t len, struct sockaddr *from, uint32_t *fromlen);
int (*origin_CreateDNSLookup)(void const*);
int32_t (*origin_getaddrinfo_async_start)(mach_port_t *p, ...);

//getaddrinfo_async_start iOS 10.3

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
            "res_9_query",
            objc_res_9_query,
            (void *)&origin_res_9_query
        },
        {
            "_startTLS",
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

int objc_CreateDNSLookup(void const*value)
{
    NSLog(@"-----");
    return origin_CreateDNSLookup(value);
}

int32_t objc_getaddrinfo_async_start(mach_port_t *p,...)
{
    abort(); //iOS 10.3 NSURLConnection/UIWebView call
    int32_t result = origin_getaddrinfo_async_start(p);
    return 1;
}

int objc_res_9_query(const char *dname, int class, int type, unsigned char *answer, int anslen)
{
    abort();
    int result = origin_res_9_query(dname,class,type,answer,anslen);
    return result;
}

//int32_t objc_dns_query(dns_handle_t dns, const char *name, uint32_t dnsclass, uint32_t dnstype, char *buf, uint32_t len, struct sockaddr *from, uint32_t *fromlen)
//{
//    abort();
//    int32_t result = origin_dns_query(dns,name,dnsclass,dnstype,buf,len,from,fromlen);
//    return result;
//}

bool isValidIpAddress(const char *ipAddress)
{
    struct sockaddr_in sa;
    int result = inet_pton(AF_INET, ipAddress, &(sa.sin_addr));
    return result != 0;
}

int  objc_getaddrinfo(const char *host, const char *port,const struct addrinfo *hints,struct addrinfo ** res)
{
    struct addrinfo hint;
    if (!isValidIpAddress(host))
    {
        memset(&hint, 0, sizeof(hint));
        hint.ai_family = hints->ai_family;
        hint.ai_socktype = hints->ai_socktype;
        hint.ai_protocol = hints->ai_protocol;
    }else{
        hint = *hints;
    }
    NSDate *startDate = [NSDate date];
    int result = origin_getaddrinfo(host,port,&hint,res);
    [DNSTracker trackEvent:[NTDNSEvent dnsEventWithStartTime:startDate host:host port:port addr:*res]];
    return result;
}

struct hostent* objc_gethostbyname(const char *name)
{
    abort();
    struct hostent* result = origin_gethostbyname(name);
    return result;
}

int32_t objc_dns_async_start(int a,...)
{
    abort();
//    int32_t result = origin_dns_async_start(p,name,dnsclass,dnstype,do_search,callback,context);
//    return result;
    return 0;
}

@end

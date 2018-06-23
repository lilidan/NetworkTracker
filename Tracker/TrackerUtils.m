//
//  TrackerUtils.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/21.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TrackerUtils.h"
#import <arpa/inet.h>
#import <fcntl.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <net/if.h>
#import <sys/socket.h>
#import <sys/types.h>

@implementation TrackerUtils

+ (NSString *)hostFromSockaddr4:(const struct sockaddr_in *)pSockaddr4
{
    char addrBuf[INET_ADDRSTRLEN];
    
    if (inet_ntop(AF_INET, &pSockaddr4->sin_addr, addrBuf, (socklen_t)sizeof(addrBuf)) == NULL)
    {
        addrBuf[0] = '\0';
    }
    
    return [NSString stringWithCString:addrBuf encoding:NSASCIIStringEncoding];
}

+ (NSString *)connectedHostFromSocket4:(int)socketFD
{
    struct sockaddr_in sockaddr4;
    socklen_t sockaddr4len = sizeof(sockaddr4);
    int result = getpeername(socketFD, (struct sockaddr *)&sockaddr4, &sockaddr4len);
    if (result < 0)
    {
        return nil;
    }
    uint16_t port = [self portFromSockaddr4:&sockaddr4];
    NSString *host = [self hostFromSockaddr4:&sockaddr4];
    return [NSString stringWithFormat:@"%@:%d",host,port];
}

+ (uint16_t)portFromSockaddr4:(const struct sockaddr_in *)pSockaddr4
{
    return ntohs(pSockaddr4->sin_port);
}


@end

//
//  SocketTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "SocketTracker.h"
#import "TrackerUtils.h"

@implementation SocketTracker

ssize_t (*origin_send)(int, const void *, size_t, int);
ssize_t (*origin_recv)(int, void *, size_t, int);
ssize_t (*origin_read)(int, void *, size_t);
ssize_t (*origin_write)(int, const void *, size_t);
int  (*origin_connect)(int, const struct sockaddr *, socklen_t);
+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[4]){
        {
            "send",
            objc_send,
            (void *)&origin_send
        },
        {
            "recv",
            objc_recv,
            (void *)&origin_recv
        },
        {
            "write",
            objc_write,
            (void *)&origin_write
        },
        {
            "read",
            objc_read,
            (void *)&origin_read
        },
        {
            "connect",
            objc_connect,
            (void *)&origin_connect
        }
    }, 4);
}

static int objc_connect(int fd, const struct sockaddr *addr, socklen_t length)
{
    int result = origin_connect(fd, addr, length);
    if (result == 0) {
        NSString *host = [TrackerUtils connectedHostFromSocket4:fd];
        [SocketTracker cacheRemoteHost:host fd:fd];
    }
    return result;
}

static ssize_t objc_send(int fd, const void *buffer, size_t size, int d)
{
    ssize_t result = origin_send(fd, buffer, size, d);
    [SocketTracker trackwrite:buffer  length:size result:result fd:fd];
    return result;
}

static ssize_t objc_recv(int fd, void *buffer, size_t size, int d)
{
    ssize_t result = origin_recv(fd, buffer, size, d);
    [SocketTracker trackRead:buffer length:size result:result fd:fd];
    return result;
}

static ssize_t objc_write(int fd, const void *buffer, size_t size)
{
    ssize_t result = origin_write(fd, buffer, size);
    [SocketTracker trackwrite:buffer  length:size result:result fd:fd];
    return result;
}

static ssize_t objc_read(int fd, void *buffer, size_t size)
{
    ssize_t result = origin_read(fd, buffer, size);
    [SocketTracker trackRead:buffer length:size result:result fd:fd];
    return result;
}




@end

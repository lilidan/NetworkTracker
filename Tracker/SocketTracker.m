//
//  SocketTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "SocketTracker.h"

@implementation SocketTracker

ssize_t (*origin_send)(int, const void *, size_t, int);
ssize_t (*origin_recv)(int, void *, size_t, int);
ssize_t (*origin_read)(int, void *, size_t);
ssize_t (*origin_write)(int, const void *, size_t);
                 
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
        
    }, 4);
}


static ssize_t objc_send(int fd, const void *buffer, size_t size, int d)
{
    [SocketTracker trackwrite:buffer  length:size fd:fd];
    return origin_send(fd, buffer, size, d);
}

static ssize_t objc_recv(int fd, void *buffer, size_t size, int d)
{
    [SocketTracker trackRead:buffer length:size fd:fd];
    return origin_recv(fd, buffer, size, d);
}

static ssize_t objc_write(int fd, const void *buffer, size_t size)
{
    [SocketTracker trackwrite:buffer  length:size fd:fd];
    return origin_write(fd, buffer, size);
}

static ssize_t objc_read(int fd, void *buffer, size_t size)
{
    [SocketTracker trackRead:buffer length:size fd:fd];
    return origin_read(fd, buffer, size);
}




@end

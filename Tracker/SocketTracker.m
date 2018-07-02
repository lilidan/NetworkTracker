//
//  SocketTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/20.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "SocketTracker.h"
#import "TrackerUtils.h"
#import <sys/socket.h>

@implementation SocketTracker

int  (*origin_connect)(int, const struct sockaddr *, socklen_t);
int  (*origin_accept)(int, struct sockaddr *, socklen_t *);
int  (*origin_bind)(int, const struct sockaddr *, socklen_t);
int  shutdown(int, int);

ssize_t (*origin_send)(int, const void *, size_t, int);
ssize_t (*origin_recv)(int, void *, size_t, int);
ssize_t (*origin_read)(int, void *, size_t);
ssize_t (*origin_write)(int, const void *, size_t);

ssize_t (*origin_sendmsg)(int, const struct msghdr *, int);
ssize_t (*origin_recvmsg)(int, struct msghdr *, int);
ssize_t (*origin_sendto)(int, const void *, size_t,
                  int, const struct sockaddr *, socklen_t);
ssize_t (*origin_recvfrom)(int, void *, size_t, int, struct sockaddr *,socklen_t *);


+ (void)load
{
    rcd_rebind_symbols((struct rcd_rebinding[11]){
        {
            "accept",
            objc_accept,
            (void *)&origin_accept
        },
        {
            "bind",
            objc_bind,
            (void *)&origin_bind
        },
        {
            "connect",
            objc_connect,
            (void *)&origin_connect
        },
        {
            "recvmsg",
            objc_recvmsg,
            (void *)&origin_recvmsg
        },
        {
            "sendmsg",
            objc_sendmsg,
            (void *)&origin_sendmsg
        },
        {
            "sendto",
            objc_sendto,
            (void *)&origin_sendto
        },
        {
            "recvfrom",
            objc_recvfrom,
            (void *)&origin_recvfrom
        },
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
        }
    }, 11);
}

static int objc_accept(int fd, struct sockaddr *addr, socklen_t *length)
{
    int result = origin_accept(fd,addr,length);
    return result;
}

static int objc_bind(int fd, const struct sockaddr *addr, socklen_t length)
{
    int result = origin_bind(fd,addr,length);
    return result;
}

static int objc_connect(int fd, const struct sockaddr *addr, socklen_t length)
{
    NSDate *startTime = [NSDate date];
    int result = origin_connect(fd, addr, length);
    [SocketTracker trackEvent:[NTTrackEvent socketEventWithType:TrackEventActionTypeConnect startTime:startTime fd:fd addr:(struct sockaddr_in *)addr]];
    return result;
}

ssize_t objc_sendmsg(int fd, const struct msghdr *msg, int flags)
{
    NSDate *startTime = [NSDate date];
    ssize_t result = origin_sendmsg(fd,msg,flags);
    [SocketTracker trackEvent:[NTTrackEvent socketEventWithType:TrackEventActionTypeWrite startTime:startTime fd:fd msg:(struct msghdr *)msg]];
    return result;
}

ssize_t objc_recvmsg(int fd, struct msghdr *msg, int flags)
{
    NSDate *startTime = [NSDate date];
    ssize_t result = origin_recvmsg(fd,msg,flags);
    [SocketTracker trackEvent:[NTTrackEvent socketEventWithType:TrackEventActionTypeRead startTime:startTime fd:fd msg:(struct msghdr *)msg]];
    return result;
}

ssize_t objc_sendto(int fd, const void *buffer, size_t size,int flags, const struct sockaddr *addr, socklen_t length)
{
    ssize_t result = origin_sendto(fd,buffer,size,flags,addr,length);
    return result;
}

ssize_t objc_recvfrom(int fd,void *buffer, size_t size,int flags,struct sockaddr *addr, socklen_t *length)
{
    ssize_t result = origin_recvfrom(fd,buffer,size,flags,addr,length);
    return result;
}


static ssize_t objc_send(int fd, const void *buffer, size_t size, int d)
{
    NSDate *startTime = [NSDate date];
    ssize_t result = origin_send(fd, buffer, size, d);
    [SocketTracker trackEvent:[NTTrackEvent socketEventWithType:TrackEventActionTypeWrite startTime:startTime fd:fd buffer:buffer length:size]];
    return result;
}

static ssize_t objc_recv(int fd, void *buffer, size_t size, int d)
{
    NSDate *startTime = [NSDate date];
    ssize_t result = origin_recv(fd, buffer, size, d);
    [SocketTracker trackEvent:[NTTrackEvent socketEventWithType:TrackEventActionTypeRead startTime:startTime fd:fd buffer:buffer length:size]];
    return result;
}

static ssize_t objc_write(int fd, const void *buffer, size_t size)
{
    NSDate *startTime = [NSDate date];
    ssize_t result = origin_write(fd, buffer, size);
    [SocketTracker trackEvent:[NTTrackEvent socketEventWithType:TrackEventActionTypeWrite startTime:startTime fd:fd buffer:buffer length:size]];
    return result;
}

static ssize_t objc_read(int fd, void *buffer, size_t size)
{
    NSDate *startTime = [NSDate date];
    ssize_t result = origin_read(fd, buffer, size);
    [SocketTracker trackEvent:[NTTrackEvent socketEventWithType:TrackEventActionTypeRead startTime:startTime fd:fd buffer:buffer length:size]];
    return result;
}

@end

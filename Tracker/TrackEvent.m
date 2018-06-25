//
//  TrackEvent.m
//  breakWork
//
//  Created by sgcy on 2018/6/25.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "TrackEvent.h"
#import "TrackerUtils.h"
#import <sys/socket.h>

@interface TrackEvent()

@property (nonatomic,assign) int fd;

//TODO:待用
@property (nonatomic,strong) NSString *host;
@property (nonatomic,assign) int port;
@property (nonatomic,strong) NSString *domain;

@end

@implementation TrackEvent

- (instancetype)initWithFd:(int)fd addr:(struct sockaddr_in *)addr
{
    return [self initWithType:TrackerEventTypeConnect fd:fd addr:addr];
}

- (instancetype)initWithType:(TrackerEventType)type fd:(int)fd addr:(struct sockaddr_in *)addr
{
    return [self initWithType:type fd:fd msg:NULL addr:addr buffer:NULL length:0];
}

- (instancetype)initWithType:(TrackerEventType)type fd:(int)fd buffer:(const void *)buffer length:(size_t)length
{
    return [self initWithType:type fd:fd msg:NULL addr:NULL buffer:buffer length:length];
}

- (instancetype)initWithType:(TrackerEventType)type fd:(int)fd msg:(struct msghdr *)msg
{
    return [self initWithType:type fd:fd msg:msg addr:NULL buffer:NULL length:0];
}

- (instancetype)initWithType:(TrackerEventType)type fd:(int)fd msg:(struct msghdr *)msg addr:(struct sockaddr_in *)addr buffer:(const void *)buffer length:(size_t)length
{
    if (self = [super init]) {
        _type = type;
        _fd = fd;
        
        if (addr != NULL) {
            _url = [TrackerUtils hostFromSockaddr4:addr];
        }else{
            _url = [TrackerUtils hostPortFromSocket4:fd];
        }
        
        if (!_url) {
            _url = @"unknown URL";
            return self; //如果URL获取不到的话直接返回好了
        }
        
        //有URL 才记录
        if (buffer != NULL) {
            _data = [[NSData alloc] initWithBytes:buffer length:length];
            _content = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        }else if (msg != NULL){
            _content = [[NSString alloc] initWithBytes:msg->msg_iov->iov_base length:msg->msg_iov->iov_len encoding:NSUTF8StringEncoding];
        }
    }
    return self;
}

@end



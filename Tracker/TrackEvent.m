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

#pragma mark - socket

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
//            return self; //如果URL获取不到的话直接返回好了
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

# pragma mark - CFStream

- (instancetype)initWithType:(TrackerEventType)type stream:(void *)stream
{
    return [self initWithType:type buffer:NULL length:0 stream:stream];
}

- (instancetype)initWithType:(TrackerEventType)type buffer:(const void *)buffer length:(size_t)length stream:(void *)stream
{
    if (self = [super init]) {
        _type = type;
        
        if (type == TrackerEventTypeCFRequest || type == TrackerEventTypeCFRequestOpen || type == TrackerEventTypeCFRequestListen) {
            NSData *fd = (__bridge NSData *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
            _fd = [[[NSString alloc] initWithData:fd encoding:NSUTF8StringEncoding] intValue];;
            _host = (__bridge NSString *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
            NSString *port = (__bridge NSString *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketRemotePortNumber);
            _url = [NSString stringWithFormat:@"%@:%@",_host,port];
        }else if (type == TrackerEventTypeCFResponse || type == TrackerEventTypeCFResponseOpen || type == TrackerEventTypeCFResponseListen){
            NSData *fd = (__bridge NSData *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
            _fd = [[[NSString alloc] initWithData:fd encoding:NSUTF8StringEncoding] intValue];;
            _host = (__bridge NSString *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
            NSString *port = (__bridge NSString *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketRemotePortNumber);
            _url = [NSString stringWithFormat:@"%@:%@",_host,port];
        }else{
            // SSL
            const void *peerIdPtr;
            size_t peerLen;
            OSStatus getId = SSLGetPeerID(stream, &peerIdPtr, &peerLen);
            if (getId == 0) {
                NSData *peerIdData = [[NSData alloc] initWithBytes:peerIdPtr length:peerLen];
                NSString *peerIdStr = [[NSString alloc] initWithData:peerIdData encoding:NSUTF8StringEncoding];
                _fd = peerIdStr.intValue;
            }
            size_t domainLen;
            SSLGetPeerDomainNameLength(stream,&domainLen);
            char domainPtr[domainLen];
            OSStatus getDomain = SSLGetPeerDomainName(stream, domainPtr, &domainLen);
            if (getDomain == 0) {
                NSString *domainStr = [[NSString alloc] initWithUTF8String:domainPtr];
                _url = _host = domainStr;
            }
        }
        
        if (!_host) {
            _url = @"unknown URL";
//            return self; //如果URL获取不到的话直接返回好了
        }
        
        //有URL 才记录
        _data = [[NSData alloc] initWithBytes:buffer length:length];
        _content = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[NAME]:%@ - [FD]:%d - [TYPE]:%lu - [URL]:%@ - [CONTENT]:%@",_trackerName,_fd,(unsigned long)_type,_url,_content];
}

@end



//
//  TrackEvent.m
//  breakWork
//
//  Created by sgcy on 2018/6/25.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTTrackEvent.h"
#import "TrackerUtils.h"
#import <sys/socket.h>
#import "DataKeeper.h"

@interface NTTrackEvent()

@property (nonatomic,assign) int fd;

//TODO:待用
@property (nonatomic,strong) NSString *host;
@property (nonatomic,assign) int port;
@property (nonatomic,strong) NSString *domain;

@end

@implementation NTTrackEvent

#pragma mark - socket


+ (instancetype)socketEventWithType:(NSUInteger)type fd:(int)fd addr:(struct sockaddr_in *)addr
{
    return [[self alloc] initWithType:type fd:fd msg:NULL addr:addr buffer:NULL length:0];
}

+ (instancetype)socketEventWithType:(NSUInteger)type fd:(int)fd buffer:(const void *)buffer length:(size_t)length
{
    return [[self alloc] initWithType:type fd:fd msg:NULL addr:NULL buffer:buffer length:length];
}

+ (instancetype)socketEventWithType:(TrackEventActionType)type fd:(int)fd msg:(struct msghdr *)msg
{
    return [[self alloc] initWithType:type fd:fd msg:msg addr:NULL buffer:NULL length:0];
}

- (instancetype)initWithType:(TrackEventActionType)type fd:(int)fd msg:(struct msghdr *)msg addr:(struct sockaddr_in *)addr buffer:(const void *)buffer length:(size_t)length
{
    if (self = [super init]) {
        _sourceType = TrackEventSourceTypeSocket;
        _actionType = type;
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

# pragma mark - CFStream

+ (instancetype)streamEventWithType:(TrackEventActionType)type stream:(void *)stream
{
    return [[self alloc] initWithType:type buffer:NULL length:0 stream:stream];
}

+ (instancetype)streamEventWithType:(TrackEventActionType)type buffer:(const void *)buffer length:(size_t)length stream:(void *)stream;
{
    return [[self alloc] initWithType:type buffer:buffer length:length stream:stream];
}

- (instancetype)initWithType:(NSUInteger)type buffer:(const void *)buffer length:(size_t)length stream:(void *)stream
{
    if (self = [super init]) {
        _sourceType = TrackEventSourceTypeCF;
        _actionType = type % 10;

        if (type & TrackEventActionTypeCFWrite ) {
            NSData *fd = (__bridge NSData *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
            _fd = [[[NSString alloc] initWithData:fd encoding:NSUTF8StringEncoding] intValue];;
            _host = (__bridge NSString *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
            NSString *port = (__bridge NSString *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketRemotePortNumber);
            _url = [NSString stringWithFormat:@"%@:%@",_host,port];
        }else if (type & TrackEventActionTypeCFRead){
            NSData *fd = (__bridge NSData *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
            _fd = [[[NSString alloc] initWithData:fd encoding:NSUTF8StringEncoding] intValue];;
            _host = (__bridge NSString *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
            NSString *port = (__bridge NSString *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketRemotePortNumber);
            _url = [NSString stringWithFormat:@"%@:%@",_host,port];
        }
        if (!_host) {
            _url = @"unknown URL";
            return self; //如果URL获取不到的话直接返回好了
        }
        
        if (buffer != NULL) {
            _data = [[NSMutableData alloc] initWithBytes:buffer length:length];
            _content = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        }
    }
    return self;
}

# pragma mark - SSL
+ (instancetype)sslEventWithType:(TrackEventActionType)type context:(SSLContextRef)context
{
    return [[self alloc] initWithType:type buffer:NULL length:0 context:context];
}
+ (instancetype)sslEventWithType:(TrackEventActionType)type buffer:(const void *)buffer length:(size_t)length context:(SSLContextRef)context
{
    return [[self alloc] initWithType:type buffer:buffer length:length context:context];
}

- (instancetype)initWithType:(TrackEventActionType)type buffer:(const void *)buffer length:(size_t)length context:(SSLContextRef)context

{
    if (self = [super init]) {
        
        _actionType = type;
        _sourceType = TrackEventSourceTypeSSL;
        
        const void *peerIdPtr;
        size_t peerLen;
        OSStatus getId = SSLGetPeerID(context, &peerIdPtr, &peerLen);
        if (getId == 0) {
            NSData *peerIdData = [[NSData alloc] initWithBytes:peerIdPtr length:peerLen];
            NSString *peerIdStr = [[NSString alloc] initWithData:peerIdData encoding:NSUTF8StringEncoding];
            _fd = peerIdStr.intValue;
        }
        size_t domainLen;
        SSLGetPeerDomainNameLength(context,&domainLen);
        char domainPtr[domainLen];
        OSStatus getDomain = SSLGetPeerDomainName(context, domainPtr, &domainLen);
        if (getDomain == 0) {
            NSString *domainStr = [[NSString alloc] initWithUTF8String:domainPtr];
            _url = _host = domainStr;
        }
        
        if (!_host) {
            _url = @"unknown URL";
            return self; //如果URL获取不到的话直接返回好了
        }
        
        if (buffer != NULL) {
            _data = [[NSMutableData alloc] initWithBytes:buffer length:length];
            _content = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        }
    }
    return self;
}


@end



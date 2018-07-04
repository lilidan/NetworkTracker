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
#import "netdb.h"

@implementation NTEventBase

@end


@interface NTTrackEvent()

@property (nonatomic,assign) int fd;

@end

@implementation NTTrackEvent

- (instancetype)initWithType:(TrackEventActionType)type startTime:(NSDate *)startTime
{
    if (self = [super init]) {
        _actionType = type;
        self.startTime = startTime;
        self.endTime = [NSDate date];
    }
    return self;
}

- (void)setUpWithBuffer:(const void *)buffer length:(size_t)length
{
    if (buffer != NULL && self.host != nil) {
        _data = [[NSData alloc] initWithBytes:buffer length:length];
        _content = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    }
}

#pragma mark - socket


+ (instancetype)socketEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime fd:(int)fd addr:(struct sockaddr_in *)addr
{
    return [[self alloc] initWithType:type startTime:startTime fd:fd msg:NULL addr:addr buffer:NULL length:0];
}

+ (instancetype)socketEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime fd:(int)fd buffer:(const void *)buffer length:(size_t)length
{
    return [[self alloc] initWithType:type startTime:startTime fd:fd msg:NULL addr:NULL buffer:buffer length:length];
}

+ (instancetype)socketEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime fd:(int)fd msg:(struct msghdr *)msg
{
    return [[self alloc] initWithType:type startTime:startTime fd:fd msg:msg addr:NULL buffer:NULL length:0];
}

- (instancetype)initWithType:(TrackEventActionType)type startTime:(NSDate *)startTime fd:(int)fd msg:(struct msghdr *)msg addr:(struct sockaddr_in *)addr buffer:(const void *)buffer length:(size_t)length
{
    if (self = [self initWithType:type startTime:startTime]) {
        _sourceType = TrackEventSourceTypeSocket;
        _fd = fd;

        if (addr != NULL) {
            _hostPort = [TrackerUtils hostPortFromSockaddr4:addr];
        }else{
            _hostPort = [TrackerUtils hostPortFromSocket4:fd];
        }
        
        if (_hostPort) {
            NSArray *seps = [_hostPort componentsSeparatedByString:@":"];
            if (seps.count > 0) {
                _host = seps[0];
            }
        }
        
        [self setUpWithBuffer:buffer length:length];
    }
    return self;
}

# pragma mark - CFStream

+ (instancetype)streamEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime stream:(void *)stream
{
    return [[self alloc] initWithType:type startTime:startTime buffer:NULL length:0 stream:stream];
}

+ (instancetype)streamEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime buffer:(const void *)buffer length:(size_t)length stream:(void *)stream;
{
    return [[self alloc] initWithType:type startTime:startTime buffer:buffer length:length stream:stream];
}

- (instancetype)initWithType:(TrackEventActionType)type startTime:(NSDate *)startTime buffer:(const void *)buffer length:(size_t)length stream:(void *)stream
{
    if (self = [self initWithType:type startTime:startTime]) {
        _sourceType = TrackEventSourceTypeCF;

        if (type > 2 ) {
            NSData *fd = (__bridge NSData *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
            _fd = [[[NSString alloc] initWithData:fd encoding:NSUTF8StringEncoding] intValue];;
            _host = (__bridge NSString *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
            NSString *port = (__bridge NSString *)CFWriteStreamCopyProperty(stream,kCFStreamPropertySocketRemotePortNumber);
            if (_host) {
                _hostPort = [NSString stringWithFormat:@"%@:%@",_host,port];
            }
        }else{
            NSData *fd = (__bridge NSData *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketNativeHandle);
            _fd = [[[NSString alloc] initWithData:fd encoding:NSUTF8StringEncoding] intValue];;
            _host = (__bridge NSString *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketRemoteHostName);
            NSString *port = (__bridge NSString *)CFReadStreamCopyProperty(stream,kCFStreamPropertySocketRemotePortNumber);
            if (_host) {
                _hostPort = [NSString stringWithFormat:@"%@:%@",_host,port];
            }
        }
        
        [self setUpWithBuffer:buffer length:length];
    }
    return self;
}

# pragma mark - SSL
+ (instancetype)sslEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime context:(SSLContextRef)context
{
    return [[self alloc] initWithType:type startTime:startTime buffer:NULL length:0 context:context];
}
+ (instancetype)sslEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime buffer:(const void *)buffer length:(size_t)length context:(SSLContextRef)context
{
    return [[self alloc] initWithType:type startTime:startTime buffer:buffer length:length context:context];
}

- (instancetype)initWithType:(TrackEventActionType)type startTime:(NSDate *)startTime buffer:(const void *)buffer length:(size_t)length context:(SSLContextRef)context

{
    if (self = [self initWithType:type startTime:startTime]) {
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
            _host = domainStr;
        }
        
        [self setUpWithBuffer:buffer length:length];
    }
    return self;
}

@end



@implementation NTDNSEvent


+ (instancetype)dnsEventWithStartTime:(NSDate *)startTime host:(const char *)host port:(const char *)port addr:(struct addrinfo *)addr
{
    return [[self alloc] initWithStartTime:startTime host:host port:port addr:addr];
}

- (instancetype)initWithStartTime:(NSDate *)startTime host:(const char *)host port:(const char *)port addr:(struct addrinfo *)addr
{
    if (self = [super init]) {
        self.startTime = startTime;
        self.endTime = [NSDate date];
        
        _url = [[NSString alloc] initWithCString:host encoding:NSUTF8StringEncoding];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        struct addrinfo *res;
        struct addrinfo *res0 = addr;

        for (res = res0; res; res = res->ai_next)
        {
            if (res->ai_family == AF_INET)
            {
                NSString *result = [TrackerUtils hostFromSockaddr4:(struct sockaddr_in *)res->ai_addr];
                if (result) {
                    [results addObject:result];
                }
            }
        }
        _results = [results copy];
    }
    return self;
}

@end



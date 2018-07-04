//
//  TrackEvent.h
//  breakWork
//
//  Created by sgcy on 2018/6/25.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TrackEventActionType) {
    TrackEventActionTypeConnect = 0,
    TrackEventActionTypeClose,
    TrackEventActionTypeRead,
    TrackEventActionTypeWrite,
    TrackEventActionTypeCFWriteConnect, //if CoreFoundation, defalt connect/close matches CFReadOpen/CFReadClose
    TrackEventActionTypeCFWriteClose
};

typedef NS_ENUM(NSUInteger, TrackEventSourceType) {
    TrackEventSourceTypeSocket = 0, //BSD socket
    TrackEventSourceTypeCF,
    TrackEventSourceTypeSSL
};


@interface NTEventBase : NSObject

@property (nonatomic,strong) NSDate *startTime;
@property (nonatomic,strong) NSDate *endTime;

@end

@interface NTTrackEvent : NTEventBase

@property (nonatomic,assign) TrackEventActionType actionType;
@property (nonatomic,assign) TrackEventSourceType sourceType;

@property (nonatomic,strong) NSString *hostPort;
@property (nonatomic,strong) NSString *host;
//@property (nonatomic,assign) int port;

@property (nonatomic,strong) NSData *data;
@property (nonatomic,strong) NSString *content;

// for socket
+ (instancetype)socketEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime fd:(int)fd addr:(struct sockaddr_in *)addr ;
+ (instancetype)socketEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime fd:(int)fd buffer:(const void *)buffer length:(size_t)length;//socket:read/write
+ (instancetype)socketEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime fd:(int)fd msg:(struct msghdr *)msg; //socket:msg

// for CFStream
+ (instancetype)streamEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime stream:(void *)stream;
+ (instancetype)streamEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime buffer:(const void *)buffer length:(size_t)length stream:(void *)stream;

// for SSL
+ (instancetype)sslEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime context:(SSLContextRef)context;
+ (instancetype)sslEventWithType:(TrackEventActionType)type startTime:(NSDate *)startTime buffer:(const void *)buffer length:(size_t)length context:(SSLContextRef)context;

@end


@interface NTDNSEvent : NTEventBase

@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSArray *results;


// for DNS
+ (instancetype)dnsEventWithStartTime:(NSDate *)startTime host:(const char *)host port:(const char *)port addr:(struct addrinfo *)addr;

@end

//
//  TrackEvent.h
//  breakWork
//
//  Created by sgcy on 2018/6/25.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TrackEventActionType) {
    TrackEventActionTypeConnect = 1<<0,
    TrackEventActionTypeWrite = 1<<1,
    TrackEventActionTypeRead = 1<<2,
    TrackEventActionTypeClose = 1<<3,
    
    TrackEventTimeTypeBegin = 1<<5,
    TrackEventTimeTypeEnd = 1<<6,
    
    TrackEventActionTypeCFRead = 1 << 7,//core foundation
    TrackEventActionTypeCFWrite = 1 << 8
};

typedef NS_ENUM(NSUInteger, TrackEventSourceType) {
    TrackEventSourceTypeSocket = 0, //BSD socket
    TrackEventSourceTypeCF,
    TrackEventSourceTypeSSL
};

@interface NTTrackEvent : NSObject

@property (nonatomic,assign) TrackEventActionType actionType;
@property (nonatomic,assign) TrackEventSourceType sourceType;

@property (nonatomic,strong) NSString *url;

@property (nonatomic,strong) NSData *data;
@property (nonatomic,strong) NSString *content;

// for socket
+ (instancetype)socketEventWithType:(TrackEventActionType)type fd:(int)fd addr:(struct sockaddr_in *)addr;
+ (instancetype)socketEventWithType:(TrackEventActionType)type fd:(int)fd buffer:(const void *)buffer length:(size_t)length;//socket:read/write
+ (instancetype)socketEventWithType:(TrackEventActionType)type fd:(int)fd msg:(struct msghdr *)msg; //socket:msg

// for CFStream
+ (instancetype)streamEventWithType:(TrackEventActionType)type stream:(void *)stream;
+ (instancetype)streamEventWithType:(TrackEventActionType)type buffer:(const void *)buffer length:(size_t)length stream:(void *)stream;

// for SSL
+ (instancetype)sslEventWithType:(TrackEventActionType)type context:(SSLContextRef)context;
+ (instancetype)sslEventWithType:(TrackEventActionType)type buffer:(const void *)buffer length:(size_t)length context:(SSLContextRef)context;


@end

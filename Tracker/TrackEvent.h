//
//  TrackEvent.h
//  breakWork
//
//  Created by sgcy on 2018/6/25.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, TrackerEventType) {
    TrackerEventTypeConnect = 0,
    TrackerEventTypeRequest,
    TrackerEventTypeResponse,
    TrackerEventTypeRequestMsg,
    TrackerEventTypeCFRequest,
    TrackerEventTypeCFResponse,
    TrackerEventTypeCFRequestOpen,
    TrackerEventTypeCFResponseOpen,
    TrackerEventTypeSSLHandshake,
    TrackerEventTypeSSLRequest,
    TrackerEventTypeSSLResponse
};

@interface TrackEvent : NSObject

@property (nonatomic,strong) NSString *trackerName;
@property (nonatomic,assign) TrackerEventType type;

@property (nonatomic,strong) NSString *url;

@property (nonatomic,strong) NSData *data;
@property (nonatomic,strong) NSString *content;

// for socket
- (instancetype)initWithFd:(int)fd addr:(struct sockaddr_in *)addr;//connect
- (instancetype)initWithType:(TrackerEventType)type fd:(int)fd addr:(struct sockaddr_in *)addr;
- (instancetype)initWithType:(TrackerEventType)type fd:(int)fd buffer:(const void *)buffer length:(size_t)length;//socket:read/write
- (instancetype)initWithType:(TrackerEventType)type fd:(int)fd msg:(struct msghdr *)msg; //socket:msg

// for CFStream/SSL
- (instancetype)initWithType:(TrackerEventType)type stream:(void *)stream;
- (instancetype)initWithType:(TrackerEventType)type buffer:(const void *)buffer length:(size_t)length stream:(void *)stream;


@end

//
//  BaseTracker.h
//  FortunePlat
//
//  Created by sgcy on 2018/6/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fishhook.h"

@interface BaseTracker : NSObject

@property (nonatomic,strong) NSMutableData *data;

+ (void)hook;
+ (void)trackRead:(const void *)buffer length:(size_t)length result:(ssize_t)result fd:(int)fd;
+ (void)trackwrite:(const void *)buffer length:(size_t)length result:(ssize_t)result fd:(int)fd;
+ (void)cacheRemoteHost:(NSString *)host fd:(int)fd;

@end

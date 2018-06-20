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
+ (void)trackRead:(const void *)data length:(size_t)length fd:(int)fd;
+ (void)trackwrite:(const void *)data length:(size_t)length fd:(int)fd;

@end

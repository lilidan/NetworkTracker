//
//  BaseTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "BaseTracker.h"

@interface BaseTracker()


@end


@implementation BaseTracker

+ (void)load
{
    [self hook];
}

+ (void)hook
{
    
}

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    static BaseTracker* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[BaseTracker alloc] init];
    });
    return sharedInstance;
}


+ (void)trackRead:(const void *)data length:(size_t)length fd:(int)fd
{
    
}

+ (void)trackwrite:(const void *)data length:(size_t)length fd:(int)fd
{
    
}





@end

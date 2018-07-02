//
//  BaseTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "BaseTracker.h"
#import "TrackerUtils.h"
#import "NTDataKeeper.h"

@interface BaseTracker()

@end


@implementation BaseTracker


+ (void)trackEvent:(NTEventBase *)event
{
    [[NTDataKeeper shareInstance] trackEvent:event];
}

@end

//
//  BaseTracker.h
//  FortunePlat
//
//  Created by sgcy on 2018/6/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fishhook.h"
#import "TrackEvent.h"

@interface BaseTracker : NSObject

+ (void)hook;

+ (void)trackEvent:(TrackEvent *)event;


@end

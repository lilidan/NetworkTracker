//
//  BaseTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "BaseTracker.h"
#import "TrackerUtils.h"

@interface BaseTracker()

@property (nonatomic,strong) NSMutableDictionary *cachedHost;

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
        sharedInstance.cachedHost = [[NSMutableDictionary alloc] init];
    });
    return sharedInstance;
}

+ (void)cacheRemoteHost:(NSString *)host fd:(int)fd
{
    [[[self shareInstance] cachedHost] setObject:host forKey:@(fd)];
    NSLog(@"%@",[[self shareInstance] cachedHost]);
}

+ (void)trackEvent:(TrackEvent *)event
{

}


@end

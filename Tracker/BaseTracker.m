//
//  BaseTracker.m
//  FortunePlat
//
//  Created by sgcy on 2018/6/19.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "BaseTracker.h"


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
}

+ (void)trackRead:(const void *)buffer length:(size_t)length result:(ssize_t)result fd:(int)fd
{
    NSString *host = [[[self shareInstance] cachedHost] objectForKey:@(fd)];
    if (host && ![host isEqualToString:@"8.8.8.8"]) {
        NSData *data = [[NSData alloc] initWithBytes:buffer length:length];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"[READ]:%@----%@",host,str);
    }
}

+ (void)trackwrite:(const void *)buffer length:(size_t)length result:(ssize_t)result fd:(int)fd
{
    NSString *host = [[[self shareInstance] cachedHost] objectForKey:@(fd)];
    if (host && ![host isEqualToString:@"8.8.8.8"]) {
        NSData *data = [[NSData alloc] initWithBytes:buffer length:length];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"[WRITE]:%@----%@",host,str);
    }
}





@end

//
//  TrackerUtils.h
//  FortunePlat
//
//  Created by sgcy on 2018/6/21.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackerUtils : NSObject

+ (NSString *)hostFromSockaddr4:(const struct sockaddr_in *)pSockaddr4;
+ (uint16_t)portFromSockaddr4:(const struct sockaddr_in *)pSockaddr4;

+ (NSString *)hostPortFromSockaddr4:(const struct sockaddr_in *)pSockaddr4;
+ (NSString *)hostPortFromSocket4:(int)socketFD;

@end

//
//  NTDataKeeper.h
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTDataKeeper : NSObject

+ (instancetype)shareInstance;

- (void)trackSessionMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0));

@end

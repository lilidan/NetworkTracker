//
//  NTDataKeeper.h
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTHTTPModel.h"
#import "NTWebModel.h"
#import "NTTCPModel.h"


@interface NTDataKeeper : NSObject

@property (nonatomic,strong) NSMutableArray<NTHTTPModel *> *httpModels;
@property (nonatomic,strong) NSMutableArray<NTWebModel *> *webModels;
@property (nonatomic,strong) NSMutableArray<NTTCPModel *> *tcpModels;

+ (instancetype)shareInstance;

- (void)trackSessionMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0));
- (void)trackWebViewTimingStr:(NSString *)timingStr request:(NSURLRequest *)request;
- (void)trackEvent:(NTEventBase *)baseEvent;

@end

//
//  NTDataKeeper.m
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTDataKeeper.h"
#import "NTHTTPModel.h"
#import "NTWebModel.h"

@interface NTDataKeeper()

@property (nonatomic,strong) NSMutableArray<NTHTTPModel *> *httpModels;
@property (nonatomic,strong) NSMutableArray<NTWebModel *> *webModels;

@end

@implementation NTDataKeeper

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    static NTDataKeeper* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[NTDataKeeper alloc] init];
    });
    return sharedInstance;
}

- (void)trackSessionMetrics:(NSURLSessionTaskMetrics *)metrics
API_AVAILABLE(ios(10.0)){
    for (NSURLSessionTaskTransactionMetrics *transMetric in metrics.transactionMetrics) {
        //TODO: metrics 还有startDate、duration、redirectCount参数，可以识别为同一个request的redirect
        if (transMetric.resourceFetchType == NSURLSessionTaskMetricsResourceFetchTypeNetworkLoad) {
            NTHTTPModel *model = [[NTHTTPModel alloc] initWithTransactionMetrics:transMetric];
            [self.httpModels addObject:model];
        }
    }
}

- (void)trackWebViewTimingStr:(NSString *)timingStr request:(NSURLRequest *)request
{
    if (request) {
        NTWebModel *model = [[NTWebModel alloc] initWithJsonStr:timingStr request:request];
        [self.webModels addObject:model];
    }
}

@end

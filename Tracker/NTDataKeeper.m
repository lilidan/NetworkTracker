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
#import "NTTCPModel.h"
#import "NTTrackEvent.h"

@interface NTDataKeeper()

@property (nonatomic,strong) NSMutableArray<NTHTTPModel *> *httpModels;
@property (nonatomic,strong) NSMutableArray<NTWebModel *> *webModels;
@property (nonatomic,strong) NSMutableArray<NTTCPModel *> *tcpModels;
@property (nonatomic,strong) NSMutableDictionary *currentTcpPairs;
@property (nonatomic,strong) NSMutableDictionary *dnsPairs;

@end

@implementation NTDataKeeper

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    static NTDataKeeper* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[NTDataKeeper alloc] init];
        sharedInstance.httpModels = [[NSMutableArray alloc] init];
        sharedInstance.webModels = [[NSMutableArray alloc] init];
        sharedInstance.tcpModels = [[NSMutableArray alloc] init];
        sharedInstance.currentTcpPairs = [[NSMutableDictionary alloc] init];
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

- (void)trackEvent:(NTEventBase *)baseEvent
{
    if ([[baseEvent class] isKindOfClass:[NTDNSEvent class]]) {
        [self trackDNSEvent:(NTDNSEvent *)baseEvent];
        return;
    }
    
    NTTrackEvent *event = (NTTrackEvent *)baseEvent;
    if (!event.url) {
        return;
    }
    
    NTTCPModel *model = [self.currentTcpPairs objectForKey:event.url];
    if (!model) {
        model = [[NTTCPModel alloc] init];
        [self.tcpModels addObject:model];
        [self.currentTcpPairs setObject:model forKey:event.url];
    }
    [model updateWithEvent:event];
}

- (void)trackDNSEvent:(NTDNSEvent *)event
{
    
}

@end

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


@property (nonatomic,strong) NSMutableDictionary *currentTcpPairs;
@property (nonatomic,strong) NSMutableDictionary *dnsPairs;

@property (nonatomic,strong) dispatch_queue_t workQueue;

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
        sharedInstance.dnsPairs = [[NSMutableDictionary alloc] init];
        sharedInstance.workQueue = dispatch_queue_create("NTDataKeeper.workQueue", NULL);
    });
    return sharedInstance;
}


- (void)trackSessionMetrics:(NSURLSessionTaskMetrics *)metrics
API_AVAILABLE(ios(10.0)){
    dispatch_async(self.workQueue, ^{
        for (NSURLSessionTaskTransactionMetrics *transMetric in metrics.transactionMetrics) {
            //TODO: metrics 还有startDate、duration、redirectCount参数，可以识别为同一个request的redirect
            if (transMetric.resourceFetchType == NSURLSessionTaskMetricsResourceFetchTypeNetworkLoad) {
                NTHTTPModel *model = [[NTHTTPModel alloc] initWithTransactionMetrics:transMetric];
                [self.httpModels addObject:model];
            }
        }
    });
}

- (void)trackTimingData:(NSDictionary *)timingData request:(NSURLRequest *)request
{
    dispatch_async(self.workQueue, ^{
        NTHTTPModel *model = [[NTHTTPModel alloc] initWithTimingData:timingData request:request];
        [self.httpModels addObject:model];
    });
}

- (void)trackWebViewTimingStr:(NSString *)timingStr request:(NSURLRequest *)request
{
    dispatch_async(self.workQueue, ^{
        if (request && !request.URL.isFileURL) {
            NTWebModel *model = [[NTWebModel alloc] initWithJsonStr:timingStr request:request];
            [self.webModels addObject:model];
        }
    });
}

- (void)trackEvent:(NTEventBase *)baseEvent
{
    dispatch_async(self.workQueue, ^{

        if ([baseEvent isKindOfClass:[NTDNSEvent class]]) {
            [self trackDNSEvent:(NTDNSEvent *)baseEvent];
            return;
        }
        
        NTTrackEvent *event = (NTTrackEvent *)baseEvent;
        if (!event.host) {
            return;
        }
        
        NSArray *compo = [event.host componentsSeparatedByString:@"."];
        if ([compo[0] isEqualToString:@"0"] ||[compo[1] isEqualToString:@"0"]) {
            return;
        }
         
        //query cached url(domain) for ip address
        NSString *domainForIp = [self.dnsPairs objectForKey:event.host];
        if (domainForIp) {
            event.host = domainForIp;
        }
        
        NTTCPModel *model = [self.currentTcpPairs objectForKey:event.host];
        if (!model) {
            model = [[NTTCPModel alloc] init];
            [self.tcpModels addObject:model];
            [self.currentTcpPairs setObject:model forKey:event.host];
        }
        [model updateWithEvent:event];
        
    });
}

- (void)trackDNSEvent:(NTDNSEvent *)event
{
    for (NSString *result in event.results) {
        [self.dnsPairs setObject:event.url forKey:result]; //save ip address as key，domain name as value
    }
    
    NTTCPModel *model = [self.currentTcpPairs objectForKey:event.url];
    if (!model) {
        model = [[NTTCPModel alloc] init];
        [self.tcpModels addObject:model];
        [self.currentTcpPairs setObject:model forKey:event.url];
    }
    
    [model updateWithDNSEvent:event];
}

@end

//
//  NTHTTPModel.m
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTHTTPModel.h"
#import <objc/runtime.h>

@implementation NTHTTPModel

- (instancetype)initWithTimingData:(NSDictionary *)timingData request:(NSURLRequest *)request
{
    if (self = [super init]) {
        [timingData enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *keyStr = [key stringByReplacingOccurrencesOfString:@"_kCFNTimingData" withString:@""];
            NSString *propsKey = [keyStr stringByAppendingString:@"Date"];
            if ([obj isKindOfClass:[NSNumber class]] && [obj doubleValue] > 0) {
                NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[obj doubleValue]];
                [self setValue:date forKey:propsKey];
            }
        }];
        self.request = request;
        self.remoteURL = request.URL.absoluteString;
    }
    return self;
}

- (instancetype)initWithTransactionMetrics:(NSURLSessionTaskTransactionMetrics *)metrics
{
    if (self = [super init]) {
        [self setUpWithMetrics:metrics];
    }
    return self;
}

- (void)setUpWithMetrics:(NSURLSessionTaskTransactionMetrics *)metrics API_AVAILABLE(ios(10.0))
{
    if (@available(iOS 10.0, *)) {
        unsigned int count ,i;
        objc_property_t *propertyArray = class_copyPropertyList([NSURLSessionTaskTransactionMetrics class], &count);
        for (i = 0; i < count; i++) {
            objc_property_t property = propertyArray[i];
            NSString *proKey = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            id proValue = [metrics valueForKey:proKey];
            if (proValue){
                [self setValue:proValue forKey:proKey];
            }
        }
        free(propertyArray);
    }
    self.remoteURL = metrics.request.URL.absoluteString;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"%@",key);
}


@end

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

- (instancetype)initWithTransactionMetrics:(NSURLSessionTaskTransactionMetrics *)metrics
API_AVAILABLE(ios(10.0)){
    if (self = [super init]) {
        unsigned int count ,i;
        objc_property_t *propertyArray = class_copyPropertyList([metrics class], &count);
        
        for (i = 0; i < count; i++) {
            objc_property_t property = propertyArray[i];
            NSString *proKey = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            id proValue = [metrics valueForKey:proKey];
            [self setValue:proValue forKey:proKey];
        }
        free(propertyArray);
    }
    return self;
}

@end

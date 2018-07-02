//
//  NTHTTPModel.h
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTBaseModel.h"

@interface NTHTTPModel : NTHTTPBaseModel

@property (nonatomic, strong) NSURLResponse *response;

@property (nonatomic, strong) NSString *networkProtocolName;//"HTTP/1.1"
@property (nonatomic, assign, getter=isProxyConnection) BOOL proxyConnection;
@property (nonatomic, assign, getter=isReusedConnection) BOOL reusedConnection;

// NSURLSession private apis
@property (nonatomic, assign) NSInteger redirected;
@property (nonatomic, assign, getter=isCellular) BOOL cellular;
@property (nonatomic, strong) NSString *localAddressAndPort;


- (instancetype)initWithTransactionMetrics:(NSURLSessionTaskTransactionMetrics *)metrics API_AVAILABLE(ios(10.0));

@end

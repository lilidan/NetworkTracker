//
//  NTBaseModel.h
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NTBaseModel : NSObject

@property (nonatomic, strong) NSDate *fetchStartDate;

@property (nonatomic, strong) NSDate *domainLookupStartDate;
@property (nonatomic, strong) NSDate *domainLookupEndDate;
@property (nonatomic, strong) NSDate *connectStartDate;
@property (nonatomic, strong) NSDate *connectEndDate;
@property (nonatomic, strong) NSDate *secureConnectionStartDate;
@property (nonatomic, strong) NSDate *secureConnectionEndDate;

@property (nonatomic, assign, getter=isSecureConnection) BOOL secureConnection;//HTTPS?

@property (nonatomic, strong) NSString *remoteAddressAndPort;
@property (nonatomic, strong) NSString *remoteURL;


@end


@interface NTHTTPBaseModel : NTBaseModel

@property (nonatomic, strong) NSURLRequest *request;

//date time stamp
@property (nonatomic, strong) NSDate *responseStartDate;
@property (nonatomic, strong) NSDate *responseEndDate;
@property (nonatomic, strong) NSDate *requestStartDate;
@property (nonatomic, strong) NSDate *requestEndDate;



@end

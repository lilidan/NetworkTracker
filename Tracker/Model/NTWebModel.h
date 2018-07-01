//
//  NTWebModel.h
//  testNetwork
//
//  Created by sgcy on 2018/7/1.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTBaseModel.h"

@interface NTWebModel : NTHTTPBaseModel

@property (nonatomic, strong) NSDate *navigationStartDate;
@property (nonatomic, strong) NSDate *redirectStartDate;
@property (nonatomic, strong) NSDate *redirectEndDate;

@property (nonatomic, strong) NSDate *domLoadingDate;
@property (nonatomic, strong) NSDate *domInteractiveDate;
@property (nonatomic, strong) NSDate *domContentLoadedEventStartDate;
@property (nonatomic, strong) NSDate *domContentLoadedEventEndDate;
@property (nonatomic, strong) NSDate *domCompleteDate;
@property (nonatomic, strong) NSDate *loadEventStartDate;
@property (nonatomic, strong) NSDate *loadEventEndDate;

- (instancetype)initWithJsonStr:(NSString *)jsonStr request:(NSURLRequest *)request;

@end

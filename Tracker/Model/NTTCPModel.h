//
//  NTTCPModel.h
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTBaseModel.h"
#import "NTTrackEvent.h"

@interface NTTCPItem : NSObject

@property (nonatomic, strong) NSData *data;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, assign) BOOL viaSSL;


@end

@interface NTTCPModel : NTBaseModel

@property (nonatomic,strong) NSMutableArray<NTTCPItem *> *requestItems;
@property (nonatomic,strong) NSMutableArray<NTTCPItem *> *responseItems;

@property (nonatomic, strong) NSDate *disconnectStartDate;
@property (nonatomic, strong) NSDate *disconnectEndDate;

- (void)updateWithEvent:(NTTrackEvent *)event;
- (void)updateWithDNSEvent:(NTDNSEvent *)event;

@end

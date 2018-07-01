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

@property (nonatomic, assign) BOOL isRequest; //request or response
@property (nonatomic, strong) NSData *data;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, assign) BOOL viaSSL;

@end

@interface NTTCPModel : NTBaseModel

@property (nonatomic,strong) NSMutableArray<NTTCPItem *> *requestItems;
@property (nonatomic,strong) NSMutableArray<NTTCPItem *> *responssItems;

- (void)updateWithEvent:(NTTrackEvent *)event;

@end

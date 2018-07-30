//
//  NTTCPModel.m
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTTCPModel.h"

@implementation NTTCPItem


@end

@implementation NTTCPModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.responseItems = [[NSMutableArray alloc] init];
        self.requestItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)updateWithEvent:(NTTrackEvent *)event
{
    if (event.sourceType == TrackEventSourceTypeCF) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"CFStream: type: %lu --- url: %@ --- length: %d",(unsigned long)event.actionType,event.hostPort,event.content.length);
        });
        return;
    }
    if (event.sourceType == TrackEventSourceTypeSocket) {
        if (event.actionType == TrackEventActionTypeConnect) {
            self.connectStartDate = event.startTime;
            self.connectEndDate = event.endTime;
        }else if (event.actionType == TrackEventActionTypeClose){
            self.disconnectStartDate = event.startTime;
            self.disconnectEndDate = event.endTime;
        }
    }else if(event.sourceType == TrackEventSourceTypeSSL){
        self.secureConnection = YES;
        if (event.actionType == TrackEventActionTypeConnect) {
            self.secureConnectionStartDate = event.startTime;
            self.secureConnectionEndDate = event.endTime;
        }
    }
    
    if (event.actionType > 1) {
        NTTCPItem *item = [[NTTCPItem alloc] init];
        item.startDate = event.startTime;
        item.endDate = event.endTime;
        item.data = event.data;
        item.viaSSL = (event.sourceType == TrackEventSourceTypeSSL);
        NSMutableArray *array = (event.actionType == TrackEventActionTypeWrite ? self.requestItems : self.responseItems);
        [array addObject:item];
    }
    
    self.remoteAddressAndPort = event.hostPort;
    self.remoteURL = event.host;
}

- (void)updateWithDNSEvent:(NTDNSEvent *)event
{
    self.domainLookupStartDate = event.startTime;
    self.domainLookupEndDate = event.endTime;
    self.remoteURL = event.url;
}

- (NSDate *)firstRequestEndDate
{
    if (self.requestItems.count > 0) {
        return [self.requestItems[0] endDate];
    }
    return nil;
}

- (NSDate *)firstRequestStartDate
{
    if (self.requestItems.count > 0) {
        return [self.requestItems[0] startDate];
    }
    return nil;
}

- (NSDate *)firstResponseStartDate
{
    if (self.responseItems.count > 0) {
        return [self.responseItems[0] startDate];
    }
    return nil;
}

- (NSDate *)firstResponseEndDate
{
    if (self.responseItems.count > 0) {
        return [self.responseItems[0] endDate];
    }
    return nil;
}




@end

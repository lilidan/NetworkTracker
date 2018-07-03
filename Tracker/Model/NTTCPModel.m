//
//  NTTCPModel.m
//  breakWork
//
//  Created by sgcy on 2018/6/29.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTTCPModel.h"

@implementation NTTCPModel

- (void)updateWithEvent:(NTTrackEvent *)event
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@",event.url);
    });
}

@end

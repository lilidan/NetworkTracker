//
//  NSStreamTracker.h
//  breakWork
//
//  Created by sgcy on 2018/6/28.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "BaseTracker.h"
#import "NTTrackEvent.h"

@interface NSStreamTracker : BaseTracker

@end

@interface TrackerInputStream:NSInputStream


@end

@interface NSInputStream(track)

+ (void)load;

@end


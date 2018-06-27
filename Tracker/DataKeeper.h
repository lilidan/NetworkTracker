//
//  DataKeeper.h
//  testNetwork
//
//  Created by sgcy on 2018/6/26.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataKeeper : NSObject

+ (instancetype)shareInstance;
- (NSString *)getDataForUrl:(NSString *)url;
- (void)appendData:(const void *)buffer length:(size_t)length ForUrl:(NSString *)url;

@end

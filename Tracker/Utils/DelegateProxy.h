//
//  DelegateProxy.h
//  testNetwork
//
//  Created by sgcy on 2018/6/30.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DelegateProxy : NSProxy

@property (nonatomic, weak) id target;

- (instancetype)initWithTarget:(id)target;

@end

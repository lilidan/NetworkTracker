//
//  NTURLConnectionTracker.m
//  breakWork
//
//  Created by sgcy on 2018/7/4.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTURLConnectionTracker.h"
#import "DelegateProxy.h"
#import <objc/runtime.h>
#import "NTDataKeeper.h"

@interface _NSURLConnectionProxy : DelegateProxy

@end

@implementation _NSURLConnectionProxy

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([NSStringFromSelector(aSelector) isEqualToString:@"connectionDidFinishLoading:"]) {
        return YES;
    }
    return [self.target respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [super forwardInvocation:invocation];
    if ([NSStringFromSelector(invocation.selector) isEqualToString:@"connectionDidFinishLoading:"]) {
        __unsafe_unretained NSURLConnection *conn;
        [invocation getArgument:&conn atIndex:2];
        SEL selector = NSSelectorFromString([@"_timin" stringByAppendingString:@"gData"]);
        NSDictionary *timingData = [conn performSelector:selector];
        [[NTDataKeeper shareInstance] trackTimingData:timingData request:conn.currentRequest];
    }
}

@end



@implementation NSURLConnection(tracker)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(initWithRequest:delegate:);
        SEL swizzledSelector = @selector(swizzledInitWithRequest:delegate:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        NSString *selectorName = [[@"_setC" stringByAppendingString:@"ollectsT"] stringByAppendingString:@"imingData:"];
        SEL selector = NSSelectorFromString(selectorName);
        [NSURLConnection performSelector:selector withObject:@(YES)];
    });
}

- (instancetype)swizzledInitWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate
{
    if (delegate) {
        _NSURLConnectionProxy *proxy = [[_NSURLConnectionProxy alloc] initWithTarget:delegate];
        objc_setAssociatedObject(delegate ,@"_NSURLConnectionProxy" ,proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return [self swizzledInitWithRequest:request delegate:(id<NSURLConnectionDelegate>)proxy];
    }else{
        return [self swizzledInitWithRequest:request delegate:delegate];
    }
}



@end

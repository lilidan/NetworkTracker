//
//  NSStreamTracker.m
//  breakWork
//
//  Created by sgcy on 2018/6/28.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NSStreamTracker.h"
#import <objc/runtime.h>

@implementation NSStreamTracker

@end

@implementation TrackerInputStream

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSLog(@"!!!!!!!!!!");
    //    NSInteger result = [self swizzledRead:buffer maxLength:len];
    //    [NSStreamTracker trackEvent:[[TrackEvent alloc] initWithType:TrackerEventTypeCFResponse buffer:buffer length:len stream:(__bridge void *)(self)]];
    return 2;
}

@end


@implementation NSInputStream(track)

+ (void)load
{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class class = [self class];
//
//        SEL originalSelector = @selector(read:maxLength:);
//        SEL swizzledSelector = @selector(swizzledRead:maxLength:);
//
//        Method originalMethod = class_getInstanceMethod(class, originalSelector);
//        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//        
//        // When swizzling a class method, use the following:
//        // Class class = object_getClass((id)self);
//        // ...
//        // Method originalMethod = class_getClassMethod(class, originalSelector);
//        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
//
//        BOOL didAddMethod =
//        class_addMethod(class,
//                        originalSelector,
//                        method_getImplementation(swizzledMethod),
//                        method_getTypeEncoding(swizzledMethod));
//
//        if (didAddMethod) {
//            class_replaceMethod(class,
//                                swizzledSelector,
//                                method_getImplementation(originalMethod),
//                                method_getTypeEncoding(originalMethod));
//        } else {
//            method_exchangeImplementations(originalMethod, swizzledMethod);
//        }
//    });
}

//- (NSInteger)swizzledRead:(uint8_t *)buffer maxLength:(NSUInteger)len
//{
//    NSLog(@"!!!!!!!!!!");
//    NSInteger result = [self swizzledRead:buffer maxLength:len];
//    [NSStreamTracker trackEvent:[[TrackEvent alloc] initWithType:TrackerEventTypeCFResponse buffer:buffer length:len stream:(__bridge void *)(self)]];
//    return 2;
//}

@end

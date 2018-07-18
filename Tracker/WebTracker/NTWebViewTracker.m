//
//  NTWebViewTracker.m
//  testNetwork
//
//  Created by sgcy on 2018/6/30.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTWebViewTracker.h"
#import <objc/runtime.h>
#import "DelegateProxy.h"
#import "NTDataKeeper.h"

@interface _UIWebViewProxy : DelegateProxy

@end

@implementation _UIWebViewProxy

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([NSStringFromSelector(aSelector) isEqualToString:@"webViewDidFinishLoad:"]) {
        return YES;
    }
    return [self.target respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [super forwardInvocation:invocation];
    if ([NSStringFromSelector(invocation.selector) isEqualToString:@"webViewDidFinishLoad:"]) {
        __unsafe_unretained UIWebView *webView;
        [invocation getArgument:&webView atIndex:2];
        __strong NSString *funcStr = @"function flatten(obj) {"
        "var ret = {}; "
        "for (var i in obj) { "
        "ret[i] = obj[i];"
        "}"
        "return ret;}";
        [webView stringByEvaluatingJavaScriptFromString:funcStr];
        NSString *timingStr = [webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(flatten(window.performance.timing))"];
        [[NTDataKeeper shareInstance] trackWebViewTimingStr:timingStr request:webView.request];
    }
}

@end


@implementation UIWebView(track)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(swizzledSetDelegate:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)swizzledSetDelegate:(id<UIWebViewDelegate>)delegate
{
    if (delegate) {
        _UIWebViewProxy *proxy = [[_UIWebViewProxy alloc] initWithTarget:delegate];
        objc_setAssociatedObject(delegate ,@"_UIWebViewProxy" ,proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self swizzledSetDelegate:(id<UIWebViewDelegate>)proxy];
    }else{
        [self swizzledSetDelegate:delegate];
    }
}


@end







@interface _WKWebViewProxy : DelegateProxy

@end

@implementation _WKWebViewProxy

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([NSStringFromSelector(aSelector) isEqualToString:@"webView:didFinishNavigation:"]) {
        return YES;
    }
    return [self.target respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [super forwardInvocation:invocation];
    if ([NSStringFromSelector(invocation.selector) isEqualToString:@"webView:didFinishNavigation:"]) {
        __unsafe_unretained WKWebView *webView;
        [invocation getArgument:&webView atIndex:2];
        if (@available(iOS 10.0, *)) {
            [webView evaluateJavaScript:@"JSON.stringify(window.performance.timing.toJSON())" completionHandler:^(NSString * _Nullable timingStr, NSError * _Nullable error) {
                if (!error) {
                    [[NTDataKeeper shareInstance] trackWebViewTimingStr:timingStr request:[NSURLRequest requestWithURL:webView.URL]];
                }
            }];
        }else{
            NSString *funcStr = @"function flatten(obj) {"
            "var ret = {}; "
            "for (var i in obj) { "
            "ret[i] = obj[i];"
            "}"
            "return ret;}";
            [webView evaluateJavaScript:funcStr completionHandler:^(NSString *_Nullable result, NSError * _Nullable error) {
                if (!error) {
                    [webView evaluateJavaScript:@"JSON.stringify(flatten(window.performance.timing))" completionHandler:^(NSString * _Nullable timingStr, NSError * _Nullable error) {
                        if (!error) {
                            [[NTDataKeeper shareInstance] trackWebViewTimingStr:timingStr request:[NSURLRequest requestWithURL:webView.URL]];
                        }
                    }];
                }
            }];
        }
    }
}

@end


@implementation WKWebView(track)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setNavigationDelegate:);
        SEL swizzledSelector = @selector(swizzledNavigationDelegate:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)swizzledNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate
{
    if (navigationDelegate) {
        _WKWebViewProxy *proxy = [[_WKWebViewProxy alloc] initWithTarget:navigationDelegate];
        objc_setAssociatedObject(navigationDelegate ,@"_WKWebViewProxy" ,proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self swizzledNavigationDelegate:(id<WKNavigationDelegate>)proxy];
    }else{
        [self swizzledNavigationDelegate:navigationDelegate];
    }
}


@end





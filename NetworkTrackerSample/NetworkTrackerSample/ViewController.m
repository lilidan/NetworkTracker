//
//  ViewController.m
//  breakWork
//
//  Created by sgcy on 2018/6/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <CFNetwork/CFNetwork.h>
#import <CFNetwork/CFNetwork.h>
#import <netinet/in.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/ethernet.h>
#import <net/if_dl.h>
#import "NTDataKeeper.h"
#import <WebKit/WebKit.h>
#import "NTChartViewController.h"
#import <CFNetwork/CFNetwork.h>

@interface ViewController ()<NSURLConnectionDataDelegate,NSURLSessionTaskDelegate,UIWebViewDelegate,WKNavigationDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *urls;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    SEL selector = NSSelectorFromString(@"_setCollectsTimingData:");
//    [NSURLConnection performSelector:selector withObject:@(YES)];

    
    
    NSArray *urls = @[@"https://www.baidu.com",@"https://www.github.com",@"https://www.google.com.hk",@"https://www.taobao.com",@"https://www.twitter.com/",@"https://www.facebook.com"];
    _urls = urls;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self loadNSURLSession];
}

- (void)loadNSURLSession
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    SEL selector = NSSelectorFromString(@"set_collectsTimingData:");
//    [config performSelector:selector withObject:@(YES)];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    for (NSString *url in self.urls) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        // Do any additional setup after loading the view, typically from a nib
//        NSURLSessionTask *task = [session dataTaskWithRequest:request];
//        [task resume];

        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [conn start];

//        NSLog(@"");
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//    SEL selector = NSSelectorFromString(@"_timingData");
//    id timingData = [task performSelector:selector];
    NSLog(@"");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    SEL selector = NSSelectorFromString(@"_timingData");
//    id timingData = [connection performSelector:selector];
    NSLog(@"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return self.urls.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    if (indexPath.section == 0) {
        cell.textLabel.text  = @"track result";
    }else{
        cell.textLabel.text = self.urls[indexPath.row];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"UIWebView";
    }else if (section == 2){
        return @"WKWebView";
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:tableView animated:indexPath];
    if (indexPath.section == 0) {
        NTChartViewController *chart = [[NTChartViewController alloc] init];
        [self.navigationController pushViewController:chart animated:YES];
    }else{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.urls[indexPath.row]]];
        UIViewController *vc = [[UIViewController alloc] init];
        if (indexPath.section == 1) {
            UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
            webView.delegate = self;
            [vc.view addSubview:webView];
            [webView loadRequest:request];
        }else{
            WKWebView *wkwebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
            [wkwebView loadRequest:request];
            [vc.view addSubview:wkwebView];
            wkwebView.navigationDelegate = self;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.navigationItem.title = @"uiwebview loading";
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.title = @"uiwebview finish";
}


- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    self.navigationItem.title = @"wk loading";
    
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.navigationItem.title = @"wk finish";
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics
{
    NSLog(@"");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"接受数据中。。。。。%d",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] length]);
    });
}


//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    //    NSString *topAppsString = [[NSString alloc] initWithData:_mutdata encoding:NSUTF8StringEncoding];
//    //    NSLog(@"%@",topAppsString);
//    [NTDataKeeper shareInstance];
//}
//

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    SEL selector = NSSelectorFromString(@"_timingData");
    id timingData = [connection performSelector:selector];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"接受数据中。。。。。%@",response);
    });
}




@end

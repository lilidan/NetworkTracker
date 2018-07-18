//
//  NTWebModel.m
//  testNetwork
//
//  Created by sgcy on 2018/7/1.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "NTWebModel.h"

@implementation NTWebModel

- (instancetype)initWithJsonStr:(NSString *)jsonStr request:(NSURLRequest *)request
{
    if (self = [super init]){
        NSError *error;
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            [json enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
                NSString *propsKey = [key stringByAppendingString:@"Date"];
                if ([obj doubleValue] > 0) {
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]/1000.0];
                    [self setValue:date forKey:propsKey];
                }
            }];
        }
        self.request = request;
        self.remoteURL = request.URL.absoluteString;
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"%@",key);
}

@end

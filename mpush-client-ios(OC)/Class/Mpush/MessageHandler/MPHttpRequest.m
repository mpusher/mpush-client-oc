//
//  MPHttpRequest.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHttpRequest.h"
#import "Mpush.h"

@implementation MPHttpRequest

- (instancetype)initWithMethod:(MPHttpMethod)method andUrl:(NSString *)url andParams:(NSMutableDictionary *)params{
    if (self = [super init]) {
        self.method = method;
        self.url = url;
        self.timeout = 50000;
        self.headers = [NSMutableDictionary dictionaryWithDictionary:@{@"Content-Type":@"application/x-www-form-urlencoded",@"charset":@"UTF-8",@"readTimeout": @(self.timeout)}];
        self.body = [self encodeParams:params];
    }
    return self;
}

+ (MPHttpRequest *)GET:(NSString *)url andParams:(NSMutableDictionary *)params{
    return [[self alloc] initWithMethod:MPHttpMethodGet andUrl:url andParams:params];
}

+ (MPHttpRequest *)POST:(NSString *)url andParams:(NSMutableDictionary *)params{
    return [[self alloc] initWithMethod:MPHttpMethodPost andUrl:url andParams:params];
}

- (void)setHeaders:(NSMutableDictionary *)headers{
    _headers = headers;
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.headers setValue:obj forKey:key];
    }];
}

- (NSData *)encodeParams:(NSMutableDictionary *)params{
    NSData *body = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    return body;
}



@end

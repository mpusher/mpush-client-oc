//
//  MPHttpResponse.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHttpResponse.h"

@implementation MPHttpResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode andReasonPhrase:(NSString *)reasonPhrase andHeaders:(NSDictionary *)headers andBody:(NSData *)body{
    if (self = [super init]) {
        self.statusCode = statusCode;
        self.reasonPhrase = reasonPhrase;
        self.headers = headers;
        self.body = body;
    }
    return self;
}
@end

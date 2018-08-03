//
//  MPHttpRequestMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHttpRequestMessage.h"

@implementation MPHttpRequestMessage

+ (instancetype)httpRequest:(MPHttpRequest *)httpRequest{
    return [[self alloc] initWithRequest:httpRequest];
}

- (instancetype)initWithRequest:(MPHttpRequest *)httpRequest{
    if (self = [super initWithPacket:[[MPPacket alloc] initWithCmd:MPCmdHttp andSessionId:[MPBaseMessage genRequestSessionId]]]) {
        self.method = httpRequest.method;
        self.url = httpRequest.url;
        self.headers = httpRequest.headers;
        self.body = httpRequest.body;
    }
    return self;
}

- (NSData *)encode{
    NSMutableData *body = [NSMutableData data];
    RFIWriter *writer = [[RFIWriter alloc] initWithData:body];
    [writer writeByte:self.method];
    [writer writeString:self.url];
    [writer writeString: [self headersToString:self.headers]];
    [writer writeData:self.body];
    self.packet.body = writer.data;
    return [super encode];
}

- (NSString *)headersToString:(NSDictionary *)headers{
    NSMutableString *headersStr = [NSMutableString string];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [headersStr appendFormat:@"%@:%@\n", key, obj];
    }];
    return headersStr;
}

@end

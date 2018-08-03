//
//  MPHttpRequestMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"
#import "MPHttpRequest.h"

@interface MPHttpRequestMessage : MPBaseMessage

+ (instancetype)httpRequest:(MPHttpRequest *)httpRequest;
- (instancetype)initWithRequest:(MPHttpRequest *)httpRequest;
@property (nonatomic, assign)int8_t method;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong)NSDictionary *headers;
@property (nonatomic, strong)NSData *body;

@end

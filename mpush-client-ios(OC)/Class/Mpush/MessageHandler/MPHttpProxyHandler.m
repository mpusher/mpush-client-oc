//
//  MPHttpProxyHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHttpProxyHandler.h"
#import "MPHttpResponseMessage.h"

@implementation MPHttpProxyHandler

-(MPHttpResponseMessage *)decodeWithPacket:(MPPacket *)packet{
    return [[MPHttpResponseMessage alloc] initWithPacket:packet];
}

- (void)handleWithMessage:(MPHttpResponseMessage *)message{
    MPLog(@"receive MPHttpProxyHandler %@", [message debugDescription]);
    MPClient *client = [MPClient sharedClient];
    if ([client.delegate respondsToSelector: @selector(client:onHttpProxyResponse:)]) {
        [client.delegate client:client onHttpProxyResponse:message];
    }
}


@end

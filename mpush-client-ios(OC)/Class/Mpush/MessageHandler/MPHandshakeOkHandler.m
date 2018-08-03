//
//  MPHandshakeOkHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHandshakeOkHandler.h"


@implementation MPHandshakeOkHandler
- (MPHandshakeOkMessage *)decodeWithPacket:(MPPacket *)packet{
    return [[MPHandshakeOkMessage alloc] initWithPacket:packet];
}

- (void)handleWithMessage:(MPHandshakeOkMessage *)message{
    // 更换密钥
    MPLog(@"MPHandshakeOkHandler  handleWithMessage");
    NSData *sessionKeyData = [MPCipherBox mixAesKey:message.serverKey];
    [MPCipherBox setSessionData:sessionKeyData];
    [MPSessionStorage saveSessionWithSessionId:message.sessionId andExpireTime: message.expireTime/1000.0];
    
    [self processHandshakeOkWithMessage:message];
}

- (void)processHandshakeOkWithMessage:(MPHandshakeOkMessage *)message{
    MPClient *client = [MPClient sharedClient];
    [self sendHBWithClient:client andDelay: [MPConfig defaultConfig].minHeartbeat];
    if ([client.delegate respondsToSelector: @selector(client:onHandshakeOk:)]) {
        [client.delegate client:client onHandshakeOk: message.heartbeat];
    }
}

- (void)sendHBWithClient:(MPClient *)client andDelay:(int64_t)delay{
    if (client.isRunning) {
        [client healthCheck];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendHBWithClient:client andDelay:delay];
        });
    }
}

@end

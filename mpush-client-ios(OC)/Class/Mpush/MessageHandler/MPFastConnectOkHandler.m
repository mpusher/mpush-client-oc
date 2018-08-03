//
//  MPFastConnectOkHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPFastConnectOkHandler.h"
#import "MPFastConnectOKMessage.h"

@implementation MPFastConnectOkHandler

- (MPFastConnectOKMessage *)decodeWithPacket:(MPPacket *)packet{
    return [[MPFastConnectOKMessage alloc] initWithPacket:packet];
}

- (void)handleWithMessage:(MPFastConnectOKMessage *)message{
    MPLog(@"receive MPFastConnectOkHandler");
    [self processHandshakeOkWithMessage:message];
}

- (void)processHandshakeOkWithMessage:(MPFastConnectOKMessage *)message{
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

//
//  MPPushMessageHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPPushMessageHandler.h"
#import "MPPushMessage.h"
#import "MPAckMessage.h"

@implementation MPPushMessageHandler

- (MPBaseMessage *)decodeWithPacket:(MPPacket *)packet{
    return [[MPPushMessage alloc] initWithPacket:packet];
}

- (void)handleWithMessage:(MPPushMessage *)message{
    MPClient *client = [MPClient sharedClient];
    if ([client.delegate respondsToSelector: @selector(client:onRecievePushMsg:)]) {
        [client.delegate client:client onRecievePushMsg:message];
    }
    if (message.autoAck) {
        MPAckMessage *ackMessage = [[MPAckMessage alloc] initWithSessionId:message.getSessionId];
        [client sendMessageData:[ackMessage encode]];
    }
}

//- (void)handleWithPacket:(MPPacket *)packet{
//    MPLog(@"receive MPPushMessageHandler");
//}

@end

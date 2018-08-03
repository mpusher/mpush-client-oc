//
//  MPKickUserHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPKickUserHandler.h"
#import "MPKickUserMessage.h"

@implementation MPKickUserHandler

-(MPKickUserMessage *)decodeWithPacket:(MPPacket *)packet{
    return [[MPKickUserMessage alloc] initWithPacket:packet];
}

- (void)handleWithMessage:(MPKickUserMessage *)message{
    MPLog(@"receive kick user message %@", [message debugDescription]);
    MPClient *client = [MPClient sharedClient];
    if ([client.delegate respondsToSelector: @selector(client:onKickUser:)]) {
        [client.delegate client:client onKickUser:message];
    }
}


@end

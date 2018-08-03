//
//  MPHeartbeatHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHeartbeatHandler.h"
#import "Mpush.h"

@implementation MPHeartbeatHandler

- (void)handleWithPacket:(MPPacket *)packet{
    MPLog(@"receive heartbeat pong...");
    
    MPClient *client = [MPClient sharedClient];
    if ([client.delegate respondsToSelector: @selector(clientOnRecieveHeartBeat:)]) {
        [client.delegate clientOnRecieveHeartBeat:client];
    }
}

@end

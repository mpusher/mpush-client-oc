//
//  MPMessageDispatcher.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPMessageDispatcher.h"
#import "MPHeartbeatHandler.h"
#import "MPFastConnectOkHandler.h"
#import "MPHandshakeOkHandler.h"
#import "MPKickUserHandler.h"
#import "MPOkMessageHandler.h"
#import "MPErrorMessageHandler.h"
#import "MPPushMessageHandler.h"
#import "MPHttpProxyHandler.h"


@interface MPMessageDispatcher()

@property (nonatomic, strong)dispatch_queue_t queue;
@property (nonatomic, strong)NSMutableDictionary *handles;

@end

@implementation MPMessageDispatcher

- (instancetype)init{
    if (self = [super init]) {
        self.handles = [NSMutableDictionary dictionary];
        self.queue = dispatch_queue_create("message_dispatch_queue", DISPATCH_QUEUE_SERIAL);
        [self registeHandle:[[MPHeartbeatHandler alloc] init] andCmd:(MPCmdHeartbeat)];
        [self registeHandle:[[MPFastConnectOkHandler alloc] init] andCmd:(MPCmdFastConnect)];
        [self registeHandle:[[MPHandshakeOkHandler alloc] init] andCmd:(MPCmdHandShake)];
        [self registeHandle:[[MPKickUserHandler alloc] init] andCmd:(MPCmdKick)];
        [self registeHandle:[[MPOkMessageHandler alloc] init] andCmd:(MPCmdOk)];
        [self registeHandle:[[MPErrorMessageHandler alloc] init] andCmd:(MPCmdError)];
        [self registeHandle:[[MPPushMessageHandler alloc] init] andCmd:(MPCmdPush)];
        [self registeHandle:[[MPHttpProxyHandler alloc] init] andCmd:(MPCmdHttp)];
    }
    return self;
}

- (void)registeHandle:(MPBaseMessageHandle *)messageHandle andCmd:(MPCmd)cmd{
    self.handles[@(cmd)] = messageHandle;
}

- (void)onReceivePacket:(MPPacket *)packet{
    MPBaseMessageHandle *handler = self.handles[@(packet.cmd)];
    if (handler) {
        dispatch_async(self.queue, ^{
            [handler handleWithPacket:packet];
        });
    }
}

@end

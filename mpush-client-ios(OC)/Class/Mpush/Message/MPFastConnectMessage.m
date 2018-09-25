//
//  MPFastConnectMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPFastConnectMessage.h"
#import "MPSessionStorage.h"
#import "GSKeyChainDataManager.h"
#import "Mpush.h"
#import "RSA.h"

@implementation MPFastConnectMessage

- (instancetype)init{
    return [super initWithPacket:[[MPPacket alloc] initWithCmd:(MPCmdFastConnect) andSessionId:MPBaseMessage.genRequestSessionId]];
}

- (NSData *)encode{
    NSMutableData *body = [NSMutableData data];
    RFIWriter *writer = [[RFIWriter alloc] initWithData:body];
    NSString *sessionId = [MPSessionStorage getSessionStorage][MPSessionId];
    [writer writeString:sessionId];
    NSString *uuid = [GSKeyChainDataManager readUUID];
    MPLog(@"uuid: %@", uuid);
    [writer writeString: uuid];
    [writer writeInt32:[MPConfig defaultConfig].minHeartbeat];
    [writer writeInt32:[MPConfig defaultConfig].maxHeartbeat];
    
    self.packet.body = writer.data;
    return [MPPacketEncoder encodePacket:self.packet];
}

@end

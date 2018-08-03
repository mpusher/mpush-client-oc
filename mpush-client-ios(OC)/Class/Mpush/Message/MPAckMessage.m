//
//  MPAckMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPAckMessage.h"

@implementation MPAckMessage
- (instancetype)initWithSessionId:(int32_t)sessionId{
    return [super initWithPacket:[[MPPacket alloc] initWithCmd:(MPCmdAck) andSessionId:sessionId]];
}

@end

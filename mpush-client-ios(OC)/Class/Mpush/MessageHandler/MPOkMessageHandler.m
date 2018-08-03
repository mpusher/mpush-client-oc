//
//  MPOkMessageHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPOkMessageHandler.h"
#import "MPOkMessage.h"

@implementation MPOkMessageHandler

- (MPOkMessage *)decodeWithPacket:(MPPacket *)packet{
    return [[MPOkMessage alloc] initWithPacket:packet];
}

- (void)handleWithMessage:(MPOkMessage *)message{
    MPLog(@"MPOkMessageHandler  message: %@",[message debugDescription]);
    
    MPClient *client = [MPClient sharedClient];
    if ([client.delegate respondsToSelector: @selector(client:onRecieveOkMsg:)]) {
        [client.delegate client:client onRecieveOkMsg: message];
    }
}
@end

//
//  MPErrorMessageHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPErrorMessageHandler.h"
#import "MPErrorMessage.h"

@implementation MPErrorMessageHandler

- (MPErrorMessage *)decodeWithPacket:(MPPacket *)packet{
    return [[MPErrorMessage alloc] initWithPacket:packet];
}

- (void)handleWithMessage:(MPErrorMessage *)message{
    MPLog(@"MPErrorMessageHandler  message: %@",[message debugDescription]);
    
    MPClient *client = [MPClient sharedClient];
    if ([client.delegate respondsToSelector: @selector(client:onRecieveErrorMsg:)]) {
        [client.delegate client:client onRecieveErrorMsg: message];
    }
}
@end

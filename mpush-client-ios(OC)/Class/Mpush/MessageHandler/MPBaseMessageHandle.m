//
//  MPMessageHandle.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessageHandle.h"

@implementation MPBaseMessageHandle
- (MPBaseMessage *)decodeWithPacket:(MPPacket *)packet{
    return nil;
}

- (void)handleWithMessage:(MPBaseMessage *)message{
    
}

- (void)handleWithPacket:(MPPacket *)packet{
    MPBaseMessage *baseMessage = [self decodeWithPacket:packet];
    [baseMessage decodeBody];
    [self handleWithMessage:baseMessage];
}


@end


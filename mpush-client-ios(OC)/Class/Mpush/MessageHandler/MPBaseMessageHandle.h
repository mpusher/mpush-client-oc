//
//  MPMessageHandle.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPPacket.h"
#import "MPBaseMessage.h"
#import "MPHandshakeOkMessage.h"
#import "Mpush.h"
#import "MPCipherBox.h"
#import "MPSessionStorage.h"
#import "MPClient.h"


@interface MPBaseMessageHandle : NSObject
- (MPBaseMessage *)decodeWithPacket:(MPPacket *)packet;
- (void)handleWithMessage:(MPBaseMessage *)message;

- (void)handleWithPacket:(MPPacket *)packet;
@end

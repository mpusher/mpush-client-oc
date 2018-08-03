//
//  MPMessageDispatcher.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MPPacket;

@protocol PacketReceiverProtocol
- (void)onReceivePacket:(MPPacket *)packet;

@end

@interface MPMessageDispatcher : NSObject<PacketReceiverProtocol>

@end

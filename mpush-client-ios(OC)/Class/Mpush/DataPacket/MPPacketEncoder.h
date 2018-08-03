//
//  MPPacketEncoder.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MPPacket;

@interface MPPacketEncoder : NSObject
+ (NSData *)encodePacket:(MPPacket *)packet;

@end

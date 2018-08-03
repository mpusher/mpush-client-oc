//
//  MPPacketDecoder.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPPacket.h"

@interface MPPacketDecoder : NSObject

+ (MPPacket *)decodePacketWithData:(NSData *)data;

@end

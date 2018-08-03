//
//  MPBaseMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPPacket.h"
#import "RFIWriter.h"
#import "RFIReader.h"
#import "MPPacketEncoder.h"
#import "MPSessionStorage.h"
#import "MPConfig.h"
#import "MPCipherBox.h"
#import "NSObject+MPDebugDescription.h"



@interface MPBaseMessage : NSObject

@property (nonatomic, strong)MPPacket *packet;

- (instancetype)initWithPacket:(MPPacket *)packet;

- (void)decodeWithBody:(NSData *)body;

- (void)decodeBody;

- (NSData *)encode;

+ (int)genRequestSessionId;

- (int32_t)getSessionId;

@end

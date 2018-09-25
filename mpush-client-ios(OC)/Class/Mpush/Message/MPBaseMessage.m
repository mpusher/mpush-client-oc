//
//  MPBaseMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

#import "MPCipherBox.h"
#import "MPAesCipher.h"
#import "LFCGzipUtility.h"
#import <stdatomic.h>
#import "RSA.h"

@interface MPBaseMessage()


@end

@implementation MPBaseMessage

- (instancetype)initWithPacket:(MPPacket *)packet{
    if (self = [super init]) {
        self.packet = packet;
    }
    return self;
}

- (void)decodeBody{
    NSData *body = self.packet.body;
    if (!body || body.length==0) return;
    
    // 1、解密
    if (self.packet.cmd == MPCmdHandShake && [self.packet hasFlag:MPFlagsCrypto]) {
        body = [MPAesCipher aesDecriptWithEncryptData:body withIv:[MPCipherBox getIvBytes] andKey:[MPCipherBox getClientKeyBytes]];
    }
    
    // 1、解密
    if (self.packet.cmd != MPCmdHandShake && [self.packet hasFlag:MPFlagsCrypto]) {
        body = [MPAesCipher aesDecriptWithEncryptData:body withIv:[MPCipherBox getIvBytes] andKey:[MPCipherBox getSessionBytes]];
    }
    // 2、解压
    if (((self.packet.flags & MPFlagsCompress) != 0)) {
        body = [LFCGzipUtility ungzipData:body];
    }
    [self decodeWithBody: body];
}

//- (NSData *)encodeBody{
//
//
//}

- (void)decodeWithBody:(NSData *)body{
    
}

- (NSData *)encode{
    NSData *body = self.packet.body;
    if (body.length > 0) {
        // 1、压缩
        if (body.length > [MPConfig defaultConfig].compressLimit) {
            NSData *result = [LFCGzipUtility gzipData:body];
            if (result.length > 0) {
                body = result;
                [self.packet addFlag: MPFlagsCompress];
            } 
        }
        
        // 2、加密
        if (self.packet.cmd == MPCmdHandShake) {
            NSData *encryptBody = [RSA encryptData:body publicKey: [MPConfig defaultConfig].publicKey];
            body = encryptBody;
            [self.packet addFlag:(MPFlagsCrypto)];
        } else {
            NSData *result = [MPAesCipher aesEncriptData:body];
            if (result.length > 0) {
                body = result;
                [self.packet addFlag: MPFlagsCrypto];
            }
        }
        
        self.packet.body = body;
    }
    return [MPPacketEncoder encodePacket:self.packet];
}

+ (int)genRequestSessionId
{
    static atomic_int counter;
    atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
    return counter;
}

- (int32_t)getSessionId{
    return self.packet.sessionId;
}

@end

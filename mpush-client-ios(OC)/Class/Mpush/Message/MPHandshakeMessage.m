//
//  MPHandshakeMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHandshakeMessage.h"
#import "RSA.h"


@implementation MPHandshakeMessage


- (instancetype)init{
    self = [super initWithPacket:[[MPPacket alloc] initWithCmd:(MPCmdHandShake) andSessionId:[MPSessionStorage genSessionId]]];
    if (self) {
        MPConfig *config = [MPConfig defaultConfig];
        self.deviceId = config.deviceId;
        self.osName = config.osName;
        self.osVersion = config.osVersion;
        self.clientVersion = config.clientVersion;
        int8_t aesLength = [[MPConfig defaultConfig] aesKeyLength];
        NSData *ivData = [MPCipherBox generateRandomAesKeyWithLength: aesLength];
        [MPCipherBox setIvData:ivData];
        
        NSData *clientKeyData = [MPCipherBox generateRandomAesKeyWithLength: aesLength];
        [MPCipherBox setClientKeyData:clientKeyData];
        self.iv = ivData;
        self.clientKey = clientKeyData;
        self.minHeartbeat = config.minHeartbeat;
        self.maxHeartbeat = config.maxHeartbeat;
        
    }
    return self;
}

- (NSData *)encode{
    NSMutableData *body = [NSMutableData data];
    RFIWriter *writer = [[RFIWriter alloc] initWithData:body];
    [writer writeString:self.deviceId];
    [writer writeString:self.osName];
    [writer writeString:self.osVersion];
    [writer writeString:self.clientVersion];
    
    [writer writeData:self.iv];
    [writer writeData:self.clientKey];
    
    [writer writeInt32:self.minHeartbeat];
    [writer writeInt32:self.maxHeartbeat];
    
    NSDate *date = [NSDate date];
    NSTimeInterval dateS = date.timeIntervalSince1970;
    long long time = (long long)dateS;
    HTONLL(time);
    self.timestamp = time;
    [writer writeInt64:time];
    
    // rsa加密
    NSData *encryptBody = [RSA encryptData:writer.data publicKey: [MPConfig defaultConfig].publicKey];
    MPPacket *packet = self.packet;
    [packet addFlag:(MPFlagsCrypto)];
    packet.body = encryptBody;
    return [MPPacketEncoder encodePacket:packet];
}

@end

//
//  MessageDataPacketTool.m
//  mpush-client-ios(OC)
//
//  Created by Yonglin on 16/8/29.
//  Copyright © 2016年 Yonglin. All rights reserved.
//

#import "MessageDataPacketTool.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GSKeyChainDataManager.h"
#import "MPCipherBox.h"
#import "MPAesCipher.h"
#import "RFIReader.h"
#import "MPSessionStorage.h"

@implementation MessageDataPacketTool



/**
 *  协议头
 *
 *  @param length    boda 长度
 *  @param cmd       数据类型
 *  @param cc        校验码
 *  @param flags     加密、压缩标志
 *  @param sessionId 会话id
 *  @param lrc       
 *
 *  @return 协议头data
 */

+ (NSMutableData *)ipHeaderWithLength:(uint32_t)length
                                  cmd:(MpushMessageBodyCMD)cmd
                                   cc:(int16_t)cc
                                flags:(int8_t)flags
                            sessionId:(uint32_t)sessionId
                                  lrc:(int8_t)lrc
{
    //协议头
    NSMutableData *packetData = [NSMutableData data];
    RFIWriter *writerPacket = [RFIWriter writerWithData:packetData];
    [writerPacket writeUInt32:length];
    [writerPacket writeByte:cmd];
    [writerPacket writeInt16:cc];
    [writerPacket writeByte:flags];
    [writerPacket writeUInt32:sessionId];
    [writerPacket writeByte:lrc];
    
    return writerPacket.data;
}
/**
 *  握手数据包
 *
 *  @return 握手数据data
 */
+ (NSData *)handshakeMessagePacketData
{
    //拼接body
    NSMutableData *bodyData = [NSMutableData data];
    RFIWriter *writerPacket = [RFIWriter writerWithData:bodyData];
    
    //设备唯一标识
    NSString *identifierForVendor = [GSKeyChainDataManager readUUID];
    [writerPacket writeString:identifierForVendor];
    [MPUserDefaults setObject:identifierForVendor forKey:MPDeviceId];
    [MPUserDefaults synchronize];
    
    //设备名称
    [writerPacket writeString:DEVICE_TYPE];
    //设备版本号
    [writerPacket writeString: appVersion];
    //app版本号
    NSString *clientVersionionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [writerPacket writeString: clientVersionionStr];
    
    // aec加密 模和指数
    uint16_t aesLength = MPAeslength;
    NSData *ivData = [MPCipherBox generateRandomAesKeyWithLength:aesLength];
    [MPCipherBox setIvData:ivData];
    [writerPacket writeInt16:aesLength];
    [writerPacket writeBytes:ivData];
    
    NSData *clientKeyData = [MPCipherBox generateRandomAesKeyWithLength:aesLength];
    [MPCipherBox setClientKeyData:clientKeyData];
    [writerPacket writeInt16:aesLength];
    [writerPacket writeBytes:clientKeyData];
    
    //心跳
    [writerPacket writeInt32:MPMinHeartbeat];
    [writerPacket writeInt32:MPMaxHeartbeat];
    
    //时间戳
    NSDate *date = [NSDate date];
    NSTimeInterval dateS = date.timeIntervalSince1970;
    long long time = (long long)dateS;
    HTONLL(time);
    [writerPacket writeInt64:time];
    
    // rsa加密
    NSData *enData = [RSA encryptData:writerPacket.data publicKey:pubkey];
    
    //拼接packet
    NSMutableData *ipHeaderData = [MessageDataPacketTool ipHeaderWithLength:(uint32_t)enData.length cmd:MpushMessageBodyCMDHandShakeSuccess cc:0 flags:MPFlagsCrypto sessionId:[MPSessionStorage genSessionId] lrc:0];
    [ipHeaderData appendData:enData];
    return ipHeaderData;
}

/**
 *  响应包信息
 *
 *  @param data read的data
 *
 *  @return ip协议包（结构体类型）
 */
+ (IP_PACKET)handShakeSuccessResponesWithData:(NSData *)data
{
    RFIReader *reader = [[RFIReader alloc] initWithData:data];
    
    IP_PACKET ipPacket;
    ipPacket.length = reader.readInt32;
    ipPacket.cmd = reader.readByte;
    ipPacket.cc = reader.readInt16;
    ipPacket.flags = reader.readByte;
    ipPacket.sessionId = reader.readInt32;
    ipPacket.lrc = reader.readByte;
    //body
    NSData *bodyData = [data subdataWithRange:NSMakeRange(13, ipPacket.length)];
    char *bodyBytes = (char *)[bodyData bytes];
    ipPacket.body = bodyBytes;
    return ipPacket;
}

/**
 *  握手成功响应的bodyData
 *
 *  @param bodyData 读到的握手ok的bodyData
 *
 *  @return 握手成功的body（结构体）
 */
+ (HAND_SUCCESS_BODY) handSuccessBodyDataWithData:(NSData *)body_data andPacket:(IP_PACKET)packet
{
    NSData *bodyData = [NSData data];
    bodyData = body_data;
    if ((packet.flags & MPFlagsCrypto) != 0) { //解密
        bodyData = [MPAesCipher aesDecriptWithEncryptData:body_data withIv:[MPCipherBox getIvBytes] andKey:[MPCipherBox getClientKeyBytes]];
    }
    if (((packet.flags & MPFlagsCompress) != 0)) { // 解压缩
        bodyData = [LFCGzipUtility ungzipData:bodyData];
    }
    
    RFIReader *reader = [[RFIReader alloc] initWithData:bodyData];
    HAND_SUCCESS_BODY handSuccessBody;
    
    //serverKey的长度
    handSuccessBody.serverKey = (char *)reader.readBytes;
    handSuccessBody.heartbeat = reader.readInt32;
    handSuccessBody.sessionId = (char *)reader.readBytes;
    handSuccessBody.expireTime = reader.readInt64;
    
    NSData *sessionKeyData = [MPCipherBox mixAesKey:handSuccessBody.serverKey];
    
    [MPCipherBox setSessionData:sessionKeyData];
    [MPUserDefaults setObject:[NSString stringWithUTF8String:handSuccessBody.sessionId] forKey:MPSessionId];
    [MPUserDefaults setDouble:handSuccessBody.expireTime/1000.0 forKey:MPExpireTime];
    [MPUserDefaults synchronize];
    return handSuccessBody;
}

/**
 *  心跳包
 *
 *  @return 心跳data
 */
+ (NSData *)heartbeatPacketData{
    int8_t heartBytes[] = {-33};
    NSData *heartData = [NSData dataWithBytes:heartBytes length:1];
    return heartData;
}


/**
 *  会话加密所需key （混淆）
 *
 *  @param clientKey 随机生成的16为byte数组
 *  @param serverKey 握手成功返回的serverKey
 *
 *  @return 混淆后的sessionKey
 */
+ (NSData *)mixKeyWithClientKey:(int8_t [])clientKey andServerKey:(int8_t[])serverKey{
    
    int8_t sessionKey[MPAeslength] ;
    for (int i = 0; i < MPAeslength; i++) {
        int8_t a = clientKey[i];
        int8_t b = serverKey[i];
        int sum = abs(a+b);
        int c = (sum % 2 == 0) ? a^b : b^a ;
        sessionKey[i] = (int8_t)c;
    }
    
    NSMutableData *bodyData = [NSMutableData data];
    
    short osNameDataLength = MPAeslength;
    NSData *data = [NSData dataWithBytes:sessionKey length:MPAeslength];
    [bodyData appendData:data];
    
    RFIWriter *writerPacket = [RFIWriter writerWithData:bodyData];
    [writerPacket writeInt16:osNameDataLength];
    [writerPacket writeBytes:data];
    return writerPacket.data;
}

/**
 *  绑定用户id
 *
 *  @param userId 用户id
 */
+ (NSData *)bindDataWithUserId:(NSString *)userId andIsUnbindFlag:(BOOL)isUnbindFlag
{
    //body数据包
    NSMutableData *bodyData = [NSMutableData data];
    RFIWriter *writerPacket = [RFIWriter writerWithData:bodyData];
    [writerPacket writeString:userId];
    
    NSString *aliasStr = @"0";
    [writerPacket writeString:aliasStr];
    
    NSString *tagsStr = @"0";
    [writerPacket writeString:tagsStr];
    
    //数据包
    NSMutableData *packetData = [NSMutableData data];
    MpushMessageBodyCMD bindCmd = MpushMessageBodyCMDBind;
    if (isUnbindFlag) {
        bindCmd = MpushMessageBodyCMDUnbind;
    }
    [packetData appendData:[MessageDataPacketTool ipHeaderWithLength:(uint32_t)writerPacket.data.length cmd:bindCmd cc:0 flags:MPFlagsNone sessionId:[MPSessionStorage genSessionId] lrc:0]];
    [packetData appendData:writerPacket.data];
    
    return packetData;
}

/**
 *  聊天数据包
 *
 *  @param body 聊天消息的内容
 *
 *  @return 聊天data
 */
+ (NSData *)chatDataWithBody:(NSDictionary *)contentDict andUrlStr:(NSString *)urlStr
{    
    // 通过http代理发送数据
    NSMutableData *dataaa = [NSMutableData data];
    NSData *contentJsonData = [NSJSONSerialization dataWithJSONObject:contentDict options:NSJSONWritingPrettyPrinted error:nil];
    NSData *strData = contentJsonData;
    
    short strDataLength = (short)strData.length;
    HTONS(strDataLength);
    NSData *strDataLengthData = [NSData dataWithBytes:&strDataLength length:sizeof(strDataLength)];
    [dataaa appendData:strDataLengthData];
    [dataaa appendData:strData];
    
    int8_t *iv = [MPCipherBox getIvBytes];
    int8_t *sessionKey = [MPCipherBox getSessionBytes];
    
    NSMutableData *bodyData = [NSMutableData data];
    RFIWriter *writerPacket = [RFIWriter writerWithData:bodyData];
    
    //methords
    int8_t method = 1;
    [writerPacket writeByte:method];
    //url
    [writerPacket writeString:urlStr];
    //headers
    NSString *headersStr =[NSString stringWithFormat:@"Content-Type:application/x-www-form-urlencoded\ncharset:UTF-8\ndeviceTypeId:1\nreadTimeout:10000"];
    [writerPacket writeString:headersStr];
    //body
    [writerPacket writeBytes:dataaa];

    //加密
    NSData *enBodyData = [MPAesCipher aesEncriptData:writerPacket.data WithIv:iv andKey:sessionKey];
    NSMutableData *packetData = [NSMutableData data];
    [packetData appendData:[MessageDataPacketTool ipHeaderWithLength:(uint32_t)enBodyData.length cmd:MpushMessageBodyCMDHttp cc:0 flags:MPFlagsCrypto sessionId:[MPSessionStorage genSessionId] lrc:0]];
    [packetData appendData:enBodyData];
    
    return packetData;
}

/**
 ack message data

 @param sessionId 回话请求id
 */
+ (NSData *)ackMessageWithSessionId:(int)sessionId
{
    NSMutableData *packetData = [NSMutableData data];
    [packetData appendData:[MessageDataPacketTool ipHeaderWithLength:0 cmd:MpushMessageBodyCMDAck cc:0 flags:MPFlagsNone sessionId:sessionId lrc:0]];
    return packetData;
}

/**
 *  聊天成功响应
 *
 *  @param bodyData 发送成功的bodyData
 *
 *  @return 发送消息成功的body（结构体）
 */
+ (HTTP_RESPONES_BODY)chatDataSuccessWithData:(NSData *)bodyData
{
    HTTP_RESPONES_BODY httpResponesBody;
    RFIReader *reader = [RFIReader readerWithData:bodyData];
    
    httpResponesBody.statusCode = reader.readInt32;
    FFInLog(@"statusCode: %d", httpResponesBody.statusCode);
    
    httpResponesBody.reasonPhrase = (char *)reader.readBytes;
    FFInLog(@"reasonPhraseStr: %s", httpResponesBody.reasonPhrase);
    
    httpResponesBody.headers = (char *)reader.readBytes;
    
    httpResponesBody.body = (char *)reader.readBytes;
    FFInLog(@"push content:%s",httpResponesBody.body);
    return httpResponesBody;
}

/**
 *  快速重连
 *
 *  @param sessionId    握手成功返回的 会话id
 *  @param deviceId     设备id
 *  @param minHeartbeat 最小心跳数
 *  @param maxHeartbeat 最大心跳数
 *
 *  @return 快速重连所需data
 */
+ (NSData *)fastConnect
{
    NSString *deviceId = [MPUserDefaults objectForKey:MPDeviceId];
    NSString *sessionId = [MPUserDefaults objectForKey:MPSessionId];
    int32_t minHeartbeat = MPMinHeartbeat;
    int32_t maxHeartbeat = MPMaxHeartbeat;

    //body数据包
    NSMutableData *bodyData = [NSMutableData data];
    RFIWriter *writer = [[RFIWriter alloc] initWithData:bodyData];
    [writer writeString:sessionId];
    [writer writeString:deviceId];
    [writer writeInt32:minHeartbeat];
    [writer writeInt32:maxHeartbeat];
    // rsa加密
    NSData *enData = [RSA encryptData:writer.data publicKey:pubkey];
    
    //拼接packet
    NSMutableData *ipHeaderData = [MessageDataPacketTool ipHeaderWithLength:(uint32_t)enData.length cmd:MpushMessageBodyCMDFastConnect cc:0 flags:MPFlagsCrypto sessionId:[MPSessionStorage genSessionId] lrc:0];
    [ipHeaderData appendData:enData];
    
    return ipHeaderData;
}

/**
 *  处理收到的消息
 *
 *  @param packet    协议包
 *  @param body_data 协议包的body data
 *
 *  @return 消息内容
 */
+ (id)processRecievePushMessageWithPacket:(IP_PACKET)packet andData:(NSData *)body_data
{
    NSData *bodyData = [MessageDataPacketTool processFlagWithPacket:packet andBodyData:body_data];
    id contentDic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingMutableContainers error:nil];//转换数据格式
    return contentDic;
}

/**
 *  根据flag对body做相应处理
 *
 *  @param packet    协议包
 *  @param body_data 协议包的body data
 *
 *  @return 处理后的 body data
 */
+ (NSData *) processFlagWithPacket:(IP_PACKET)packet andBodyData:(NSData *)body_data
{
    NSData *bodyData = [NSData data];
    int8_t *iv = [MPCipherBox getIvBytes];
    int8_t *sessionKey = [MPCipherBox getSessionBytes];
    bodyData = body_data;
    if ((packet.flags&MPFlagsCrypto) != 0) { //解密
        bodyData = [MPAesCipher aesDecriptWithEncryptData:body_data withIv:iv andKey:sessionKey];
    }
    if (((packet.flags&MPFlagsCompress) != 0)) { // 解压缩
        bodyData = [LFCGzipUtility ungzipData:bodyData];
    }
    return bodyData;
}

/**
 *  错误信息
 *
 *  @param body 错误信息body
 *
 *  @return 错误信息（结构体）
 */
+ (ERROR_MESSAGE)errorWithBody:(NSData *)body
{
    ERROR_MESSAGE errorMessage;
    RFIReader *reader = [RFIReader readerWithData:body];
    errorMessage.cmd = reader.readByte;
    FFInLog(@"error cmdL: %d",errorMessage.cmd);
    
    errorMessage.code = reader.readByte;
    FFInLog(@"error code: %d",errorMessage.code);
    
    errorMessage.reason = (char *)reader.readBytes;
    FFInLog(@"error reason: %s",errorMessage.reason);
    return errorMessage;
}

/**
 *  ok信息
 *
 *  @param body ok信息body
 *
 *  @return ok信息（结构体）
 */
+ (OK_MESSAGE) okWithBody:(NSData *)body
{
    OK_MESSAGE okMessage;
    RFIReader *reader = [RFIReader readerWithData: body];
    
    okMessage.cmd = reader.readByte;
    FFInLog(@"ok cmd: %d",okMessage.cmd);
    
    okMessage.code = reader.readByte;
    FFInLog(@"ok code: %d",okMessage.code);
    
    okMessage.reason = (char *)reader.readBytes;
    FFInLog(@"ok reason: %s",okMessage.reason);
    return okMessage;
}

/**
 *  kickUser信息
 *
 *  @param body kickUser信息body
 *
 *  @return kickUser信息（结构体）
 */
+ (KICK_USER_MESSAGE) kickUserWithBody:(NSData *)body
{
    KICK_USER_MESSAGE kickUserMessage;
    RFIReader *reader = [RFIReader readerWithData:body];
    kickUserMessage.deviceId = (char *)reader.readBytes;
    FFInLog(@"deviceId kick: %s",kickUserMessage.deviceId);
    
    kickUserMessage.userId = (char *)reader.readBytes;
    FFInLog(@"userId kick: %s",kickUserMessage.userId);
    return kickUserMessage;
}

+ (BOOL)isFastConnect
{
    NSString *sessionId = [MPUserDefaults objectForKey:MPSessionId];
    // 过期时间
    double expireTime = [MPUserDefaults doubleForKey:MPExpireTime];
    // 当前时间
    NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
    
    // 发送握手数据
    if (!sessionId || expireTime < date) {
        return NO;
    } else{
        return YES;
    }
}


@end










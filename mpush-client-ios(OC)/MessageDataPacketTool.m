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


@implementation MessageDataPacketTool



/**
 *  协议头
 *
 *  @param length    boda 长度
 *  @param cmd       数据类型
 *  @param cc        校验码
 *  @param flags     加密、压缩标志
 *  @param sessionId 会话id
 *  @param lrc       <#lrc description#>
 *
 *  @return 协议头data
 */

+ (NSMutableData *)ipHeaderWithLength:(uint32_t)length
                                  cmd:(MpushMessageBodyCMD)cmd
                                   cc:(int16_t)cc
                                flags:(int8_t)flags
                            sessionId:(uint32_t)sessionId
                                  lrc:(int8_t)lrc{
    //协议头
    NSMutableData *packetData = [NSMutableData data];
    RFIWriter *writerPacket = [RFIWriter writerWithData:packetData];
    
    HTONL(length);
    HTONS(cc);
    HTONL(sessionId);
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
+ (NSData *)handshakeMessagePacketData {
    //拼接body
    NSMutableData *bodyData = [NSMutableData data];
    RFIWriter *writerPacket = [RFIWriter writerWithData:bodyData];
    
    //设备唯一标识
    NSString *identifierForVendor = [GSKeyChainDataManager readUUID];
    [MPUserDefaults setObject:identifierForVendor forKey:MPDeviceId];
    [writerPacket writeString:identifierForVendor];
    
    //设备名称
    NSString *iosStr = DEVICE_TYPE;
    [writerPacket writeString:iosStr];
    
    //设备版本号
    NSString *osVersionStr =  appVersion;
    [writerPacket writeString:osVersionStr];
    
    //app版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *clientVersionionStr = [infoDict objectForKey:@"CFBundleShortVersionString"];
    [writerPacket writeString:clientVersionionStr];
    
    // aec加密 模和指数
    char iv[16] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    NSData *ivData = [[NSData alloc] initWithBytes:iv length:16];
    [MPUserDefaults setObject:ivData forKey:MPIvData];
    uint16_t ivLength = 16;
    HTONS(ivLength);
    [writerPacket writeInt16:ivLength];
    [writerPacket writeBytes:ivData];
    
    char clientKey[16] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    NSData *clientKeyData = [[NSData alloc] initWithBytes:clientKey length:16];
    [MPUserDefaults setObject:clientKeyData forKey:MPClientKeyData];
    [MPUserDefaults synchronize];
    [writerPacket writeInt16:ivLength];
    [writerPacket writeBytes:clientKeyData];
    
    //心跳
    int minHeartbeat = MPMinHeartbeat;
    HTONL(minHeartbeat);
    [writerPacket writeInt32:minHeartbeat];
    int maxHeartbeat = MPMaxHeartbeat;
    HTONL(maxHeartbeat);
    [writerPacket writeInt32:maxHeartbeat];
    
    //时间戳
    NSDate *date = [NSDate date];
    NSTimeInterval dateS = date.timeIntervalSince1970;
    long long time = (long long)dateS;
    HTONLL(time);
    [writerPacket writeInt64:time];
    
    // rsa加密
    NSData *enData = [RSA encryptData:writerPacket.data publicKey:pubkey];
    
    //拼接packet
    NSMutableData *ipHeaderData = [MessageDataPacketTool ipHeaderWithLength:(uint32_t)enData.length cmd:MpushMessageBodyCMDHandShakeSuccess cc:0 flags:1 sessionId:1 lrc:0];
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
+ (IP_PACKET)handShakeSuccessResponesWithData:(NSData *)data{
    NSLog(@"data--%@",data);
    
    NSData *lengthData = [data subdataWithRange:NSMakeRange(0, 4)];
    int length;
    
    [lengthData getBytes: &length length: sizeof(length)];
    NTOHL(length);
    
    IP_PACKET ipPacket;
    ipPacket.length = length;
    
    // cmd
    NSData *cmdData = [data subdataWithRange:NSMakeRange(4, 1)];
    int8_t cmd;
    [cmdData getBytes:&cmd length: sizeof(cmd)];
    ipPacket.cmd = cmd;
    
    // cc
    NSData *ccData = [data subdataWithRange:NSMakeRange(5, 2)];
    short cc;
    [ccData getBytes: &cc length: sizeof(cc)];
    NTOHS(cc);
    ipPacket.cc = cc;
    
    // flags
    NSData *flagsData = [data subdataWithRange:NSMakeRange(7, 1)];
    int8_t flags;
    [flagsData getBytes: &flags length: sizeof(flags)];
    ipPacket.flags = flags;
    
    // sessionId
    NSData *sessionIdData = [data subdataWithRange:NSMakeRange(8, 4)];
    int sessionId;
    [sessionIdData getBytes: &sessionId length: sizeof(sessionId)];
    NTOHL(sessionId);
    ipPacket.sessionId = sessionId;
    
    //lrc
    NSData *lrcData = [data subdataWithRange:NSMakeRange(12, 1)];
    int8_t lrc;
    [lrcData getBytes: &lrc length: sizeof(lrc)];
    ipPacket.lrc = lrc;
    
    //body
    NSData *bodyData = [data subdataWithRange:NSMakeRange(13, length)];
    int8_t *bodyBytes = (int8_t *)[bodyData bytes];
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
+ (HAND_SUCCESS_BODY) HandSuccessBodyDataWithData:(NSData *)body_data andPacket:(IP_PACKET)packet{
    int8_t sessionKey[16] ;
    NSData *bodyData;
    if (packet.flags == 1) { //仅加密
        int8_t iv[16];
        NSData *ivData = [MPUserDefaults objectForKey:MPIvData];
        int8_t *ivBytes = (int8_t *)[ivData bytes];
        for (int i = 0; i < ivData.length; i ++) {
            iv[i] = ivBytes[i];
        }
        
        int8_t clientKey[16] ;
        NSData *clientKeyData = [MPUserDefaults objectForKey:MPClientKeyData];
        int8_t *clientKeyBytes = (int8_t *)[clientKeyData bytes];
        for (int i = 0; i < clientKeyData.length; i ++) {
            clientKey[i] = clientKeyBytes[i];
        }
        
        bodyData = [MessageDataPacketTool aesDecriptWithEncryptData:body_data withIv:iv andKey:clientKey];
        
    } else if(packet.flags == 0){ //没加密
        bodyData = body_data;
    } else { //加密又压缩
        NSLog(@"加密又压缩");
        int8_t iv[16];
        NSData *ivData = [MPUserDefaults objectForKey:MPIvData];
        int8_t *ivBytes = (int8_t *)[ivData bytes];
        for (int i = 0; i < ivData.length; i ++) {
            iv[i] = ivBytes[i];
        }
        
        int8_t clientKey[16] ;
        NSData *clientKeyData = [MPUserDefaults objectForKey:MPClientKeyData];
        int8_t *clientKeyBytes = (int8_t *)[clientKeyData bytes];
        for (int i = 0; i < clientKeyData.length; i ++) {
            clientKey[i] = clientKeyBytes[i];
        }
        
        bodyData = [MessageDataPacketTool aesDecriptWithEncryptData:body_data withIv:iv andKey:clientKey];
        bodyData = [LFCGzipUtility ungzipData:bodyData];
    }
    HAND_SUCCESS_BODY handSuccessBody;
    
    //serverKey的长度
    short serverKeyLength = 16;
    NSData *serverKeyData = [bodyData subdataWithRange:NSMakeRange(2, 16)];
    int8_t *serverKeyBytes = (int8_t *) [serverKeyData bytes];
    for (int i = 0; i < 16 ; i ++) {
        handSuccessBody.serverKey[i] = serverKeyBytes[i];
    }
    
    //心跳Data
    NSData *heartbeatData = [bodyData subdataWithRange:NSMakeRange(2+serverKeyLength, 4)];
    int heartbeat ;
    [heartbeatData getBytes:&heartbeat length:sizeof(heartbeat)];
    NTOHL(heartbeat);
    handSuccessBody.heartbeat = heartbeat;
    [MPUserDefaults setDouble:handSuccessBody.heartbeat/1000.0 forKey:MPHeartbeatData];
    
    //sessionId的长度
    NSData *sessionIdLengthData = [bodyData subdataWithRange:NSMakeRange(6+serverKeyLength, 2)];
    short sessionIdLength;
    [sessionIdLengthData getBytes:&sessionIdLength length:sizeof(sessionIdLength)];
    NTOHS(sessionIdLength);
    
    //sessionId的data
    NSData *sessionIdStrData = [bodyData subdataWithRange:NSMakeRange(8+serverKeyLength, sessionIdLength)];
    NSString *sessionIdStr = [[NSString alloc] initWithData:sessionIdStrData encoding:NSUTF8StringEncoding];
    handSuccessBody.sessionId = (char *)sessionIdStr.UTF8String;
    
    //expireTime的长度
    NSData *expireTimeData = [bodyData subdataWithRange:NSMakeRange(8+serverKeyLength+sessionIdLength, 8)];
    long expireTime ;
    [expireTimeData getBytes:&expireTime length:sizeof(expireTime)];
    NTOHLL(expireTime);
    handSuccessBody.expireTime = expireTime;
    
    int8_t clientKey[16] ;
    NSData *clientKeyData = [MPUserDefaults objectForKey:MPClientKeyData];
    int8_t *clientKeyBytes = (int8_t *)[clientKeyData bytes];
    for (int i = 0; i < clientKeyData.length; i ++) {
        clientKey[i] = clientKeyBytes[i];
    }
    
    for (int i = 0; i < 16; i++) {
        int8_t a = clientKey[i];
        int8_t b = handSuccessBody.serverKey[i];
        int sum = abs(a+b);
        int c = (sum % 2 == 0) ? a^b : b^a ;
        sessionKey[i] = (int8_t)c;
    }
    
    NSData *sessionKeyData = [NSData dataWithBytes:sessionKey length:16];
    [MPUserDefaults setObject:sessionKeyData forKey:MPSessionKeyData];
    
    NSLog(@"sessionId---%s",handSuccessBody.sessionId);
    [MPUserDefaults setObject:[NSString stringWithUTF8String:handSuccessBody.sessionId] forKey:MPSessionId];
    
    NSLog(@"expireTime---%ld",handSuccessBody.expireTime);
    [MPUserDefaults setObject:[NSString stringWithFormat:@"%.0f",handSuccessBody.expireTime/1000.0] forKey:MPExpireTime];
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
    
    int8_t sessionKey[16] ;
    for (int i = 0; i < 16; i++) {
        int8_t a = clientKey[i];
        int8_t b = serverKey[i];
        int sum = abs(a+b);
        int c = (sum % 2 == 0) ? a^b : b^a ;
        sessionKey[i] = (int8_t)c;
    }
    
    NSMutableData *bodyData = [NSMutableData data];
    
    short osNameDataLength = 16;
    HTONS(osNameDataLength);
    NSData *data = [NSData dataWithBytes:sessionKey length:16];
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
+ (NSData *)bindDataWithUserId:(NSString *)userId andIsUnbindFlag:(BOOL)isUnbindFlag{
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
    [packetData appendData:[MessageDataPacketTool ipHeaderWithLength:(uint32_t)writerPacket.data.length cmd:bindCmd cc:0 flags:0 sessionId:1 lrc:0]];
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
+ (NSData *)chatDataWithBody:(NSData *)messageBody andUrlStr:(NSString *)urlStr{
    NSData *ivData = [MPUserDefaults objectForKey:MPIvData];
    int8_t *iv = (int8_t *)[ivData bytes];
    NSData *sessionKeyData = [MPUserDefaults objectForKey:MPSessionKeyData];
    int8_t *sessionKey = (int8_t *)sessionKeyData.bytes;
    
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
    [writerPacket writeBytes:messageBody];
    
    //加密
    NSData *enBodyData = [MessageDataPacketTool aesEncriptData:writerPacket.data WithIv:iv andKey:sessionKey];
    
    NSMutableData *packetData = [NSMutableData data];
    [packetData appendData:[MessageDataPacketTool ipHeaderWithLength:(uint32_t)enBodyData.length cmd:MpushMessageBodyCMDHttp cc:0 flags:1 sessionId:1 lrc:0]];
    [packetData appendData:enBodyData];
    
    return packetData;
}

/**
 *  聊天成功响应
 *
 *  @param bodyData 发送成功的bodyData
 *
 *  @return 发送消息成功的body（结构体）
 */
+ (HTTP_RESPONES_BODY)chatDataSuccessWithData:(NSData *)bodyData{
    
    
    HTTP_RESPONES_BODY httpResponesBody;
    
    //statusCode
    NSData *statusCodeData = [bodyData subdataWithRange:NSMakeRange(0, 4)];
    int statusCode ;
    [statusCodeData getBytes:&statusCode length:sizeof(statusCode)];
    NSLog(@"statusCode--%d",statusCode);
    NTOHL(statusCode);
    httpResponesBody.statusCode = statusCode;
    
    //reasonPhrase的长度
    NSData *reasonPhraseLengthData = [bodyData subdataWithRange:NSMakeRange(4, 2)];
    short reasonPhraseLength;
    [reasonPhraseLengthData getBytes:&reasonPhraseLength length:sizeof(reasonPhraseLength)];
    NTOHS(reasonPhraseLength);
    NSLog(@"reasonPhraseLength--%d",reasonPhraseLength);
    //reasonPhrase的data
    NSData *reasonPhraseStrData = [bodyData subdataWithRange:NSMakeRange(6, reasonPhraseLength)];
    NSString *reasonPhraseStr = [[NSString alloc] initWithData:reasonPhraseStrData encoding:NSUTF8StringEncoding];
    NSLog(@"reasonPhraseStr--%@",reasonPhraseStr);
    httpResponesBody.reasonPhrase = (char *)reasonPhraseStr.UTF8String;
    
    //headers的长度
    NSData *headersLengthData = [bodyData subdataWithRange:NSMakeRange(6+reasonPhraseLength, 2)];
    short headersLength;
    [headersLengthData getBytes:&headersLength length:sizeof(headersLength)];
    NTOHS(headersLength);
    NSLog(@"headersLength--%d",headersLength);
    //headers的data
    NSData *headersStrData = [bodyData subdataWithRange:NSMakeRange(8+reasonPhraseLength, headersLength)];
    NSString *headersStr = [[NSString alloc] initWithData:headersStrData encoding:NSUTF8StringEncoding];
    NSLog(@"headersStr--%@",headersStr);
    httpResponesBody.headers = (char *)headersStr.UTF8String;
    
    //bodyBytes的长度
    NSData *bodyBytesLengthData = [bodyData subdataWithRange:NSMakeRange(8+reasonPhraseLength+headersLength, 2)];
    short bodyBytesLength ;
    [bodyBytesLengthData getBytes:&bodyBytesLength length:sizeof(bodyBytesLength)];
    NTOHS(bodyBytesLength);
    NSLog(@"bodyBytesLength----%d",bodyBytesLength);
    
    //bodyBytes的Data
    NSData *bodyBytesData = [bodyData subdataWithRange:NSMakeRange(10+reasonPhraseLength+headersLength, bodyBytesLength)];
    int8_t *bodyBytesDta = (int8_t *) [bodyBytesData bytes];
    NSString *strsss = [[NSString alloc] initWithBytes:bodyBytesDta length:bodyBytesLength encoding:NSUTF8StringEncoding];
    httpResponesBody.body = bodyBytesDta;
    NSLog(@"str--%@",strsss);
    return httpResponesBody;
}

/**
 *  aes加密方法
 *
 *  @param enData 需要加密的数据
 *  @param iv     加密指数
 *  @param key    加密key
 *
 *  @return 加密后的data
 */
+ (NSData *) aesEncriptData:(NSData *)enData WithIv:(int8_t [])iv andKey:(int8_t [])key{
    
    NSLog(@"加密操作-->");
    NSData *data = enData;
    size_t encryptBufferSize = data.length + kCCBlockSizeAES128;
    void *encryptBuffer = malloc(encryptBufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key, kCCKeySizeAES128,
                                          iv ,/* initialization vector (optional) */
                                          [data bytes],
                                          data.length, /* input */
                                          encryptBuffer,
                                          encryptBufferSize, /* output */
                                          &numBytesEncrypted);
    NSData *encryptData = nil;
    if (cryptStatus == kCCSuccess) {
        encryptData = [NSData dataWithBytes:encryptBuffer length:numBytesEncrypted];
        
        NSLog(@"encryptData---%@", encryptData);
    }
    
    free(encryptBuffer); //free the buffer;
    
    return encryptData;
}

/**
 *  aes解密方法
 *
 *  @param enData 需要解密的数据
 *  @param iv     加密指数
 *  @param key    加密key
 *
 *  @return 解密后的data
 */
+ (NSData *) aesDecriptWithEncryptData:(NSData *)encryptData withIv:(int8_t [])iv andKey:(int8_t[])key {
    
    size_t decryptBufferSize = encryptData.length + kCCBlockSizeAES128;
    void *decryptBuffer = malloc(decryptBufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key,
                                          kCCKeySizeAES128,
                                          iv ,/* initialization vector (optional) */
                                          [encryptData bytes],
                                          encryptData.length, /* input */
                                          decryptBuffer,
                                          decryptBufferSize, /* output */
                                          &numBytesDecrypted);
    
    NSData *newSrcData = nil;
    if (cryptStatus == kCCSuccess) {
        newSrcData = [NSData dataWithBytes:decryptBuffer length:numBytesDecrypted];
        NSLog(@"newSrcData---%@", newSrcData);
    }
    
    free(decryptBuffer); //free the buffer;
    
    return newSrcData;
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
+ (NSData *)fastConnect{
    
    NSString *deviceId = [MPUserDefaults objectForKey:MPDeviceId];
    NSString *sessionId = [MPUserDefaults objectForKey:MPSessionId];
    int32_t minHeartbeat = MPMinHeartbeat;
    int32_t maxHeartbeat = MPMaxHeartbeat;

    //body数据包
    NSMutableData *bodyData = [NSMutableData data];
    RFIWriter *writer = [[RFIWriter alloc] initWithData:bodyData];
    HTONL(minHeartbeat);
    HTONL(maxHeartbeat);
    [writer writeString:sessionId];
    [writer writeString:deviceId];
    [writer writeInt32:minHeartbeat];
    [writer writeInt32:maxHeartbeat];
    // rsa加密
    NSData *enData = [RSA encryptData:writer.data publicKey:pubkey];
    
    //拼接packet
    NSMutableData *ipHeaderData = [MessageDataPacketTool ipHeaderWithLength:(uint32_t)enData.length cmd:MpushMessageBodyCMDFastConnect cc:0 flags:1 sessionId:1 lrc:0];
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
+ (id)processRecievePushMessageWithPacket:(IP_PACKET)packet andData:(NSData *)body_data{
    
    NSData *bodyData = [MessageDataPacketTool processFlagWithPacket:packet andBodyData:body_data];
    id contentDic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingMutableContainers error:nil];//转换数据格式
    NSLog(@"contentDic--%@",contentDic);
    
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
+ (NSData *) processFlagWithPacket:(IP_PACKET)packet andBodyData:(NSData *)body_data{
    NSData *bodyData = [NSData data];
    NSData *ivData = [MPUserDefaults objectForKey:MPIvData];
    int8_t *iv = (int8_t *)[ivData bytes];
    NSData *sessionKeyData = [MPUserDefaults objectForKey:MPSessionKeyData];
    int8_t *sessionKey = (int8_t *)sessionKeyData.bytes;
    bodyData = body_data;
    if ((packet.flags&1) != 0) { //解密
        bodyData = [MessageDataPacketTool aesDecriptWithEncryptData:body_data withIv:iv andKey:sessionKey];
    }
    if (((packet.flags&2) != 0)) { // 解压缩
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
+ (ERROR_MESSAGE) errorWithBody:(NSData *)body{
    ERROR_MESSAGE errorMessage;
    NSData *cmd = [body subdataWithRange:NSMakeRange(0, 1)];
    int8_t cmdInt8 ;
    [cmd getBytes:&cmdInt8 length:sizeof(cmdInt8)];
    errorMessage.cmd = cmdInt8;
    NSLog(@"错误命令--%d",cmdInt8);
    
    NSData *code = [body subdataWithRange:NSMakeRange(1, 1)];
    int8_t codeInt8 ;
    [code getBytes:&codeInt8 length:sizeof(codeInt8)];
    errorMessage.code = codeInt8;
    NSLog(@"错误码--%d",codeInt8);
    
    //reason的长度
    NSData *reasonLengthData = [body subdataWithRange:NSMakeRange(2,2)];
    short reasonLength;
    [reasonLengthData getBytes:&reasonLength length:sizeof(reasonLength)];
    NTOHS(reasonLength);
    //sessionId的data
    NSData *reasonStrData = [body subdataWithRange:NSMakeRange(4, reasonLength)];
    NSString *reasonStr = [[NSString alloc] initWithData:reasonStrData encoding:NSUTF8StringEncoding];
    NSLog(@"错误原因--%@",reasonStr);
    errorMessage.reason = (char *)reasonStr.UTF8String;
    return errorMessage;
}

/**
 *  ok信息
 *
 *  @param body ok信息body
 *
 *  @return ok信息（结构体）
 */
+ (OK_MESSAGE) okWithBody:(NSData *)body{
    
    OK_MESSAGE okMessage;
    NSData *cmd = [body subdataWithRange:NSMakeRange(0, 1)];
    int8_t cmdInt8 ;
    [cmd getBytes:&cmdInt8 length:sizeof(cmdInt8)];
    okMessage.cmd = cmdInt8;
    NSLog(@"ok命令--%d",cmdInt8);
    
    NSData *code = [body subdataWithRange:NSMakeRange(1, 1)];
    int8_t codeInt8 ;
    [code getBytes:&codeInt8 length:sizeof(codeInt8)];
    okMessage.code = codeInt8;
    NSLog(@"ok码--%d",codeInt8);
    
    //reason的长度
    NSData *reasonLengthData = [body subdataWithRange:NSMakeRange(2,2)];
    short reasonLength;
    [reasonLengthData getBytes:&reasonLength length:sizeof(reasonLength)];
    //    NTOHS(reasonLength);
    //reason的data
    NSData *reasonStrData = [body subdataWithRange:NSMakeRange(4, reasonLength)];
    NSString *reasonStr = [[NSString alloc] initWithData:reasonStrData encoding:NSUTF8StringEncoding];
    NSLog(@"ok--%@",reasonStr);
    okMessage.reason = (char *)reasonStr.UTF8String;
    return okMessage;
}

+ (BOOL)isFastConnect{
    
    NSString *sessionId = [MPUserDefaults objectForKey:MPSessionId];
    // 过期时间
    NSString *expireTimeStr = [MPUserDefaults objectForKey:MPExpireTime];
    // 当前时间
    NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
    
    // 发送握手数据
    if (!sessionId || expireTimeStr.doubleValue < date) {
        return NO;
    } else{
        return YES;
    }
}



@end










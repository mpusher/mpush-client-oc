//
//  MessageDataPacketTool.h
//  mpush-client-ios(OC)
//
//  Created by Yonglin on 16/8/29.
//  Copyright © 2016年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RSA.h"
#import "RFIWriter.h"
#import "Mpush.h"
#import "LFCGzipUtility.h"
#import "MPSessionStorage.h"


typedef struct _iphdr
{
    uint32_t length;        //body的长度
    int8_t cmd;             //协议消息类型
    short cc;               //根据body生成的校验码
    int8_t flags;           //当前包使用的一些特性
    int32_t sessionId;          //消息会话标示用于消息响应
    int8_t lrc;             //用于校验header
    char *body;
    
}IP_PACKET;

typedef struct _ipbody
{
    char *deviceId;         //设备id
    char *osName;           //设备名称
    char *osVersion;        //设备版本
    char *clientVersion;    //客户端版本
    int8_t iv[MPAeslength] ;         //aes加密指数 （16位随机数）
    int8_t clientKey[MPAeslength];   //aes加密key （16位随机数）
    int minHeartbeat;       //最小心跳数（单位毫秒）
    int maxHeartbeat;       //最大心跳数（单位毫秒）
    long timestamp;         //时间戳
}IP_BODY;

/**
 *  握手成功的body
 */
typedef struct _handSuccessBody
{
    int8_t serverKey[MPAeslength];   //服务段返回的key 用于aes加密的
    int heartbeat;          //消息会话标示用于消息响应
    char *sessionId;        //会话id
    long expireTime;        //失效时间
    
}HAND_SUCCESS_BODY;


/**
 *  握手成功的packet
 */
typedef struct _handSuccess
{
    uint32_t length;        //body的长度
    int8_t cmd;             //协议消息类型
    short cc;               //根据body生成的校验码
    int8_t flags;           //当前包使用的一些特性
    int sessionId;          //消息会话标示用于消息响应
    int8_t lrc;             //用于校验header
    int8_t *body;
    
}HAND_SUCCESS;

/**
 *  error的body
 */
typedef struct error
{
    int8_t cmd;             //协议消息类型
    int8_t code;            //错误码
    char *reason;           //错误原因
    
}ERROR_MESSAGE;

/**
 *  OK的body
 */
typedef struct OKMessage
{
    int8_t cmd;             //协议消息类型
    int8_t code;            //错误码
    char *reason;           //错误原因
    
}OK_MESSAGE;

/**
 *  http响应的body
 */
typedef struct _httpResponesBody
{
    int32_t statusCode;     //状态码
    char *reasonPhrase;    //会话id
    char *headers;    //会话id
    char *body;   //响应体
    
}HTTP_RESPONES_BODY;

/**
 *  kick user
 */
typedef struct _kickUser
{
    char *deviceId;
    char *userId;
    
}KICK_USER_MESSAGE;


typedef NS_ENUM(NSInteger, MpushMessageBodyCMD) {
    MpushMessageBodyCMDHandShakeSuccess = 2,	// 握手成功
    MpushMessageBodyCMDLogin = 3,    // 登录
    MpushMessageBodyCMDLogout = 4,   //退出
    MpushMessageBodyCMDBind = 5,    // 绑定
    MpushMessageBodyCMDUnbind = 6,    // 解除绑定
    MpushMessageBodyCMDFastConnect = 7,    //快速重连
    MpushMessageBodyCMDStop = 8,    //暂停
    MpushMessageBodyCMDResume = 9,    // 重新开始
    MpushMessageBodyCMDError = 10,    // 错误
    MpushMessageBodyCMDOk= 11,    //OK
    MpushMessageBodyCMDHttp = 12,    // Http代理
    MpushMessageBodyCMDKick = 13,   // 踢人
    MpushMessageBodyCMDPush = 15,    // 推送
    MpushMessageBodyCMDChat = 19,    // 聊天
    MpushMessageBodyCMDAck = 23,     // 确认收到
    MpushMessageBodyCMDUnknown = -1     //未知消息
};

typedef enum {
    MPFlagsNone = 0x0,
    MPFlagsCrypto = 0x1,
    MPFlagsCompress = 0x2,
    MPFlagsBizAck = 0x4,
    MPFlagsAutoAck = 0x8
} MPFlags;


static NSString *const pubkey = @"-------BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCghPCWCobG8nTD24juwSVataW7\niViRxcTkey/B792VZEhuHjQvA3cAJgx2Lv8GnX8NIoShZtoCg3Cx6ecs+VEPD2f\nBcg2L4JK7xldGpOJ3ONEAyVsLOttXZtNXvyDZRijiErQALMTorcgi79M5uVX9/j\nMv2Ggb2XAeZhlLD28fHwIDAQAB\n-----END PUBLIC KEY-----";


@interface MessageDataPacketTool : NSObject

/**
 *  握手数据包
 *
 *  @return 握手数据data
 */
+ (NSData *)handshakeMessagePacketData;

/**
 *  握手成功响应包
 *
 *  @param data read的data
 *
 *  @return ip协议包（结构体类型）
 */

+ (IP_PACKET)handShakeSuccessResponesWithData:(NSData *)data;

/**
 *  握手成功解析body
 *
 *  @param bodyData 握手成功响应包
 *
 *  @return 握手成功数据包的body
 */
+ (HAND_SUCCESS_BODY) handSuccessBodyDataWithData:(NSData *)body_data andPacket:(IP_PACKET)packet;
/**
 *  心跳包
 *
 *  @return 心跳data
 */

+ (NSData *)heartbeatPacketData;
/**
 *  会话加密所需key （混淆）
 *
 *  @param clientKey 随机生成的16为byte数组
 *  @param serverKey 握手成功返回的serverKey
 *
 *  @return 混淆后的sessionKey
 */
//+ (NSData *)mixKeyWithClientKey:(int8_t [])clientKey andServerKey:(int8_t [])serverKey;

/**
 *  绑定用户id
 *
 *  @param userId 用户id
 */
+ (NSData *)bindDataWithUserId:(NSString *)userId andIsUnbindFlag:(BOOL)isUnbindFlag;

/**
 ack message data
 
 @param sessionId 回话请求id
 */
+ (NSData *)ackMessageWithSessionId:(int)sessionId;

/**
 *  聊天消息数据包
 *
 *  @param messageBody             聊天消息的内容
 *
 *  @return     完整的聊天数据包
 */
+ (NSData *)chatDataWithBody:(NSDictionary *)contentDict andUrlStr:(NSString *)urlStr;

/**
 *  请求成功
 *
 *  @param bodyData 发送成功的bodyData
 *
 *  @return 发送消息成功的body（结构体）
 */
+ (HTTP_RESPONES_BODY)chatDataSuccessWithData:(NSData *)bodyData;


/**
 *  错误信息
 *
 *  @param body 错误信息body
 *
 *  @return 错误信息（结构体）
 */
+ (ERROR_MESSAGE) errorWithBody:(NSData *)body;

/**
 *  ok信息
 *
 *  @param body ok信息body
 *
 *  @return ok信息（结构体）
 */
+ (OK_MESSAGE) okWithBody:(NSData *)body;

/**
 *  kickUser信息
 *
 *  @param body kickUser信息body
 *
 *  @return kickUser信息（结构体）
 */
+ (KICK_USER_MESSAGE) kickUserWithBody:(NSData *)body;

/**
 *  处理收到的push消息
 *
 *  @param packet    协议包
 *  @param body_data 协议包的body data
 *
 *  @return 消息内容
 */
+ (id)processRecievePushMessageWithPacket:(IP_PACKET)packet andData:(NSData *)body_data;

/**
 *  根据flag对body做相应处理
 *
 *  @param packet    协议包
 *  @param body_data 协议包的body data
 *
 *  @return 处理后的 body data
 */
+ (NSData *) processFlagWithPacket:(IP_PACKET)packet andBodyData:(NSData *)body_data;

/**
 *  是否快速重连 yes快速重连
 */
+ (BOOL)isFastConnect;
/**     
 *快速重连   
 */
+ (NSData *)fastConnect;


@end






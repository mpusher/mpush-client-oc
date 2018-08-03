//
//  MPPacket.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>


#define HEADER_LEN 13
#define FLAG_CRYPTO 0x1
#define FLAG_COMPRESS 0x2
#define FLAG_BIZ_ACK 0x4
#define FLAG_AUTO_ACK 0x8

#define HB_PACKET_BYTE -33


typedef NS_ENUM(int8_t, MPCmd) {
    MPCmdHeartbeat = 1,
    MPCmdHandShake = 2,    // 握手成功
    MPCmdLogin = 3,    // 登录
    MPCmdLogout = 4,   //退出
    MPCmdBind = 5,    // 绑定
    MPCmdUnbind = 6,    // 解除绑定
    MPCmdFastConnect = 7,    //快速重连
    MPCmdStop = 8,    //暂停
    MPCmdResume = 9,    // 重新开始
    MPCmdError = 10,    // 错误
    MPCmdOk= 11,    //OK
    MPCmdHttp = 12,    // Http代理
    MPCmdKick = 13,   // 踢人
    MPCmdPush = 15,    // 推送
    MPCmdChat = 19,    // 聊天
    MPCmdAck = 23,     // 确认收到
    MPCmdUnknown = -1     //未知消息
};

typedef enum {
    MPFlagsNone = 0x0,
    MPFlagsCrypto = 0x1,
    MPFlagsCompress = 0x2,
    MPFlagsBizAck = 0x4,
    MPFlagsAutoAck = 0x8
} MPFlags;

@interface MPPacket : NSObject


@property (nonatomic, assign)int32_t length;
@property (nonatomic, assign)MPCmd cmd;
@property (nonatomic, assign)int16_t cc;
@property (nonatomic, assign)int8_t flags;
@property (nonatomic, assign)int32_t sessionId;
@property (nonatomic, assign)int8_t lrc;
@property (nonatomic, strong)NSData *body;

- (instancetype)initWithLength:(int32_t)length andCmd:(int8_t)cmd andCc:(int16_t)cc andFlags:(int8_t)flags andSessionId:(int32_t)sessionId andlrc:(int8_t)lrc andBody:(NSData *)body;
- (instancetype)initWithCmd:(MPCmd)cmd andSessionId:(int32_t)sessionId;
- (void)addFlag:(MPFlags)flag;
- (BOOL)hasFlag:(MPFlags)flag;
//- (int32_t)getBodyLength;

@end

//
//  MPClient.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/1.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "MPOkMessage.h"
#import "MPErrorMessage.h"
#import "MPHttpResponseMessage.h"
#import "MPPushMessage.h"
#import "MPKickUserMessage.h"

@class MPClient;

@protocol  MPClientDelegate <NSObject>

@optional
// 连接
- (void)client:(MPClient *)client onConnectedSock:(GCDAsyncSocket *)sock;
// 断开连接
- (void)client:(MPClient *)client onDisConnectedSock:(GCDAsyncSocket *)sock;
// 握手成功
- (void)client:(MPClient *)client onHandshakeOk:(int32_t)heartbeat;
// 收到心跳
- (void)clientOnRecieveHeartBeat:(MPClient *)client;
// 收到okMessage
- (void)client:(MPClient *)client onRecieveOkMsg:(MPOkMessage *)okMsg;
// 收到errorMessage
- (void)client:(MPClient *)client onRecieveErrorMsg:(MPErrorMessage *)errorMsg;
// httpProxy响应
- (void)client:(MPClient *)client onHttpProxyResponse:(MPHttpResponseMessage *)httpResponseMsg;
// 收到推送消息
- (void)client:(MPClient *)client onRecievePushMsg:(MPPushMessage *)pushMessage;
// 收到被踢消息
- (void)client:(MPClient *)client onKickUser:(MPKickUserMessage *)kickUser;

@end

@interface MPClient : NSObject

@property (nonatomic, weak)id<MPClientDelegate> delegate;
+ (instancetype)sharedClient;

- (void)connectToHost;
- (void)disconnect;
- (void)reconnect;
- (BOOL)isRunning;
- (BOOL)healthCheck;

/**
 绑定用户
 */
- (void)bindUserWithUserId:(NSString *)userId;
/**
 解绑用户
 */
- (void)unbindUserWithUserId:(NSString *)userId;
/**
 通过HttpProxy发送push信息
 */
- (void)sendPushMessageWithContent:(NSMutableDictionary *)contentDic;
/**
 发送完整包数据
 */
- (void)sendMessageData:(NSData *)messageData;
/**
 手动ack
 */
- (void)sendBizAckMessage:(MPPushMessage *)message;

@end

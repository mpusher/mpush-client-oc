//
//  MessageHandler.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageDataPacketTool.h"
@class MPMessageHandler;

typedef void(^SuccessCallBack)(id successContent);
typedef void(^FailureCallBack)(id failureContent);

@protocol MPMessageHandlerDelegate<NSObject>

@optional
/**
 绑定用户成功
 */
-(void)messageHandler:(MPMessageHandler *)handler didBindUser:(NSString *)userId;
/**
 解除绑定用户成功
 */
-(void)messageHandler:(MPMessageHandler *)handler didUnbindUser:(NSString *)userId;
/**
 接收消息
 */
-(void)messageHandler:(MPMessageHandler *)handler didRecieveMessage:(NSString *)messageString;
/**
 踢用户下线消息
 */
-(void)messageHandler:(MPMessageHandler *)handler didKickUserWithUserId:(NSString *)userId andDeviceId:(NSString *)deviceId;

@end


@interface MPMessageHandler : NSObject

+ (instancetype)shareMessageHandler;

@property (nonatomic, weak)id<MPMessageHandlerDelegate> delegate;
/**
 获取分配的 主机ip 和 端口号 并建立socket连接
 */
- (void)connectToHostSuccess:(SuccessCallBack)success;

/**
 断开连接
 */
- (void)disconnectSuccess:(SuccessCallBack)success;

/**
 绑定用户id
 */
- (void)bindUserWithUserId:(NSString *)userId;

/**
 解除绑定用户
 */
- (void)unbindUserWithUserId:(NSString *)userId;

/**
 发送push消息
 */
- (void)sendPushMessageWithContent:(NSDictionary *)contentDic andSuccess:(SuccessCallBack)success andFailure:(FailureCallBack)failure;
/**
 是否连接
 */
- (BOOL)isRunning;



@end

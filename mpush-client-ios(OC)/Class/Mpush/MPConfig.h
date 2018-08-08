//
//  MPConfig.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//  配置文件（单例）

#import <Foundation/Foundation.h>

@interface MPConfig : NSObject

@property (nonatomic, copy) NSString *allotServer;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *toUserId;

@property (nonatomic, copy) NSString *serverHost;
@property (nonatomic, assign)NSInteger serverPort;
@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *osName;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSString *clientVersion;
@property (nonatomic, assign)int32_t maxHeartbeat;
@property (nonatomic, assign)int32_t minHeartbeat;
@property (nonatomic, assign)int aesKeyLength;
@property (nonatomic, assign)int32_t compressLimit;

@property (nonatomic, assign)int maxConnectTimes;
@property (nonatomic, assign)int maxHBTimeOutTimes;
//@property (nonatomic, assign)BOOL logEnabled;
//@property (nonatomic, assign)BOOL enableHttpProxy;


+ (MPConfig *)defaultConfig;


@end

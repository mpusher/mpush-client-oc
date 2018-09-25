//
//  MPConfig.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPConfig.h"
#import "GSKeyChainDataManager.h"

@implementation MPConfig

//        114.116.50.243:9999 imo2o_136923
+ (MPConfig *)defaultConfig{
    static MPConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        config = [[MPConfig alloc] init];
//        103.60.220.145:9999 官
        config.allotServer = @"http://103.60.220.145:9999";
        config.userId = @"12345";
        config.toUserId = @"12345";
        
        config.publicKey = @"-------BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCghPCWCobG8nTD24juwSVataW7\niViRxcTkey/B792VZEhuHjQvA3cAJgx2Lv8GnX8NIoShZtoCg3Cx6ecs+VEPD2f\nBcg2L4JK7xldGpOJ3ONEAyVsLOttXZtNXvyDZRijiErQALMTorcgi79M5uVX9/j\nMv2Ggb2XAeZhlLD28fHwIDAQAB\n-----END PUBLIC KEY-----";
        NSLog(@"%@",[GSKeyChainDataManager readUUID]);
        config.deviceId = [GSKeyChainDataManager readUUID];
        config.osName = @"ios";
        config.osVersion = [[UIDevice currentDevice] systemVersion];
        config.clientVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        config.maxHeartbeat = 30;
        config.minHeartbeat = 30;
        config.aesKeyLength = 16;
        config.compressLimit = 10240;
        
        config.maxConnectTimes = 6;
        config.maxHBTimeOutTimes = 2;
//        config.logEnabled = false;
//        config.enableHttpProxy = false;
    });
    return config;
}

@end

//
//  MPConfig.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPConfig.h"
#import "GSKeyChainDataManager.h"
#import <UIKit/UIKit.h>

@implementation MPConfig

+ (MPConfig *)defaultConfig{
    static MPConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //#define PUSH_HOST_ADDRESS @"http://114.116.50.243:9999"
        //    imo2o_74562
        
//        config.allotServer = @"http://103.60.220.145:9999"; 官方
        config = [[MPConfig alloc] init];
//        config.allotServer = @"http://103.60.220.145:9999";  // 官方
        config.allotServer = @"http://114.116.50.243:9999";
        config.publicKey = @"-------BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCghPCWCobG8nTD24juwSVataW7\niViRxcTkey/B792VZEhuHjQvA3cAJgx2Lv8GnX8NIoShZtoCg3Cx6ecs+VEPD2f\nBcg2L4JK7xldGpOJ3ONEAyVsLOttXZtNXvyDZRijiErQALMTorcgi79M5uVX9/j\nMv2Ggb2XAeZhlLD28fHwIDAQAB\n-----END PUBLIC KEY-----";
        NSLog(@"%@",[GSKeyChainDataManager readUUID]);
        config.deviceId = [GSKeyChainDataManager readUUID];
        config.osName = @"ios";
        config.osVersion = [[UIDevice currentDevice] systemVersion];
        config.clientVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
//        config.userId = userId;
        config.maxHeartbeat = 30;
        config.minHeartbeat = 30;
        config.aesKeyLength = 16;
        config.compressLimit = 10240;
        
        config.maxConnectTimes = 6;
        config.maxHBTimeOutTimes = 2;
        config.logEnabled = false;
        config.enableHttpProxy = false;
    });
    return config;
}

@end

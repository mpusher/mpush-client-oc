//
//  Mpush.h
//  mpush-client-ios(OC)
//
//  Created by Yonglin on 16/8/29.
//  Copyright © 2016年 Yonglin. All rights reserved.
//

#ifndef Mpush_h
#define Mpush_h


#define PUSH_HOST_ADDRESS @"http://103.60.220.145:9999"

#define DEVICE_TYPE @"ios"
#define appVersion @"9.2.1"
#define MPMinHeartbeat 20
#define MPMaxHeartbeat 20
/// 最大连接次数
#define MPMaxConnectTimes 6
/// 超时时间
#define MPTimeOutIntervel 90
/// 写入tag
#define MPWriteDatatag 0
#define MPMaxHBTimeOutTimes 2

#define MPAeslength 16


#define MPUserDefaults  [NSUserDefaults standardUserDefaults]
#define MPIvData @"BCJIvData"
#define MPClientKeyData @"BCJClientKeyData"
#define  MPSessionKeyData @"BCJSessionKeyData"
#define  MPSessionId @"BCJSessionId"
#define  MPExpireTime @"BCJExpireTime"
#define MPDeviceId @"identifierForVendor"


#ifdef DEBUG  //在调试模式下
#define FFLog(fmt, ...) NSLog((@"[Line-%d] %s >>>>>>" fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#define FFInLog(fmt, ...) NSLog((@"[Line-%d] %s <<<<<<" fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#else  //Release模式下
#define FFLog(...)
#endif


#endif /* Mpush_h */

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
#define MPIvData @"MPIvData"
#define MPClientKeyData @"MPClientKeyData"
#define  MPSessionKeyData @"MPSessionKeyData"
#define  MPSessionId @"MPSessionId"
#define  MPExpireTime @"MPExpireTime"
#define MPDeviceId @"MPIdentifierForVendor"


#ifdef DEBUG  //在调试模式下
#define MPLog(fmt, ...) NSLog((@"[Line-%d] %s >>>>>>" fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#define MPInLog(fmt, ...) NSLog((@"[Line-%d] %s <<<<<<" fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#else  //Release模式下
#define MPLog(...)
#endif


#endif /* Mpush_h */

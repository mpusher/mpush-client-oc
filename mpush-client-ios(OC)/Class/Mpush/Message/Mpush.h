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

//#define DEVICE_TYPE @"ios"
//#define appVersion @"9.2.1"
//#define MPMinHeartbeat 5
//#define MPMaxHeartbeat 5
/// 最大连接次数
#define MPMaxConnectTimes 6
#define MPMaxHBTimeOutTimes 2

#define MPUserDefaults  [NSUserDefaults standardUserDefaults]
#define MPIvData @"MPIvData"
#define MPClientKeyData @"MPClientKeyData"
#define  MPSessionKeyData @"MPSessionKeyData"
#define  MPSessionId @"MPSessionId"
#define  MPExpireTime @"MPExpireTime"
#define MPDeviceId @"MPIdentifierForVendor"
#define HOST_ADDRESS_KEY @"HOST_ADDRESS_KEY"


#ifdef DEBUG  //在调试模式下
#define MPLog(fmt, ...) NSLog((@"[Line-%d] %s >>>>>>" fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#define MPInLog(fmt, ...) NSLog((@"[Line-%d] %s <<<<<<" fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#else  //Release模式下
#define MPLog(...)
#define MPInLog(...)
#endif


#endif /* Mpush_h */

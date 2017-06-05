//
//  Mpush.h
//  mpush-client-ios(OC)
//
//  Created by Yonglin on 16/8/29.
//  Copyright © 2016年 Yonglin. All rights reserved.
//

#ifndef Mpush_h
#define Mpush_h

#define DEVICE_TYPE @"ios"
#define appVersion @"9.2.1";

#define MPUserDefaults  [NSUserDefaults standardUserDefaults]
#define  MPIvData @"BCJIvData"
#define  MPClientKeyData @"BCJClientKeyData"
#define PUSH_HOST_ADDRESS @"http://103.246.161.44:9999/push"

#define  MPSessionKeyData @"BCJSessionKeyData"
#define  MPSessionId @"BCJSessionId"
#define  MPExpireTime @"BCJExpireTime"
#define MPDeviceId @"identifierForVendor"
#define MPMinHeartbeat 180
#define MPMaxHeartbeat 180
#define MPMaxConnectTimes 6


#endif /* Mpush_h */

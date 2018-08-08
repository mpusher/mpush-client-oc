//
//  SessionStorage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/5.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  MPSessionId @"MPSessionId"
#define  MPExpireTime @"MPExpireTime"
#define MPDeviceId @"MPIdentifierForVendor"
#define HOST_ADDRESS_KEY @"HOST_ADDRESS_KEY"

@interface MPSessionStorage : NSObject


@property (nonatomic, assign)double expireTime;
@property (nonatomic, copy) NSString *sessionId;

+ (void)saveSessionWithSessionId:(NSString *)sessionId andExpireTime:(double)expireTime;
+ (NSDictionary *)getSessionStorage;
+ (void)clearSession;
//+ (int)genSessionId;

@end

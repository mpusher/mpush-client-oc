//
//  SessionStorage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/5.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPSessionStorage.h"
#import "Mpush.h"
#import <stdatomic.h>
#import "MPConfig.h"



@implementation MPSessionStorage

+ (void)saveSessionWithSessionId:(NSString *)sessionId andExpireTime:(double)expireTime
{
    [MPUserDefaults setObject:sessionId forKey:MPSessionId];
    [MPUserDefaults setDouble:expireTime forKey:MPExpireTime];
    [MPUserDefaults setObject:[MPConfig defaultConfig].allotServer forKey:HOST_ADDRESS_KEY];
    [MPUserDefaults synchronize];
}

+ (NSDictionary *)getSessionStorage
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    double expireTime = [MPUserDefaults doubleForKey:MPExpireTime];
    NSString *sessionId = [MPUserDefaults objectForKey:MPSessionId];
    NSString *pushHostAddress = [MPUserDefaults objectForKey:HOST_ADDRESS_KEY];
    dictionary[MPSessionId] = sessionId;
    dictionary[MPExpireTime] = @(expireTime);
    dictionary[HOST_ADDRESS_KEY] = pushHostAddress;
    return dictionary;
}

+ (void)clearSession
{
    [MPUserDefaults removeObjectForKey:MPSessionId];
    [MPUserDefaults removeObjectForKey:HOST_ADDRESS_KEY];
    [MPUserDefaults setDouble:0.0 forKey: MPExpireTime];
    [MPUserDefaults synchronize];
}

//+ (int)genSessionId
//{
//    static atomic_int counter;
//    atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
//    return counter;
//}

@end




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



@implementation MPSessionStorage

+ (void)saveSessionWithSessionId:(NSString *)sessionId andExpireTime:(double)expireTime
{
    [MPUserDefaults setObject:sessionId forKey:MPSessionId];
    [MPUserDefaults setDouble:expireTime forKey:MPExpireTime];
    [MPUserDefaults synchronize];
}

+ (NSDictionary *)getSessionStorage
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    double expireTime = [MPUserDefaults doubleForKey:MPExpireTime];
    NSString *sessionId = [MPUserDefaults objectForKey:MPSessionId];
    dictionary[MPSessionId] = sessionId;
    dictionary[MPExpireTime] = @(expireTime);
    return dictionary;
}

+ (void)clearSession
{
    [MPUserDefaults removeObjectForKey:MPSessionId];
    [MPUserDefaults setDouble:0.0 forKey: MPExpireTime];
    [MPUserDefaults synchronize];
}

+ (int)genSessionId
{
    static atomic_int counter;
    atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
    return counter;
}

@end




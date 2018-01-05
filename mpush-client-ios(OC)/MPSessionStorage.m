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

- (instancetype)initWithSessionId:(NSString *)sessionId expireTime:(double)expireTime
{
    if (self = [super init]) {
        self.sessionId = sessionId;
        self.expireTime = expireTime;
    }
    return self;
}

- (void)saveSession
{
    [MPUserDefaults setObject:self.sessionId forKey:MPSessionId];
    [MPUserDefaults setDouble:self.expireTime/1000.0 forKey:MPExpireTime];
    [MPUserDefaults synchronize];
}

- (MPSessionStorage *)getSessionStorage
{
    double expireTime = [MPUserDefaults doubleForKey:MPExpireTime];
    NSString *sessionId = [MPUserDefaults objectForKey:MPSessionId];
    self.expireTime = expireTime;
    self.sessionId = sessionId;
    return self;
}

- (void)clearSession
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




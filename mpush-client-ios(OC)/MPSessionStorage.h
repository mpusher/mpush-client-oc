//
//  SessionStorage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/5.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPSessionStorage : NSObject


@property (nonatomic, assign)double expireTime;
@property (nonatomic, copy) NSString *sessionId;

- (instancetype)initWithSessionId:(NSString *)sessionId expireTime:(double)expireTime;
- (void)saveSession;
- (MPSessionStorage *)getSessionStorage;
+ (int)genSessionId;

@end

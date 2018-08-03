//
//  MPBindUserMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/1.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

@interface MPBindUserMessage : MPBaseMessage

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *tags;

+ (instancetype)bindUser:(NSString *)userId;
+ (instancetype)bindUser:(NSString *)userId andAlias:(NSString *)alias andTags:(NSString *)tags;
+ (instancetype)unbindUser:(NSString *)userId;
+ (instancetype)unbindUser:(NSString *)userId andAlias:(NSString *)alias andTags:(NSString *)tags;


@end

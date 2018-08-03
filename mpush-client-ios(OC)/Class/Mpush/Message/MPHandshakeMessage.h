//
//  MPHandshakeMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

@interface MPHandshakeMessage : MPBaseMessage


@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *osName;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSString *clientVersion;

@property (nonatomic, strong)NSData *iv;
@property (nonatomic, strong)NSData *clientKey;
@property (nonatomic, assign)int32_t maxHeartbeat;
@property (nonatomic, assign)int32_t minHeartbeat;
@property (nonatomic, assign)long long timestamp;

@end

//
//  MPFastConnectMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

@interface MPFastConnectMessage : MPBaseMessage

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, assign)int32_t minHeartbeat;
@property (nonatomic, assign)int32_t maxHeartbeat;

@end

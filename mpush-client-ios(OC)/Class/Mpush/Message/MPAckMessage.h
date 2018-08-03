//
//  MPAckMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

@interface MPAckMessage : MPBaseMessage
- (instancetype)initWithSessionId:(int32_t)sessionId;
@end

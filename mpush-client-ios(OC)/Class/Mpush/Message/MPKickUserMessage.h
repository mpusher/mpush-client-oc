//
//  MPKickUserMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

@interface MPKickUserMessage : MPBaseMessage
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *userId;
@end

//
//  MPHandshakeOkMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

@interface MPHandshakeOkMessage : MPBaseMessage

@property (nonatomic, strong)NSData *serverKey;
@property (nonatomic, assign)int32_t heartbeat;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, assign)int64_t expireTime;


@end

//
//  MPPushMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

@interface MPPushMessage : MPBaseMessage
@property (nonatomic, strong)NSData *content;
//@property (nonatomic, strong) NSDictionary *contentDict;
- (BOOL)autoAck;
- (BOOL)bizAck;
@end

//
//  MPErrorMessage.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/1.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBaseMessage.h"

@interface MPErrorMessage : MPBaseMessage

@property (nonatomic, assign)int8_t cmd;
@property (nonatomic, assign)int8_t code;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) NSString *reason;

@end

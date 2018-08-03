//
//  MPPushMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPPushMessage.h"

@implementation MPPushMessage
- (void)decodeWithBody:(NSData *)body{
    self.content = body;
    
//    self.contentDict = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableContainers error:nil];
}

- (BOOL)autoAck{
    return [self.packet hasFlag:(MPFlagsAutoAck)];
}

- (BOOL)bizAck{
    return [self.packet hasFlag:(MPFlagsBizAck)];
}

@end

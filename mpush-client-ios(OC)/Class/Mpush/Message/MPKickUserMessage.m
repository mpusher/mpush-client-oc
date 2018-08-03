//
//  MPKickUserMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPKickUserMessage.h"
#import "Mpush.h"

@implementation MPKickUserMessage


- (void)decodeWithBody:(NSData *)body{
    
    NSMutableData *bodyData = [NSMutableData dataWithData:body];
    RFIReader *reader = [[RFIReader alloc] initWithData: bodyData];
    self.deviceId = [reader readString];
    self.userId = [reader readString];
}

@end

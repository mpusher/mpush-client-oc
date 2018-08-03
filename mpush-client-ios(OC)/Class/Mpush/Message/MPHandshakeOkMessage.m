//
//  MPHandshakeOkMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHandshakeOkMessage.h"

@implementation MPHandshakeOkMessage

- (void)decodeWithBody:(NSData *)body{
    NSMutableData *bodyData = [NSMutableData dataWithData:body];
    RFIReader *reader = [[RFIReader alloc] initWithData: bodyData];
    self.serverKey = [reader readData];
    self.heartbeat = [reader readInt32];
    self.sessionId = [reader readString];
    self.expireTime = [reader readInt64];
}

@end

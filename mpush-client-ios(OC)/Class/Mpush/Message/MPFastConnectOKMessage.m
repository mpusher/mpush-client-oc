//
//  MPFastConnectOKMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/30.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPFastConnectOKMessage.h"

@implementation MPFastConnectOKMessage
- (void)decodeWithBody:(NSData *)body{
    NSMutableData *bodyData = [NSMutableData dataWithData:body];
    RFIReader *reader = [[RFIReader alloc] initWithData: bodyData];
    self.heartbeat = [reader readInt32];
}
@end

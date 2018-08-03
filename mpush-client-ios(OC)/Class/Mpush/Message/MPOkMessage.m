//
//  MPOkMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/1.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPOkMessage.h"

@implementation MPOkMessage
-(void)decodeWithBody:(NSData *)body{
    NSMutableData *bodyData = [NSMutableData dataWithData:body];
    RFIReader *reader = [[RFIReader alloc] initWithData: bodyData];
    self.cmd = [reader readByte];
    self.code = [reader readByte];
    self.data = [reader readString];
}

//- (NSString *)debugDescription{
//    return [NSString stringWithFormat:@"okMessage = {cmd: %d, code: %d, data: %@}",self.cmd, self.code, self.data];
//}


@end

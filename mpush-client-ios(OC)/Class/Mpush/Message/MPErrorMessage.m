//
//  MPErrorMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/1.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPErrorMessage.h"

@implementation MPErrorMessage

-(void)decodeWithBody:(NSData *)body{
    NSMutableData *bodyData = [NSMutableData dataWithData:body];
    RFIReader *reader = [[RFIReader alloc] initWithData: bodyData];
    self.cmd = [reader readByte];
    self.code = [reader readByte];
    self.reason = [reader readString];
    self.data = [reader readString];
    
}



@end

//
//  MPPacket.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPPacket.h"

@implementation MPPacket


- (instancetype)initWithLength:(int32_t)length andCmd:(int8_t)cmd andCc:(int16_t)cc andFlags:(int8_t)flags andSessionId:(int32_t)sessionId andlrc:(int8_t)lrc andBody:(NSData *)body{
    if (self = [super init]) {
        self.length = length;
        self.cmd = cmd;
        self.cc = cc;
        self.flags = flags;
        self.sessionId = sessionId;
        self.lrc = lrc;
        self.body = body;
        
    }
    return self;
}

- (instancetype)initWithCmd:(MPCmd)cmd andSessionId:(int32_t)sessionId{
    return [self initWithLength:0 andCmd:cmd andCc:0 andFlags:0 andSessionId:sessionId andlrc:0 andBody:nil];
}

- (void)addFlag:(MPFlags)flag{
    self.flags |= flag;
}

- (BOOL)hasFlag:(MPFlags)flag{
    return (self.flags&flag) != 0;
}



@end

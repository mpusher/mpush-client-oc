//
//  MPBindUserMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/1.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPBindUserMessage.h"

@implementation MPBindUserMessage

- (instancetype)initWithCmd:(MPCmd)cmd{
    return [super initWithPacket:[[MPPacket alloc] initWithCmd:cmd andSessionId:[MPBaseMessage genRequestSessionId]]];
}

- (instancetype)initWithCmd:(MPCmd)cmd  andUserId:(NSString *)userId{
    if (self = [super initWithPacket:[[MPPacket alloc] initWithCmd:cmd andSessionId:[MPBaseMessage genRequestSessionId]]]) {
        self.userId = userId;
    }
    return self;
}

- (instancetype)initWithCmd:(MPCmd)cmd  andUserId:(NSString *)userId andAlias:(NSString *)alias andTags:(NSString *)tags{
    if (self = [super initWithPacket:[[MPPacket alloc] initWithCmd:MPCmdBind andSessionId:[MPBaseMessage genRequestSessionId]]]) {
        self.userId = userId;
        self.alias = alias;
        self.tags = tags;
    }
    return self;
}

+ (instancetype)bindUser:(NSString *)userId{
    return [[self alloc] initWithCmd:MPCmdBind andUserId:userId];
}

+ (instancetype)bindUser:(NSString *)userId andAlias:(NSString *)alias andTags:(NSString *)tags{
    return [[self alloc] initWithCmd:MPCmdBind andUserId:userId andAlias:alias andTags:tags];
}

+ (instancetype)unbindUser:(NSString *)userId{
    return [[self alloc] initWithCmd:MPCmdUnbind andUserId:userId];
}

+ (instancetype)unbindUser:(NSString *)userId andAlias:(NSString *)alias andTags:(NSString *)tags{
    return [[self alloc] initWithCmd:MPCmdUnbind andUserId:userId andAlias:alias andTags:tags];
}

- (NSData *)encode{
    NSMutableData *body = [NSMutableData data];
    RFIWriter *writer = [[RFIWriter alloc] initWithData:body];
    [writer writeString:self.userId];
    [writer writeString:self.alias];
    [writer writeString:self.tags];
    self.packet.body = writer.data;
    return [super encode];
}

@end

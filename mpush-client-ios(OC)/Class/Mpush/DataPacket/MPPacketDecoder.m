//
//  MPPacketDecoder.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPPacketDecoder.h"
#import "RFIReader.h"


@interface MPPacketDecoder()

@end

@implementation MPPacketDecoder

+ (MPPacket *)decodePacketWithData:(NSData *)data {
    MPPacket *hbPacket = [self decodeHeartbeattWithData:data];
    if (hbPacket) {
        return hbPacket;
    }
    return [self decodeFrameWithData:data];
}

+ (MPPacket *)decodeHeartbeattWithData:(NSData *)data{
    RFIReader *reader = [[RFIReader alloc] initWithData:data];
    if ([reader readByte] == HB_PACKET_BYTE) {
        MPPacket *packet = [[MPPacket alloc] initWithCmd:(MPCmdHeartbeat) andSessionId:0];
        return packet;
    }
    return nil;
}

+ (MPPacket *)decodeFrameWithData:(NSData *)data{
    
    RFIReader *reader = [[RFIReader alloc] initWithData:data];
    int32_t length = reader.readInt32;
    Byte cmd = reader.readByte;
    int16_t cc = reader.readInt16;
    int32_t flags = reader.readByte;
    int32_t sessionId = reader.readInt32;
    Byte lrc = reader.readByte;
    
    NSData *bodyData = [data subdataWithRange:NSMakeRange(13, length)];
    MPPacket *packet = [[MPPacket alloc] initWithLength:length andCmd:cmd andCc:cc andFlags:flags andSessionId:sessionId andlrc:lrc andBody:bodyData];
    return packet;
}
@end

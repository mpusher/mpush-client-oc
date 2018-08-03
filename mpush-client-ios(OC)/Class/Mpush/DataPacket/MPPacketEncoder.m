//
//  MPPacketEncoder.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPPacketEncoder.h"
#import "MPPacket.h"
#import "RFIWriter.h"

@implementation MPPacketEncoder

+ (NSData *)encodePacket:(MPPacket *)packet{
    //协议头
    NSMutableData *packetData = [NSMutableData data];
    RFIWriter *writerPacket = [RFIWriter writerWithData:packetData];
    if (packet.cmd == MPCmdHeartbeat) {
        [writerPacket writeByte: HB_PACKET_BYTE];
    } else {
        int32_t length = (int32_t)packet.body.length;
        [writerPacket writeUInt32: length];
        [writerPacket writeByte: packet.cmd];
        [writerPacket writeInt16: packet.cc];
        [writerPacket writeByte: packet.flags];
        [writerPacket writeUInt32: packet.sessionId];
        [writerPacket writeByte: packet.lrc];
    }
    if (packet.body.length > 0) {
        NSMutableData *data = [NSMutableData dataWithData:writerPacket.data];
        [data appendData:packet.body];
        return data;
    } else{
        return writerPacket.data;
    }
}
@end

//
//  MPDataProcesser.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPDataProcesser.h"
#import "MPPacket.h"
#import "MPPacketDecoder.h"
#import "Mpush.h"
#import "RFIReader.h"
#import "MPMessageDispatcher.h"
#import "MPCipherBox.h"
#import "MPAesCipher.h"
#import "LFCGzipUtility.h"

@interface MPDataProcesser()

// 粘包buffer
@property (nonatomic, strong)NSMutableData *readBuf;
// 半包buffer
@property (nonatomic, strong)NSMutableData *readData;


@property (nonatomic, assign)BOOL complete;

@end

@implementation MPDataProcesser

- (NSMutableData *)readData {
    if (_readData == nil) {
        _readData = [[NSMutableData alloc] init];
    }
    return _readData;
}

- (NSMutableData *)readBuf {
    if (_readBuf == nil) {
        _readBuf = [[NSMutableData alloc] init];
    }
    return _readBuf;
}

+ (MPDataProcesser *)processer {
    static MPDataProcesser *processer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        processer = [[self alloc] init];
        processer.readData = [NSMutableData data];
    });
    return processer;
}

- (void)processData:(NSData *)data{
    if (data.length == 1) {
        MPPacket *packet = [MPPacketDecoder decodePacketWithData:data];
        MPMessageDispatcher *dispatcher = [[MPMessageDispatcher alloc] init];
        [dispatcher onReceivePacket:packet];
        return;
    }
    [self.readBuf appendData:data];
    while (_readBuf.length > HEADER_LEN) {
        NSData *head = [self.readBuf subdataWithRange:NSMakeRange(0, HEADER_LEN)];//取得头部数据
        
        NSData *lengthData = [head subdataWithRange:NSMakeRange(0, 4)];//取得长度数据
        uint32_t length;//得出内容长度
        [lengthData getBytes:&length length: sizeof(uint32_t)];
        NTOHL(length);
        
        NSInteger complateDataLength = length + HEADER_LEN; //算出一个包完整的长度(内容长度＋头长度)
        
        MPPacket *packet;
        if (self.readBuf.length >= complateDataLength) //如果缓存中数据够一个整包的长度
        {
            NSData *packetData = [_readBuf subdataWithRange:NSMakeRange(0, complateDataLength)];//截取一个包的长度(处理粘包)
            packet = [MPPacketDecoder decodePacketWithData:packetData];
            
            _readBuf = [NSMutableData dataWithData:[_readBuf subdataWithRange:NSMakeRange(complateDataLength, _readBuf.length - complateDataLength)]];
            
        }else {
            if (self.readBuf.length == complateDataLength) {
                packet = [MPPacketDecoder decodePacketWithData:self.readBuf];
                self.readBuf = nil;
            }
            break;
        }
        // 消息调度者接收消息
        MPLog(@"packet: %d",packet.cmd);
        MPMessageDispatcher *dispatcher = [[MPMessageDispatcher alloc] init];
        [dispatcher onReceivePacket:packet];
    }
}

@end

//
//  RFIReader.m
//  mpush-client
//
//  Created by OHUN on 16/6/3.
//  Copyright © 2016年 OHUN. All rights reserved.
//

#import "RFIReader.h"

@implementation RFIReader

+ (instancetype)readerWithData:(NSData *)data
{
    return [[RFIReader alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData*)data
{
    self = [super init];
    if (!self || !data)
        return nil;
    
    _data = data;
    _pointer = (char*)data.bytes;
    return self;
}

- (NSData*)readData:(uint32_t)len
{
    if(!len) return nil;
    
    NSData *data = [_data subdataWithRange:NSMakeRange(_poz, len)];
    _poz += len;
    return data;
}

- (const char*)readBytes
{
    NSData *data = [self readData];
    return [data bytes];
}

- (NSData*)readData
{
    int16_t len = [self readInt16];
    return [self readData:len];
}

- (int16_t)readInt16
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(int16_t);
    return NTOHS(*(int16_t*)ptr);
}

- (int32_t)readInt32
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(int32_t);
    return NTOHL(*(int32_t*)ptr);
}

- (int64_t)readInt64
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(int64_t);
    return NTOHLL(*(int64_t*)ptr);
}

- (uint16_t)readUInt16
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(uint16_t);
    return NTOHS(*(uint16_t*)ptr);
}

- (uint32_t)readUInt32
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(uint32_t);
    return NTOHL(*(uint32_t*)ptr);
}

- (uint64_t)readUInt64
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(uint64_t);
    return NTOHLL(*(uint64_t*)ptr);
}

- (char)readByte
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(char);
    return *(char*)ptr;
}

- (BOOL)readBool
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(BOOL);
    return *(BOOL*)ptr;
}

- (float)readFloat
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(float);
    return NTOHLL(*(float*)ptr);
}

- (double)readDouble
{
    char *ptr = _pointer + _poz;
    _poz += sizeof(double);
    return NTOHLL(*(double*)ptr);
}

- (NSString*)readString
{
    NSData *data = [self readData];
    if(data)
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return nil;
}

@end

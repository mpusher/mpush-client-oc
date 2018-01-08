//
//  RFIReader.h
//  mpush-client
//
//  Created by OHUN on 16/6/3.
//  Copyright © 2016年 OHUN. All rights reserved.
//

#ifndef RFIReader_h
#define RFIReader_h

#import <Foundation/Foundation.h>

@interface RFIReader : NSObject
{
    char *_pointer;
}
@property (nonatomic, assign) uint32_t poz;
@property (nonatomic, strong, readonly) NSData *data;

+ (instancetype)readerWithData:(NSData*)data;
- (instancetype)initWithData:(NSData*)data;

- (NSData*)readData:(uint32_t)len;
- (const char*)readBytes;
- (int32_t)readInt32;
- (int64_t)readInt64;
- (int16_t)readInt16;
- (uint32_t)readUInt32;
- (uint64_t)readUInt64;
- (uint16_t)readUInt16;
- (char)readByte;
- (BOOL)readBool;
- (NSString*)readString;
- (NSData*)readData;
- (float)readFloat;
- (double)readDouble;
@end

#endif /* RFIReader_h */

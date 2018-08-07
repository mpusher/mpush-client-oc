//
//  MPCipherBox.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/3.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MPIvData @"MPIvData"
#define MPClientKeyData @"MPClientKeyData"
#define  MPSessionKeyData @"MPSessionKeyData"

@interface MPCipherBox : NSObject

+ (NSData *)mixAesKey:(NSData *)serverKey;

+ (NSData *)generateRandomAesKeyWithLength:(int8_t)aesIvLength;

+ (void)setIvData:(NSData *)ivData;
+ (void)setClientKeyData:(NSData *)keyData;
+ (void)setSessionData:(NSData *)keyData;

+ (int8_t *)getIvBytes;
+ (int8_t *)getClientKeyBytes;
+ (int8_t *)getSessionBytes;

+ (NSData *)getIvData;
+ (NSData *)getClientKeyData;


@end

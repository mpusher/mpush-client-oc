//
//  MPAesCipher.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/3.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPAesCipher : NSObject

/**
 *  aes加密方法
 *
 *  @param enData 需要加密的数据
 *  @param iv     加密指数
 *  @param key    加密key
 *
 *  @return 加密后的data
 */
+ (NSData *) aesEncriptData:(NSData *)enData WithIv:(int8_t [])iv andKey:(int8_t [])key;

+ (NSData *) aesEncriptData:(NSData *)enData;
/**
 *  aes解密方法
 *
 *  @param enData 需要解密的数据
 *  @param iv     加密指数
 *  @param key    加密key
 *
 *  @return 解密后的data
 */
+ (NSData *) aesDecriptWithEncryptData:(NSData *)encryptData withIv:(int8_t [])iv andKey:(int8_t[])key;



@end

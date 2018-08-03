//
//  MPAesCipher.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/3.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPAesCipher.h"
#import <CommonCrypto/CommonCryptor.h>
#import "MPCipherBox.h"

@implementation MPAesCipher

/**
 *  aes加密方法
 *
 *  @param enData 需要加密的数据
 *  @param iv     加密指数
 *  @param key    加密key
 *
 *  @return 加密后的data
 */
+ (NSData *) aesEncriptData:(NSData *)enData WithIv:(int8_t [])iv andKey:(int8_t [])key
{
    NSData *data = enData;
    size_t encryptBufferSize = data.length + kCCBlockSizeAES128;
    void *encryptBuffer = malloc(encryptBufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key, kCCKeySizeAES128,
                                          iv ,/* initialization vector (optional) */
                                          [data bytes],
                                          data.length, /* input */
                                          encryptBuffer,
                                          encryptBufferSize, /* output */
                                          &numBytesEncrypted);
    NSData *encryptData = nil;
    if (cryptStatus == kCCSuccess) {
        encryptData = [NSData dataWithBytes:encryptBuffer length:numBytesEncrypted];
    }
    free(encryptBuffer); //free the buffer;
    return encryptData;
}

+ (NSData *) aesEncriptData:(NSData *)enData{
    return [self aesEncriptData:enData WithIv:[MPCipherBox getIvBytes] andKey:[MPCipherBox getSessionBytes]];
}

/**
 *  aes解密方法
 *
 *  @param enData 需要解密的数据
 *  @param iv     加密指数
 *  @param key    加密key
 *
 *  @return 解密后的data
 */
+ (NSData *) aesDecriptWithEncryptData:(NSData *)encryptData withIv:(int8_t [])iv andKey:(int8_t[])key
{
    size_t decryptBufferSize = encryptData.length + kCCBlockSizeAES128;
    void *decryptBuffer = malloc(decryptBufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key,
                                          kCCKeySizeAES128,
                                          iv ,/* initialization vector (optional) */
                                          [encryptData bytes],
                                          encryptData.length, /* input */
                                          decryptBuffer,
                                          decryptBufferSize, /* output */
                                          &numBytesDecrypted);
    
    NSData *newSrcData = nil;
    if (cryptStatus == kCCSuccess) {
        newSrcData = [NSData dataWithBytes:decryptBuffer length:numBytesDecrypted];
    }
    
    free(decryptBuffer); //free the buffer;
    
    return newSrcData;
}



@end

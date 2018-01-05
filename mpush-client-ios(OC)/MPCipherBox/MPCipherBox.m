//
//  MPCipherBox.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/3.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPCipherBox.h"
#import "Mpush.h"

@implementation MPCipherBox

+(NSData *)mixAesKey:(char *)serverKey {
    static int8_t sessionKey[MPAeslength] ;
    NSData *clientKeyData = [MPUserDefaults objectForKey:MPClientKeyData];
    int8_t *clientKeyBytes = (int8_t *)[clientKeyData bytes];
    for (int i = 0; i < MPAeslength; i++) {
        int8_t a = clientKeyBytes[i];
        int8_t b = serverKey[i];
        int sum = abs(a+b);
        int c = (sum % 2 == 0) ? a^b : b^a ;
        sessionKey[i] = (int8_t)c;
    }
    NSData *sessionKeyData = [NSData dataWithBytes:sessionKey length:MPAeslength];
    return sessionKeyData;
}

+ (NSData *)generateRandomAesKeyWithLength:(int)aesIvLength
{
    char iv[aesIvLength];
    for (int i = 0; i < aesIvLength; i++) {
        iv[i] = arc4random() % aesIvLength;
    }
    NSData *ivData = [[NSData alloc] initWithBytes:iv length:MPAeslength];
    return ivData;
}

+ (void)setIvData:(NSData *)ivData
{
    [MPUserDefaults setObject:ivData forKey:MPIvData];
    [MPUserDefaults synchronize];
}

+ (void)setClientKeyData:(NSData *)keyData
{
    [MPUserDefaults setObject:keyData forKey:MPClientKeyData];
    [MPUserDefaults synchronize];
}

+ (int8_t *)getIvBytes
{
    NSData *ivData = [MPUserDefaults objectForKey:MPIvData];
    int8_t *iv = (int8_t *)[ivData bytes];
    return iv;
}

+ (int8_t *)getClientKeyBytes
{
    NSData *clientKeyData = [MPUserDefaults objectForKey:MPClientKeyData];
    int8_t *clientKeyBytes = (int8_t *)[clientKeyData bytes];
    return clientKeyBytes;
}

+ (void)setSessionData:(NSData *)keyData
{
    [MPUserDefaults setObject:keyData forKey:MPSessionKeyData];
    [MPUserDefaults synchronize];
}

+ (int8_t *)getSessionBytes
{
    NSData *sessionKeyData = [MPUserDefaults objectForKey:MPSessionKeyData];
    int8_t *sessionKey = (int8_t *)sessionKeyData.bytes;
    return sessionKey;
}

@end

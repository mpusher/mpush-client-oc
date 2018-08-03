//
//  MPHttpResponseMessage.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPHttpResponseMessage.h"
#import "NSObject+MPDebugDescription.h"

@implementation MPHttpResponseMessage

- (void)decodeWithBody:(NSData *)body{
    NSMutableData *bodyData = [NSMutableData dataWithData:body];
    RFIReader *reader = [[RFIReader alloc] initWithData: bodyData];
    self.statusCode = [reader readInt32];
    self.reasonPhrase = [reader readString];
    self.headers = [self headersFromString:[reader readString]];
    self.body = [reader readData];
}

- (NSDictionary *)headersFromString:(NSString *)header{
    if (!header) return nil;
    NSArray *headerArr = [header componentsSeparatedByString:@"\n"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    for (NSString *tempHeader in headerArr) {
        NSArray *keyAndValue = [tempHeader componentsSeparatedByString:@":"];
        if (keyAndValue.count == 2) {
            NSString *key = keyAndValue[0];
            NSString *value = keyAndValue[1];
            headers[key] = value;
        }
    }
    return headers;
}

@end

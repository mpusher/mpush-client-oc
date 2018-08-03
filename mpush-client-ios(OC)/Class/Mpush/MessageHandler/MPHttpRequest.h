//
//  MPHttpRequest.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONTENT_TYPE_FORM @"application/x-www-form-urlencoded; charset="
#define HTTP_HEAD_READ_TIMEOUT @"readTimeout"

typedef enum : NSUInteger {
    MPHttpMethodGet=0,
    MPHttpMethodPost,
    MPHttpMethodPut,
    MPHttpMethodDelete
} MPHttpMethod;



@interface MPHttpRequest : NSObject

@property (nonatomic, assign)MPHttpMethod method;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign)NSInteger timeout;
@property (nonatomic, strong)NSMutableDictionary *headers;
@property (nonatomic, strong)NSData *body;

+ (MPHttpRequest *)GET:(NSString *)url andParams:(NSMutableDictionary *)params;
+ (MPHttpRequest *)POST:(NSString *)url andParams:(NSMutableDictionary *)params;

@end

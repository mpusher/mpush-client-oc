//
//  MPHttpResponse.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPHttpResponse : NSObject

@property (nonatomic, assign)NSInteger statusCode;
@property (nonatomic, copy) NSString *reasonPhrase;
@property (nonatomic, strong)NSDictionary *headers;
@property (nonatomic, strong)NSData *body;

@end

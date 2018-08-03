//
//  MPDataProcesser.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/7/27.
//  Copyright © 2018年 Yonglin. All rights reserved.
//  用以处理 粘包、半包

#import <Foundation/Foundation.h>

@interface MPDataProcesser : NSObject

+ (MPDataProcesser *)processer;
- (void)processData:(NSData *)data;

@end

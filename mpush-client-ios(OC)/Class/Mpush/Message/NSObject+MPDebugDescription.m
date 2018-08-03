//
//  NSObject+MPDebugDescription.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "NSObject+MPDebugDescription.h"
#import <objc/runtime.h>

@implementation NSObject (MPDebugDescription)

- (NSString *)debugDescription{
    
    unsigned int count = 0;
    
    objc_property_t *proList = class_copyPropertyList([self class], &count);
    NSMutableArray *mArr = [NSMutableArray array];
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@:{",NSStringFromClass([self class])];
    for (unsigned int i = 0; i < count; i++) {
        
        //从数组中取得属性
        objc_property_t pty = proList[i];
        
        //从中获得属性名称
        const char *cName = property_getName(pty);
        
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        
        id value = [self valueForKeyPath:name];
        [string appendFormat:@"%@: %@; ", name, value];
        [mArr addObject:name];
    }
    [string appendString:@"}"];
    free(proList);
    return string;
    
}

@end

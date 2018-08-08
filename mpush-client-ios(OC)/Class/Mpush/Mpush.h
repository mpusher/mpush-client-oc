//
//  Mpush.h
//  mpush-client-ios(OC)
//
//  Created by Yonglin on 16/8/29.
//  Copyright © 2016年 Yonglin. All rights reserved.
//

#ifndef Mpush_h
#define Mpush_h


#import "MPClient.h"
#import "MPConfig.h"


#define MPUserDefaults  [NSUserDefaults standardUserDefaults]
#ifdef DEBUG  //在调试模式下
#define MPLog(fmt, ...) NSLog((@"[Line-%d] %s >>>>>>" fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#define MPInLog(fmt, ...) NSLog((@"[Line-%d] %s <<<<<<" fmt), __LINE__, __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#else  //Release模式下
#define MPLog(...)
#define MPInLog(...)
#endif


#endif /* Mpush_h */

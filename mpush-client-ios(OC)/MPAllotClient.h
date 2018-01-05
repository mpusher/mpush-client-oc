//
//  MPAllotClient.h
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/3.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessGetHost)(NSString *hostAddress);
typedef void(^FailureGetHost)(NSError *error);

@interface MPAllotClient : NSObject

+ (void)getHostAddressSuccess:(SuccessGetHost)success andFailure:(FailureGetHost)failure;

@end

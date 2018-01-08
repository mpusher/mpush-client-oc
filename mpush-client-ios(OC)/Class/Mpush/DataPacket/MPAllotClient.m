//
//  MPAllotClient.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/3.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPAllotClient.h"
#import "Mpush.h"
#import "AFNetworking.h"

@implementation MPAllotClient

/**
 获取分配的 主机ip 和 端口号 并建立socket连接
 */
+ (void)getHostAddressSuccess:(SuccessGetHost)success andFailure:(FailureGetHost)failure
{
    // 获取分配的 主机ip 和 端口号
    NSString *urlStr = PUSH_HOST_ADDRESS;
    AFHTTPSessionManager *mng = [AFHTTPSessionManager manager];
    mng.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain",@"text/html",nil];
    [mng.requestSerializer setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    mng.requestSerializer= [AFHTTPRequestSerializer serializer];
    mng.responseSerializer= [AFHTTPResponseSerializer serializer];
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [mng.requestSerializer setValue:currentVersion forHTTPHeaderField:@"version"];
    [mng GET:urlStr
  parameters:nil
    progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSString *responseObjectStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         if (responseObjectStr.length < 3) {
             MPLog(@"ip and port are both null");
             return ;
         }
         if (success) success(responseObjectStr);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         MPLog(@"get host and port exception occur");
         if (failure) failure(error);
     }];
    
}

@end

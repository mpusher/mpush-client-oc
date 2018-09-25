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
#import "MPConfig.h"

@implementation MPAllotClient

/**
 获取分配的 主机ip 和 端口号 并建立socket连接
 */
+ (void)getHostAddressSuccess:(SuccessGetHost)success andFailure:(FailureGetHost)failure
{

//    NSURLSession *session = [NSURLSession sharedSession];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: [MPConfig defaultConfig].allotServer]];
//    [request setHTTPMethod:@"get"];
//    [request setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [request setValue:currentVersion forHTTPHeaderField:@"version"];
//
//    NSLog(@"allotServer: %@",[MPConfig defaultConfig].allotServer);
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (data && error==nil) {
//            NSString *responseObjectStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"responseObjectStr: %@", responseObjectStr);
//            if (responseObjectStr.length < 3) {
//                MPLog(@"ip and port are both null");
//                return ;
//            }
//            if (success) success(responseObjectStr);
//        } else {
//            if (failure) {
//                failure(error);
//            }
//        }
//    }];
//    [dataTask resume];

    // 获取分配的 主机ip 和 端口号
    NSString *urlStr = [MPConfig defaultConfig].allotServer;
    AFHTTPSessionManager *request = [AFHTTPSessionManager manager];
    [request.requestSerializer setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.requestSerializer= [AFHTTPRequestSerializer serializer];
    request.responseSerializer= [AFHTTPResponseSerializer serializer];
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [request.requestSerializer setValue:currentVersion forHTTPHeaderField:@"version"];
    [request GET:urlStr
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

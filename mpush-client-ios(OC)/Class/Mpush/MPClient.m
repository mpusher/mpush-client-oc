//
//  MPClient.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/8/1.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPClient.h"
#import "GCDAsyncSocket.h"
#import "MPAllotClient.h"
#import "AFNetworking.h"
#import "MPHandshakeMessage.h"
#import "MPDataProcesser.h"
#import "MPBindUserMessage.h"
#import "MPHttpRequestMessage.h"
#import "MPFastConnectMessage.h"
#import "Mpush.h"
#import "MPAckMessage.h"
#import "GSKeyChainDataManager.h"


/// 超时时间
#define MPTimeOutIntervel 90
/// 写入tag
#define MPWriteDatatag 0

@interface MPClient()<GCDAsyncSocketDelegate>

@property(nonatomic,strong)GCDAsyncSocket *socket;
@property(nonatomic,copy)NSString *host;
@property(nonatomic,assign)uint16_t port;

/// 上次收到消息的时间
@property (nonatomic, assign)double lastReadTime;
/// 上次发送消息的时间
@property (nonatomic, assign)double lastWriteTime;
/// 心跳超时次数
@property (nonatomic, assign)int hbTimeoutTimes;
/// 重连次数
@property (nonatomic, assign)unsigned int connectNum;

@end

@implementation MPClient

+ (instancetype)sharedClient
{
    static MPClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (client == nil) {
            // 创建一个Socket对象 异步线程
            GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            client = [[MPClient alloc] initWithSocket: socket];
        }
    });
    return client;
}

- (instancetype)initWithSocket:(GCDAsyncSocket *)socket
{
    if (self == [super init]) {
        [self saveUUID];
        socket.delegate = self;
        _socket = socket;
    }
    return self;
}

/**
 *  保存UDID
 */
- (void)saveUUID{
    NSString *udid = [GSKeyChainDataManager readUUID];
    if (udid == nil) {
        NSString *deviceUUID = [[UIDevice currentDevice].identifierForVendor UUIDString];
        [GSKeyChainDataManager saveUUID:deviceUUID];
    }
}


/**
 获取分配的 主机ip 和 端口号 并建立socket连接
 */
- (void)connectToHost
{
    MPLog(@"socket start connect");
    // 获取分配的 主机ip 和 端口号
    [MPAllotClient getHostAddressSuccess:^(NSString *hostAddress) {
        [self processAllocHostDataWithhostAddressStr:hostAddress];
    }andFailure:^(NSError *error) {
        NSAssert(false, @"get host and port exception occur");
    }];
}
- (void)processAllocHostDataWithhostAddressStr:(NSString *)hostAddress
{
    NSArray *hostArr = [hostAddress componentsSeparatedByString:@":"];
    NSString *host = hostArr[0];
    uint16_t port = (uint16_t)[hostArr[1] intValue];
    MPConfig *config = [MPConfig defaultConfig];
    config.serverHost = host;
    config.serverPort = port;
    MPLog(@"ip and port:%@---%d",host,port);
    [self networkReachability];
}
/**
 *  网络环境变化判断
 */
- (void)networkReachability
{
    //创建网络监听管理者对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //设置监听
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                MPLog(@"unrecognized network");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                MPLog(@"can not connect");
                [self disconnect];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                MPLog(@"2G,3G,4G... network");
                [self reconnect];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                MPLog(@"wifi  network");
                [self reconnect];
                break;
            default:
                break;
        }
    }];
    //开始监听
    [manager startMonitoring];
}
- (void)reconnect
{
    // 连接
    NSError *error = nil;
    [self disconnect];
    
    MPConfig *config = [MPConfig defaultConfig];
    [_socket connectToHost:config.serverHost onPort:config.serverPort error:&error];
}

#pragma mark -GCDAsyncSocketDelegate
// 连接主机成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    MPLog(@"connect To host");
    if (![self isFastConnect]) { // 不是快速重连 重新连接
        NSData *hd2 = [[[MPHandshakeMessage alloc] init] encode];
        [self sendMessageData: hd2];
        MPInLog(@"mpush send handshake data");
    }else{
        [self sendMessageData: [[[MPFastConnectMessage alloc] init] encode]];
        MPInLog(@"mpush send fastConnect data");
    }
    
    if ([self.delegate respondsToSelector:@selector(client:onConnectedSock:)]) {
        [self.delegate client:self onConnectedSock:sock];
    }
}
- (void)sendMessageData:(NSData *)messageData
{
    [self.socket writeData:messageData withTimeout:MPTimeOutIntervel tag:MPWriteDatatag];
    self.lastWriteTime = [[NSDate date] timeIntervalSince1970];
}

// 与主机断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if ([self.delegate respondsToSelector:@selector(client:onDisConnectedSock:)]) {
        [self.delegate client:self onDisConnectedSock:sock];
    }
    if(err){
        self.connectNum ++;
        if (_connectNum < [MPConfig defaultConfig].maxConnectTimes) {
            sleep(_connectNum+2);
            [self reconnect];
        }
    }
}

// 数据成功发送到服务器
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [_socket readDataWithTimeout:-1 tag:tag];
}

// 读取到数据时调用
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // 处理收到的数据
    @synchronized(self){
        self.lastReadTime = [[NSDate date] timeIntervalSince1970];
        [self processRecieveMessageData:data];
        //持续接收服务端放回的数据
        [sock readDataWithTimeout:-1 tag:tag];
    }
    
}

- (void)processRecieveMessageData:(NSData *)data{
    MPDataProcesser *processer = [MPDataProcesser processer];
    [processer processData: data];
}

/**
 断开连接
 */
- (void)disconnect
{
    if ([self isRunning]) {
        [self.socket disconnect];
    }
}

/**
 绑定用户id
 */
- (void)bindUserWithUserId:(NSString *)userId
{
    if (userId && ![userId isEqualToString:@""]) {
        [self sendMessageData:[[MPBindUserMessage bindUser:userId] encode]];
    }
}

/**
 解除绑定用户id
 */
- (void)unbindUserWithUserId:(NSString *)userId
{
    //绑定用户
    if (userId && ![userId isEqualToString:@""]) {
        [self sendMessageData:[[MPBindUserMessage unbindUser:userId] encode]];
    }
}

- (BOOL)isRunning
{
    return [self.socket isConnected];
}

- (BOOL)isReadTimeout
{
    double last = [[NSDate date] timeIntervalSince1970] - self.lastReadTime;
    double hb = (double)(([MPConfig defaultConfig].minHeartbeat) + 1);
    return last > hb;
}

- (BOOL)isWriteTimeout
{
    double last = [[NSDate date] timeIntervalSince1970] - self.lastWriteTime;
    double hb = (double)(([MPConfig defaultConfig].minHeartbeat) + 1);
    return last > hb;
}

- (BOOL)healthCheck
{
    if ([self isReadTimeout]) {
        self.hbTimeoutTimes+=1;
    }else {
        self.hbTimeoutTimes = 0;
    }
    if (self.hbTimeoutTimes > [MPConfig defaultConfig].maxHBTimeOutTimes) {
        [self reconnect];
        self.hbTimeoutTimes = 0;
        return false;
    }
    if ([self isWriteTimeout]) {
        MPInLog(@"send heartbeat ping...");
        [self sendMessageData: [MPPacketEncoder encodePacket:[[MPPacket alloc] initWithCmd:MPCmdHeartbeat andSessionId:0]]];
    }
    return true;
}

/**
 发送消息
 */
- (void)sendPushMessageWithContent:(NSMutableDictionary *)contentDic
{
    // 通过http代理发送数据
    NSString *urlStr = [NSString stringWithFormat:@"%@/push",[MPConfig defaultConfig].allotServer];
    MPHttpRequest *request = [MPHttpRequest POST:urlStr andParams:contentDic];
    MPHttpRequestMessage *reqMsg = [MPHttpRequestMessage httpRequest:request];
    [self sendMessageData:[reqMsg encode]];
    MPInLog(@"send message data");
}

- (BOOL)isFastConnect
{
    NSDictionary *ssDict = [MPSessionStorage getSessionStorage];
    NSString *hostAddress = ssDict[HOST_ADDRESS_KEY];
    NSString *sessionId = ssDict[MPSessionId];
    // 过期时间
    double expireTime = [ssDict[MPExpireTime] doubleValue];
    // 当前时间
    NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
    
    // 发送握手数据
    if (!sessionId || expireTime < date || ![hostAddress isEqualToString: [MPConfig defaultConfig].allotServer]) {
        [MPSessionStorage clearSession];
        return NO;
    } else{
        return YES;
    }
}

- (void)sendBizAckMessage:(MPPushMessage *)message{
    if ([message bizAck]) {
        MPAckMessage *ackMessage = [[MPAckMessage alloc] initWithSessionId:message.getSessionId];
        [self sendMessageData:[ackMessage encode]];
    }
}


@end

//
//  MessageHandler.m
//  mpush-client-ios(OC)
//
//  Created by WYL on 2018/1/2.
//  Copyright © 2018年 Yonglin. All rights reserved.
//

#import "MPMessageHandler.h"
#import "GCDAsyncSocket.h"
#import "MPAllotClient.h"
#import "AFNetworking.h"
#import <CoreFoundation/CoreFoundation.h>

@interface MPMessageHandler()<GCDAsyncSocketDelegate>
{
    NSString *_userId;
}
@property(nonatomic,strong)GCDAsyncSocket *socket;
/// host
@property(nonatomic,copy)NSString *host;
/// port
@property(nonatomic,assign)uint16_t port;
/// 心跳计时器
@property (nonatomic, strong)NSTimer *timer;
/// 重连次数
@property (nonatomic, assign)unsigned int connectNum;
/// 一条消息读取到到的次数（半包处理）
@property(nonatomic,assign)int recieveNum;
/// 接收到消息的body Data
@property(nonatomic,strong)NSMutableData *messageBodyData;
/// 上次收到消息的时间
@property (nonatomic, assign)double lastReadTime;
/// 上次发送消息的时间
@property (nonatomic, assign)double lastWriteTime;
/// 心跳超时次数
@property (nonatomic, assign)int hbTimeoutTimes;

/// 连接成功回调
@property (nonatomic, weak)SuccessCallBack connectSuccessCallBack;
/// 连接失败回调 因原因众多暂未实现

@property (nonatomic, weak)SuccessCallBack sendSuccessCallBack;
@property (nonatomic, weak)FailureCallBack sendFailureCallBack;

@property (nonatomic, weak)SuccessCallBack disconnectSuccessCallBack;

@property (nonatomic, assign)BOOL isAutoAck;
@property (nonatomic, assign)BOOL isBizAck;

@end

@implementation MPMessageHandler

- (NSMutableData *)messageBodyData{
    
    if (_messageBodyData == nil) {
        _messageBodyData = [[NSMutableData alloc] init];
    }
    return _messageBodyData ;
}

+ (instancetype)shareMessageHandler
{
    static MPMessageHandler *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (handler == nil) {
            // 创建一个Socket对象 异步线程
            GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            handler = [[MPMessageHandler alloc] initWithSocket: socket];
        }
    });
    return handler;
}

- (instancetype)initWithSocket:(GCDAsyncSocket *)socket
{
    if (self == [super init]) {
        socket.delegate = self;
        _socket = socket;
    }
    return self;
}

/**
 获取分配的 主机ip 和 端口号 并建立socket连接
 */
- (void)connectToHostSuccess:(SuccessCallBack)success
{
    self.connectSuccessCallBack = success;
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
    self.host = host;
    self.port = port;
    MPLog(@"ip and port:%@---%d",host,port);
    [self networkReachability];
}

- (void)startConnectSocketWithHostAandPort
{
    // 连接
    NSError *error = nil;
    [_socket connectToHost:self.host onPort:self.port error:&error];
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
                [self.socket disconnect];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                MPLog(@"2G,3G,4G... network");
                [self startConnectSocketWithHostAandPort];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                MPLog(@"wifi  network");
                [self startConnectSocketWithHostAandPort];
                break;
            default:
                break;
        }
    }];
    //开始监听
    [manager startMonitoring];
}

#pragma mark -GCDAsyncSocketDelegate
// 连接主机成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    MPLog(@"connect To host");
    if (![MessageDataPacketTool isFastConnect]) { // 不是快速重连 重新连接
        [self sendMessageDataWithData:[MessageDataPacketTool handshakeMessagePacketData]];
        MPLog(@"mpush send handshake data");
    }else{
        [self sendMessageDataWithData:[MessageDataPacketTool fastConnect]];
        MPLog(@"mpush send fastConnect data");
    }
}

// 与主机断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [self clearHeartBeatTimer];
    self.disconnectSuccessCallBack(err);
    if(err){
        _connectNum ++;
        if (_connectNum < MPMaxConnectTimes) {
            sleep(_connectNum+2);
            NSError *error = nil;
            [_socket connectToHost:self.host onPort:self.port error:&error];
        }
    }
}

// 数据成功发送到服务器
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    MPLog(@"data write success");
    //数据发送成功后，自己调用一下读取数据的方法，接着_socket才会调用下面的代理方法
    [_socket readDataWithTimeout:-1 tag:tag];
}

// 读取到数据时调用
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // 处理收到的数据
    [self processRecieveMessageData:data];
    
    //持续接收服务端放回的数据
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)processRecieveMessageData:(NSData *)data
{
    //心跳
    self.lastReadTime = [[NSDate date] timeIntervalSince1970];
    if (data.length == 1) {
        MPLog(@"receive heartbeat data");
        return ;
    }
    
    // 半包处理
    int length = 0;
    if (_recieveNum < 1) {
        NSData *lengthData = [data subdataWithRange:NSMakeRange(0, 4)];
        [lengthData getBytes: &length length: sizeof(length)];
        NTOHL(length);
    }
    
    if (length > data.length - 13) {
        _recieveNum ++;
        [self.messageBodyData appendData:data];
        length = 0;
        return;
    }
    
    [self.messageBodyData appendData:data];
    
    length = 0;
    _recieveNum = 0;
    
    IP_PACKET packet = [MessageDataPacketTool handShakeSuccessResponesWithData:self.messageBodyData];
    
    self.messageBodyData = nil;
    NSData *body_data = [NSData dataWithBytes:packet.body length:packet.length];
    MPInLog(@"packet cmd:%d",packet.cmd);
    switch (packet.cmd)
    {
        case MpushMessageBodyCMDHandShakeSuccess:
            MPInLog(@"handshake success");
            [self processHandShakeDataWithPacket:packet andData:body_data];
            break;
            
        case MpushMessageBodyCMDFastConnect: //快速重连成功
            [self processFastConnect];
            break;
            
        case MpushMessageBodyCMDError: //错误
        {
            ERROR_MESSAGE errorMessage = [MessageDataPacketTool errorWithBody:body_data];
            if (errorMessage.cmd == MpushMessageBodyCMDError) {
//                if ([self.delegate respondsToSelector:@selector()]) {
                
//                }
            }
        }
            break;
            
        case MpushMessageBodyCMDOk: //ok
        {
            OK_MESSAGE okMessage = [MessageDataPacketTool okWithBody:body_data];
            if (okMessage.cmd == MpushMessageBodyCMDBind) {
                if ([self.delegate respondsToSelector:@selector(messageHandler:didBindUser:)]) {
                    [self.delegate messageHandler:self didBindUser: _userId];
                }
            } else if(okMessage.cmd == MpushMessageBodyCMDUnbind){
                if ([self.delegate respondsToSelector:@selector(messageHandler:didUnbindUser:)]) {
                    [self.delegate messageHandler:self didUnbindUser: _userId];
                }
            }
        }
            
            break;
            
        case MpushMessageBodyCMDHttp: // http代理
        {
            MPInLog(@"call http proxy successed");
            NSData *bodyData = [MessageDataPacketTool processFlagWithPacket:packet andBodyData:body_data];
            HTTP_RESPONES_BODY responesBody = [MessageDataPacketTool chatDataSuccessWithData:bodyData];
            
            if ([self isAutoAckWithBody:packet]) {
                [self sendMessageDataWithData:[MessageDataPacketTool ackMessageWithSessionId:packet.sessionId]];
            }
            
            if (responesBody.statusCode == 200) {
                self.sendSuccessCallBack([NSString stringWithFormat:@"%d",responesBody.statusCode]);
            } else{
                self.sendFailureCallBack([NSString stringWithFormat:@"%d",responesBody.statusCode]);
            }
            break;
        }
        case MpushMessageBodyCMDPush:  //收到的push消息
            [self processRecievePushMessageWithPacket:packet andData:body_data];
            break;
            
        case MpushMessageBodyCMDChat: //聊天
            MPInLog(@"CMDChat");
            break;
        case MpushMessageBodyCMDKick: // 被踢下线
            [self processKickUserWithBodyData:body_data];
            break;
        default:
            break;
    }
}

- (void)processKickUserWithBodyData:(NSData *)bodyData
{
    KICK_USER_MESSAGE kickUserMessage = [MessageDataPacketTool kickUserWithBody:bodyData];
    if ([self.delegate respondsToSelector:@selector(messageHandler:didKickUserWithUserId:andDeviceId:)]) {
        [self.delegate messageHandler:self didKickUserWithUserId:[NSString stringWithUTF8String:kickUserMessage.userId] andDeviceId:[NSString stringWithUTF8String:kickUserMessage.deviceId]];
    }
    MPInLog(@"kick userId: %s",kickUserMessage.userId);
}
/**
 增加心跳定时器

 @param time 心跳时间间隔
 */
- (void)addHeartBeatTimer:(NSTimeInterval)time
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _timer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(sendHeartbeat) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    });
}

/**
 清除心跳定时器
 */
- (void)clearHeartBeatTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_timer invalidate];
        _timer = nil;
    });
}
/**
 *  心跳
 */
- (void)sendHeartbeat
{
    MPLog(@"heartbeat data send");
    [self healthCheck];
}

/**
 *  处理握手ok响应的数据
 *
 *  @param bodyData 握手ok的bodyData
 */
- (void)processHandShakeDataWithPacket:(IP_PACKET)packet andData:(NSData *)body_data
{
    [MessageDataPacketTool handSuccessBodyDataWithData:body_data andPacket:packet];
    [self addHeartBeatTimer: MPMinHeartbeat];
    self.connectSuccessCallBack(@"connect success");
}

/**
 处理快速重连
 */
- (void)processFastConnect
{
    MPInLog(@"fastConnect success");
    self.connectSuccessCallBack(@"connect success");
    [self addHeartBeatTimer: MPMinHeartbeat];
}

/**
 *  处理收到的消息
 *
 *  @param packet    协议包
 *  @param body_data 协议包body data
 */
- (void)processRecievePushMessageWithPacket:(IP_PACKET)packet andData:(NSData *)body_data
{
    id content = [MessageDataPacketTool processRecievePushMessageWithPacket:packet andData:body_data];
    NSString *contentJsonStr = content[@"content"];
    NSDictionary *contentDict = [self dictionaryWithJsonString:contentJsonStr];
    if (contentDict == nil) {
        MPInLog(@"json parse data is nil");
        return;
    }
    NSString *contentStr = contentDict[@"content"];
    if ([self.delegate respondsToSelector:@selector(messageHandler:didRecieveMessage:)]) {
        [self.delegate messageHandler:self didRecieveMessage:contentStr];
    }
    MPInLog(@"recieve push message: %@", contentStr);
}

/*
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

/**
 绑定用户id
 */
- (void)bindUserWithUserId:(NSString *)userId
{
    if (userId && ![userId isEqualToString:@""]) {
        //绑定用户
        _userId = userId;
        [self sendMessageDataWithData:[MessageDataPacketTool bindDataWithUserId:userId andIsUnbindFlag:NO]];
    }
}

/**
 解除绑定用户id
 */
- (void)unbindUserWithUserId:(NSString *)userId
{
    //绑定用户
    if (userId && ![userId isEqualToString:@""]) {
        //解绑用户
        [self sendMessageDataWithData:[MessageDataPacketTool bindDataWithUserId:userId andIsUnbindFlag:YES]];
    }
}

/**
 发送消息
 */
- (void)sendPushMessageWithContent:(NSDictionary *)contentDic andSuccess:(SuccessCallBack)success andFailure:(FailureCallBack)failure
{
    self.sendSuccessCallBack = success;
    self.sendFailureCallBack = failure;

    // 通过http代理发送数据
    // PUSH_HOST_ADDRESS
    NSString *urlStr = [NSString stringWithFormat:@"%@/push",PUSH_HOST_ADDRESS];
    
    [self sendMessageDataWithData:[MessageDataPacketTool chatDataWithBody:contentDic andUrlStr:urlStr]];
    MPLog(@"send message data");
}

- (void)sendMessageDataWithData:(NSData *)messageData
{
    self.lastWriteTime = [[NSDate date] timeIntervalSince1970];
    [self.socket writeData:messageData withTimeout:MPTimeOutIntervel tag:MPWriteDatatag];
}

/**
 断开连接
 */
- (void)disconnectSuccess:(SuccessCallBack)success
{
    self.disconnectSuccessCallBack = success;
    [self.socket disconnect];
}

/**
 是否已连接
 */
- (BOOL)isRunning
{
    return [self.socket isConnected];
}

- (BOOL)isReadTimeout
{
    double last = [[NSDate date] timeIntervalSince1970] - self.lastReadTime;
    double hb = (double)((MPMinHeartbeat) + 1);
    return last > hb;
}

- (BOOL)isWriteTimeout
{
    double last = [[NSDate date] timeIntervalSince1970] - self.lastWriteTime;
    double hb = (double)((MPMinHeartbeat) + 1);
    return last > hb;
}

- (BOOL)healthCheck
{
    if ([self isReadTimeout]) {
        self.hbTimeoutTimes+=1;
        MPLog(@"heartbeat timeout times is: %d", self.hbTimeoutTimes);
    }else{
        self.hbTimeoutTimes = 0; 
    }
    
    if (self.hbTimeoutTimes >= MPMaxHBTimeOutTimes) {
        __weak __typeof(self) weakSelf  = self;
        [self connectToHostSuccess:^(id successContent) {
            __strong __typeof(self) strongSelf = weakSelf;
            strongSelf.hbTimeoutTimes = 0;
        }];
        return false;
    }
    if ([self isWriteTimeout]) {
        [self sendMessageDataWithData:[MessageDataPacketTool heartbeatPacketData]];
    }
    return true;
}

/**
 是否自动ack
 */
- (BOOL)isAutoAckWithBody:(IP_PACKET)ipPacket
{
    if (((ipPacket.flags&8) != 0)) {
        return true;
    }
    return false;
}
/**
 是否ack
 */
- (BOOL)isBizAckWithBody:(IP_PACKET)ipPacket
{
    if (((ipPacket.flags&4) != 0)) {
        return true;
    }
    return false;
}

@end








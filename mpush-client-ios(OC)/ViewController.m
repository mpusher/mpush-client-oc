//
//  ViewController.m
//  mpush-client-ios(OC)
//
//  Created by Yonglin on 16/8/29.
//  Copyright © 2016年 Yonglin. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import "AFNetworking.h"
#import "RSA.h"
#import "RFIWriter.h"
#import "MessageDataPacketTool.h"
#import <CommonCrypto/CommonCryptor.h>
#import "LFCGzipUtility.h"

#define AllocHost @"http://103.246.161.44:9999"



@interface ViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

/** 盛放消息内容的数组  */
@property(nonatomic,strong)NSMutableArray *messages;


@property(nonatomic,strong)GCDAsyncSocket *socket;
/**  发送心跳的计时器 */
@property(nonatomic,strong)NSTimer *timer;
/**  一条消息接收到的次数（半包处理） */
@property(nonatomic,assign)int recieveNum;
/**  接收到消息的body Data */
@property(nonatomic,strong)NSMutableData *messageBodyData;
/** 绑定的用户id  */
@property(nonatomic,copy)NSString *userId;
/** 连接次数  */
@property(nonatomic,assign)int connectNum;
/** host  */
@property(nonatomic,copy)NSString *host;
/** port  */
@property(nonatomic,assign)int port;

@property (weak, nonatomic) IBOutlet UITextField *allocerTextField;
@property (weak, nonatomic) IBOutlet UITextField *userFromTextField;
@property (weak, nonatomic) IBOutlet UITextField *userToTextField;
@property (weak, nonatomic) IBOutlet UITextField *pushContentTextField;
@property (weak, nonatomic) IBOutlet UIButton *bindButton;
@property (weak, nonatomic) IBOutlet UIButton *unBindButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;


@end

@implementation ViewController

- (NSMutableArray *)messages{
    if (_messages == nil) {
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages ;
}


- (IBAction)connectBtnClick:(id)sender {
    NSLog(@"connectBtnClick");
    // 1.建立连接
    [self networkReachability];
    
}
// 断开连接
- (IBAction)didConnectBtnClick:(id)sender {
    [self.socket disconnect];
}



- (void)connectToHost{
    // 获取分配的 主机ip 和 端口号
    NSString *urlStr = self.allocerTextField.text;
    AFHTTPSessionManager *mng = [AFHTTPSessionManager manager];
    mng.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain",@"text/html",nil];
    [mng.requestSerializer setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    mng.requestSerializer= [AFHTTPRequestSerializer serializer];
    mng.responseSerializer= [AFHTTPResponseSerializer serializer];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    [mng.requestSerializer setValue:currentVersion forHTTPHeaderField:@"version"];
    [mng GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject-----%@",responseObject);
        NSString *responseObjectStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"--%@",responseObjectStr);
        if (responseObjectStr.length < 3) {
            return ;
        }
        NSArray *hostArr = [responseObjectStr componentsSeparatedByString:@":"];
        NSString *host = hostArr[0];
        self.host = host;
        int port = [hostArr[1] intValue];
        self.port = port;
        NSLog(@"%@---%d",host,port);
        
        // 创建一个Socket对象
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        // 连接
        NSError *error = nil;
        [_socket connectToHost:host onPort:port error:&error];
        
        [self.messages addObject:@"socketConnectToHost"];
        [self messageTableViewReloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error-----%@",error);
    }];

}


/**
 *  网络环境变化判断
 */
- (void)networkReachability{
    //创建网络监听管理者对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,//未识别的网络
     AFNetworkReachabilityStatusNotReachable     = 0,//不可达的网络(未连接)
     AFNetworkReachabilityStatusReachableViaWWAN = 1,//2G,3G,4G...
     AFNetworkReachabilityStatusReachableViaWiFi = 2,//wifi网络
     };
     */
    //设置监听
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                self.navigationItem.title = @"未识别的网络";
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                self.navigationItem.title = @"网络不可用";
                [self.socket disconnect];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"2G,3G,4G...的网络");
                [self connectToHost];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi的网络");
                [self connectToHost];
                break;
            default:
                break;
        }
    }];
    //开始监听
    [manager startMonitoring];
}

/** 绑定用户 */
- (IBAction)bindBtnClick:(id)sender {
    NSLog(@"bindBtnClick");
    
    [self.messages addObject:@"绑定用户..."];
    [self messageTableViewReloadData];
    //绑定用户
    self.userId = [NSString stringWithFormat:@"%@",self.userFromTextField.text];
    [self.socket writeData:[MessageDataPacketTool bindDataWithUserId:self.userId andIsUnbindFlag:NO] withTimeout:-1 tag:222];
}

- (IBAction)unbindBtnClick:(id)sender {
    if (self.userId) {
        [self.messages addObject:@"解绑用户"];
        [self messageTableViewReloadData];
        //解绑用户
        [self.socket writeData:[MessageDataPacketTool bindDataWithUserId:self.userId andIsUnbindFlag:YES] withTimeout:-1 tag:222];
        self.userId = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.messageTableView.dataSource = self;
    self.messageTableView.delegate = self;
    self.messageTextField.delegate = self;
}

#pragma mark -UITextFieldDelegate
// 发送消息
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendPushMessage];
    return YES;
}
// 发送消息
- (void) sendPushMessage{
    
    // 通过http代理发送数据
    NSMutableData *dataaa = [NSMutableData data];
    NSMutableDictionary *contentDict = [NSMutableDictionary dictionary];
    contentDict[@"userId"] = self.userToTextField.text;
    contentDict[@"hello"] = self.messageTextField.text;
    NSData *contentJsonData = [NSJSONSerialization dataWithJSONObject:contentDict options:NSJSONWritingPrettyPrinted error:nil];
    NSData *strData = contentJsonData;
    
    short strDataLength = (short)strData.length;
    HTONS(strDataLength);
    NSData *strDataLengthData = [NSData dataWithBytes:&strDataLength length:sizeof(strDataLength)];
    [dataaa appendData:strDataLengthData];
    [dataaa appendData:strData];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@",PUSH_HOST_ADDRESS];
    
    [self.socket writeData:[MessageDataPacketTool chatDataWithBody:dataaa andUrlStr:urlStr] withTimeout:-1 tag:222];
    
    [self.messages addObject:[NSString stringWithFormat:@"发送数据%@",self.messageTextField.text]];
    self.messageTextField.text = nil;
    [self messageTableViewReloadData];
    
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.messages[indexPath.row];
    return cell;
}

#pragma mark -GCDAsyncSocketDelegate
// 连接主机成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接主机成功");
    self.title = @"连接成功";
    [self.messages addObject:@"socketDidConnectToHost"];
    [self messageTableViewReloadData];
    if (![MessageDataPacketTool isFastConnect]) {
        [self.messages addObject:@"发送握手数据"];
        [self messageTableViewReloadData];
        [sock writeData:[MessageDataPacketTool handshakeMessagePacketData] withTimeout:-1 tag:222];
        return;
    }
    
    [self.messages addObject:@"发送快速重连数据"];
    [self messageTableViewReloadData];
    [sock writeData:[MessageDataPacketTool fastConnect] withTimeout:-1 tag:222];
    
}
- (void) messageTableViewReloadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageTableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
        [self.messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

// 与主机断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    if(err){
        NSLog(@"断开连接 %@",err);
        self.title = @"连接错误";
        _connectNum ++;
        if (_connectNum < MPMaxConnectTimes) {
            sleep(_connectNum+2);
            NSError *error = nil;
            [_socket connectToHost:self.host onPort:self.port error:&error];
        }
    } else{
        self.title = @"断开连接";
    }
    [self.messages addObject:@"socketDidDisconnect"];
    [self messageTableViewReloadData];
}

// 数据成功发送到服务器
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"数据成功发送到服务器");
    //数据发送成功后，自己调用一下读取数据的方法，接着_socket才会调用下面的代理方法
    [_socket readDataWithTimeout:-1 tag:tag];
}

// 读取到数据时调用
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    //心跳
    if (data.length == 1) {
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
        _recieveNum ++ ;
        [self.messageBodyData appendData:data];
        length = 0;
        return;
    }
    
    [self.messageBodyData appendData:data];
    
    length = 0;
    _recieveNum = 0;
    
    IP_PACKET packet ;
    if (self.messageBodyData == nil) {
        //读取到的数据
        packet = [MessageDataPacketTool handShakeSuccessResponesWithData:data];
    } else {
        packet = [MessageDataPacketTool handShakeSuccessResponesWithData:self.messageBodyData];
    }
    self.messageBodyData = nil;
    
    //解密以前的body
    NSData *body_data = [NSData dataWithBytes:packet.body length:packet.length];
    NSLog(@"bodyData--%@--%d",body_data,packet.length);
    switch (packet.cmd) {
            
        case MpushMessageBodyCMDHandShakeSuccess:
            NSLog(@"握手成功");
            
            [self.messages addObject:@"握手成功"];
            [self messageTableViewReloadData];
            [self processHandShakeDataWithPacket:packet andData:body_data];
            break;
            
        case MpushMessageBodyCMDLogin: //登录
            
            break;
            
        case MpushMessageBodyCMDLogout: //退出
            
            break;
        case MpushMessageBodyCMDBind: //绑定
            
            break;
        case MpushMessageBodyCMDUnbind: //解绑
            
            break;
        case MpushMessageBodyCMDFastConnect: //快速重连
        
            NSLog(@"MpushMessageBodyCMDUNFastConnect");
            [self.messages addObject:@"快速重连成功"];
            [self messageTableViewReloadData];
            break;
        
        case MpushMessageBodyCMDStop: //暂停
            
            break;
        case MpushMessageBodyCMDResume: //重新开始
            
            break;
        case MpushMessageBodyCMDError: //错误
            [MessageDataPacketTool errorWithBody:body_data];
            break;
        case MpushMessageBodyCMDOk: //ok
            //                        [MessageDataPacketTool okWithBody:body_data];
            [self.messages addObject:@"操作成功!"];
            [self messageTableViewReloadData];
            break;
            
        case MpushMessageBodyCMDHttp: // http代理
        {
            NSLog(@"ok======聊天=========");
            [self.messages addObject:@"成功调用http代理"];
            [self messageTableViewReloadData];
            NSData *bodyData = [MessageDataPacketTool processFlagWithPacket:packet andBodyData:body_data];
            HTTP_RESPONES_BODY responesBody = [MessageDataPacketTool chatDataSuccessWithData:bodyData];
            NSLog(@"--%d",responesBody.statusCode);
        }
            break;
        case MpushMessageBodyCMDPush:  //收到的push消息
            [self processRecievePushMessageWithPacket:packet andData:body_data];
            
            break;
            
        case MpushMessageBodyCMDChat: //聊天
            break;
            
        default:
            break;
    }
    
    [sock readDataWithTimeout:-1 tag:tag];//持续接收服务端放回的数据
}
/**
 *  心跳
 */
- (void)heartbeatSend{
    
    [_socket writeData:[MessageDataPacketTool heartbeatPacketData] withTimeout:-1 tag:123];
}

/**
 *  处理收到的消息
 *
 *  @param packet    协议包
 *  @param body_data 协议包body data
 */
- (void)processRecievePushMessageWithPacket:(IP_PACKET)packet andData:(NSData *)body_data{
    id content = [MessageDataPacketTool processRecievePushMessageWithPacket:packet andData:body_data];
    NSString *contentJsonStr = content[@"content"];
    NSDictionary *contentDict = [self dictionaryWithJsonString:contentJsonStr];
    NSString *contentStr = contentDict[@"content"];
    
    [self.messages addObject:[NSString stringWithFormat:@"收到push消息--%@",contentStr]];
    [self messageTableViewReloadData];
    NSLog(@"content--%@",contentDict);
}
/*!
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
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/**
 *  处理心跳响应的数据
 *
 *  @param bodyData 握手ok的bodyData
 */
- (void) processHeartDataWithData:(NSData *)bodyData{
    NSLog(@"接收到心跳");
}

/**
 *  处理握手ok响应的数据
 *
 *  @param bodyData 握手ok的bodyData
 */
- (void) processHandShakeDataWithPacket:(IP_PACKET)packet andData:(NSData *)body_data{
    
    HAND_SUCCESS_BODY handSuccessBody = [MessageDataPacketTool HandSuccessBodyDataWithData:body_data andPacket:packet];
    
    //添加计时器
    _timer = [NSTimer timerWithTimeInterval:handSuccessBody.heartbeat/1000.0 target:self selector:@selector(heartbeatSend) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
}
// 发送消息按钮点击
- (IBAction)senfBtnClick:(id)sender {
    [self sendPushMessage];
}




@end










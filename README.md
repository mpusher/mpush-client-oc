### 一、此demo依赖AFNetworking、CocoaAsyncSocket、LFCGzipUtility 和rfi_reader四个三方框架

- 1、afn 用于使用http代理向服务端发送数据 和 监测网络变化
- 2、CocoaAsyncSocket 用于建立socket连接
- 3、LFCGzipUtility 用于压缩和解压缩数据
- 4、rfi_reader 用于拼接数据


### 二、核心文件：MessageDataPacketTool 
`MessageDataPacketTool`为该demo的核心文件  <br><br>此文件封装了 `握手` `握手响应` `心跳` `绑定` `绑定ok` `快速重连` `AES加解密`  `http代理` `http代理响应` `ok` `error`  等数据包
需要使用以上功能 只需调用MessageDataPacketTool 中的对应方法  方法返回值即为需要向服务端发送的数据
### 三、相应操作对应的方法
    握手:   + (NSData *)handshakeMessagePacketData;
    握手响应包:  + (IP_PACKET)handShakeSuccessResponesWithData:(NSData *)data;
    握手响应包中的body:  + (HAND_SUCCESS_BODY) HandSuccessBodyDataWithData:(NSData *)body_data andPacket:(IP_PACKET)packet;
    心跳: +(NSData *)heartbeatPacketData;
    绑定: + (NSData *)bindDataWithUserId:(NSString *)userId;
    绑定ok:   + (OK_MESSAGE) okWithBody:(NSData *)body;
    快速重连:   + (NSData *)fastConnect;
    AES加密:  + (NSData *) aesEncriptData:(NSData *)enData WithIv:(int8_t [])iv andKey:(int8_t [])key;
    AES解密:   + (NSData *) aesDecriptWithEncryptData:(NSData *)encryptData withIv:(int8_t [])iv andKey:(int8_t[])key;
    http代理:   + (NSData *)chatDataWithBody:(NSData *)messageBody andUrlStr:(NSString *)urlStr;
    http代理响应: + (HTTP_RESPONES_BODY)chatDataSuccessWithData:(NSData *)bodyData;
    处理收到的push消息:  + (id)processRecievePushMessageWithPacket:(IP_PACKET)packet andData:(NSData *)body_data;新的
### 四、使用方法：
    1、建立连接 
    2、绑定用户
    3、收发消息
## 使用注意：
1、需要更换与服务对应的 IP地址  和 MessageDataPacketTool.h文件中的pubkey(握手时RSA加密所需的公钥)
2、iOS10以上需要打开keychain Sharing的开关 -->`在xcode的Ttarget中选中Capabilities找到keychain Sharing选项 打开开关即可`


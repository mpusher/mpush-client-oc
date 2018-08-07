### Mpush开源推送框架（OC客户端）

#### 系统结构图：

![Mpush结构图](https://github.com/mpusher/mpush-client-oc/blob/master/Mpush.png)

#### 说明
结构图分为Server、Client和Actor三部分，SDK则为Client的实现, 以下按照接收数据（1-7）和发送数据（a-d）的流程介绍。

接收数据:

1. Client通过GCDAsycSocket建立并管理连接。

2. 接收到的数据,经由MPDataProcesser处理有可能发生的粘包、半包情况，获得完整的包数据。

3. 使用MPPacketDecoder将获得的data解码为MPPacket类。

4. 消息调度者MPMessageDispatcher则根据MPPacket中的cmd调用相应的已注册的MessageHandler。

5. MessageHandler操作对应消息的行为。

6. 将消息解码为MPMessage类。

7. MPClient监听接收的消息。

发送数据:

a. Client通过GCDAsycSocket建立并管理连接。

b. MPClient的数据操作: 连接、断开、绑定用户、解绑用户、发送数据、通过HttpProxy发送push数据。

c. 将要发送的Message打包为MPPacket并转为data。

d. 通过socket发送数据。

#### 使用注意
1. MPConfig为配置文件。
2. iOS10以上需要打开keychain Sharing的开关 -->在xcode的Target中选中Capabilities找到keychain Sharing选项 打开开关即可。
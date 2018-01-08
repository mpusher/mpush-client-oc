### 一、核心文件：MPMessageHandler
`MPMessageHandler`为该sdk的核心类，</br>该类提供了`连接` `断开连接` `绑定用户`  `解除绑定`  `发送消息` 等api </br>和`绑定用户成功` `解除绑定用户成功` `接收消息`  `踢用户下线` 等代理方法</br>

### 二、demo使用方法：
    1、建立连接 </br>
    2、绑定用户 </br>
    3、收发消息 </br>
    
## 使用注意：
    1、在Mpush.h文件修改相应配置</br>
    2、需要更换与服务对应的 IP地址  和 MessageDataPacketTool.h文件中的pubkey(握手时RSA加密所需的公钥)</br>
    3、iOS10以上需要打开keychain Sharing的开关 -->`在xcode的Target中选中Capabilities找到keychain Sharing选项 打开开关即可`


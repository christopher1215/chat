//
//  XXMPPTool.m
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//  XMPP与服务器交互的工具类

#import "XXMPPTool.h"

/*
 用户登录流程
 
 1.初始化XMPPStream
 2.连接服务器，传递一个JID
 3.连接成功，接着就发送密码
 4.默认登录成功不“在线”，需要发送一个“在线”消息给服务器，可以通知其他用户你“在线”
 */

@interface XXMPPTool ()<XMPPStreamDelegate>
{
    
    XMPPResultBlock _resultBlock;  //结果回调Block
    
    //自动连接模块，由于网络问题与服务器断开连接时，会自动雨服务器连接
    XMPPReconnect *_reconnect;
    
}

//初始化XMPPStream
-(void)setupStream;
//释放资源
-(void)teardownStream;
//连接服务器
-(void)connectToHost;
//发送密码
-(void)sendPwdToHost;
//发送一个“在线”消息给服务器
-(void)sendOnLine;
//发送一个“离线”消息给服务器
-(void)sendOffLine;
//与服务器断开连接
-(void)disconnectFromHost;

@end

@implementation XXMPPTool

singleton_implementation(XXMPPTool)

#pragma mark - 私有方法
-(void)setupStream
{
    //创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc]init];
    
    //添加“电子名片”模块
    //1.添加“电子名片”模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc]initWithvCardStorage:_vCardStorage];
    //2.激活“电子名片”模块
    [_vCard activate:_xmppStream];
    
    //“电子名片”模块还会配合“头像模块”一起使用
    //添加“电子名片头像”模块
    _avatar = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_vCard];
    [_avatar activate:_xmppStream];
    
    //“花名册”模块
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    //“消息”模块
    _msgArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc]init];
    _msgArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:_msgArchivingStorage];
    [_msgArchiving activate:_xmppStream];
    
    //“自动连接”模块
    _reconnect = [[XMPPReconnect alloc]init];
    [_reconnect activate:_xmppStream];
    
    //设置代理,所有代理都在子线程调用
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)teardownStream
{
    //移除代理
    [_xmppStream removeDelegate:self];
    
    //取消模块
    [_avatar deactivate];
    [_vCard deactivate];
    [_roster deactivate];
    [_msgArchiving deactivate];
    [_reconnect deactivate];
    
    //断开连接
    [_xmppStream disconnect];
    
    //清空资源
    _vCardStorage = nil;
    _vCard = nil;
    _avatar = nil;
    _roster = nil;
    _rosterStorage = nil;
    _msgArchiving = nil;
    _msgArchivingStorage = nil;
    _reconnect = nil;
    _xmppStream = nil;
}

-(void)connectToHost
{
    if (!_xmppStream) {
        [self setupStream];
    }
    //1.设置登录用户jid
    //resource 用户登录客户端设备登录类型
    XMPPJID *myJid = nil;
    
    XAccount *account = [XAccount shareAccount];
    
    //如果是注册，就设置注册的JID
    if (self.isRegisterOperation) {
        //注册
        NSString *registerUsr = [XAccount shareAccount].registerUser;
        myJid = [XMPPJID jidWithUser:registerUsr domain:account.domain resource:@"iPhone"];
    }else{
        //登录
        NSString *loginUsr = [XAccount shareAccount].loginUser;
        myJid = [XMPPJID jidWithUser:loginUsr domain:account.domain resource:@"iPhone"];
    }
    
    _xmppStream.myJID = myJid;
    
    //2.设置主机地址
    _xmppStream.hostName = account.host;
    
    //3.设置port(默认就是：5222，可以不用设置)
    _xmppStream.hostPort = account.port;
    
    //4.发起连接
    NSError *err = nil;
    //缺少必要参数就会发起连接失败，例如，没有jid
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err];
    if (err) {
        XLog(@"%@",err);
    }else{
        XLog(@"发起连接成功");
    }
    
}

-(void)sendPwdToHost
{
    //发送密码
    NSString *pwd = [XAccount shareAccount].loginPwd;
    NSError *err = nil;
    [_xmppStream authenticateWithPassword:pwd error:&err];
    if (err) {
        XLog(@"%@",err);
    }else{
        XLog(@"发送密码成功");
    }
    
}

-(void)sendOnLine
{
    //XMPP框架，将所有指令封装成对象
    XMPPPresence *presence = [XMPPPresence presence];
    XLog(@"%@", presence);
    [_xmppStream sendElement:presence];
}

-(void)sendOffLine
{
    //XMPP框架，将所有指令封装成对象
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    XLog(@"%@", offline);
    [_xmppStream sendElement:offline];
}

-(void)disconnectFromHost
{
    [_xmppStream disconnect];
}

#pragma mark - XMPPStream Delegate
#pragma mark 连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    XLog(@"连接成功");
    if (self.isRegisterOperation) {
        //注册
        NSString *registerPwd = [XAccount shareAccount].registerPwd;
        NSError *err = nil;
        [_xmppStream registerWithPassword:registerPwd error:&err];
        if (err) {
            XLog(@"err:%@",err);
        }
    }else{
        //登录
        [self sendPwdToHost];
    }
}

#pragma mark 断开连接
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    XLog(@"断开连接");
}

#pragma mark 登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //XLog(@"%s",__func__);
    XLog(@"登录成功");
    [self sendOnLine];
    
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
        
        _resultBlock = nil;
    }
}

#pragma mark 登录失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    XLog(@"登录失败 %@", error);
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
        
        _resultBlock = nil;
        
    }
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    XLog(@"注册成功");
    
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSuccess);
        
        _resultBlock = nil;
    }
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    XLog(@"注册失败 %@", error);
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
        
        _resultBlock = nil;
    }

}

#pragma mark - 公共方法
#pragma mark 用户登录
-(void)xmppLogin:(XMPPResultBlock)resultBlock
{
    //不管什么情况，把以前的连接断开
    [_xmppStream disconnect];
    
    //保存resultBlock
    _resultBlock = resultBlock;
    
    //连接服务器,开始登录的操作
    [self connectToHost];
    
}

#pragma mark 用户注册
-(void)xmppRegister:(XMPPResultBlock)resultBlock
{
    //注册的步骤：
    //1.发送注册的JID给服务器，请求一个长连接
    //2.连接成功，发送注册的密码
    
    //保存block
    _resultBlock = resultBlock;
    
    //不管什么情况，把以前的连接断开
    [_xmppStream disconnect];
    
    [self connectToHost];
    
    
}

#pragma mark 用户注销
-(void)xmppLogout
{
    //1.发送“离线”消息给服务器
    [self sendOffLine];
    //2.断开连接
    [self disconnectFromHost];
    
    
}

-(void)dealloc
{
    [self teardownStream];
}


@end

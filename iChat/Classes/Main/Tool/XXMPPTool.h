//
//  XXMPPTool.h
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//  XMPP与服务器交互的工具类

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"

typedef enum
{
    XMPPResultTypeLoginSuccess,  //登录成功
    XMPPResultTypeLoginFailure,   //登录失败
    XMPPResultTypeRegisterSuccess,  //注册成功
    XMPPResultTypeRegisterFailure  //注册失败
}XMPPResultType;

//与服务器交互的结果
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface XXMPPTool : NSObject

singleton_interface(XXMPPTool)

//“电子名片”模块
@property (strong, nonatomic, readonly)XMPPvCardTempModule *vCard;

//“电子名片”数据存储
@property (strong, nonatomic, readonly)XMPPvCardCoreDataStorage *vCardStorage;
//“花名册”模块
@property (strong, nonatomic, readonly)XMPPRoster *roster;
//“花名册”模块数据存储
@property (strong, nonatomic, readonly)XMPPRosterCoreDataStorage *rosterStorage;
//“电子名片头像”模块
@property (strong, nonatomic, readonly)XMPPvCardAvatarModule *avatar;
//与服务器交互的核心类
@property (strong, nonatomic, readonly)XMPPStream *xmppStream;
//“消息模块”
@property (strong, nonatomic, readonly)XMPPMessageArchiving *msgArchiving;
//“消息模块”数据存储
@property (strong, nonatomic, readonly)XMPPMessageArchivingCoreDataStorage *msgArchivingStorage;

//标示连接服务器时，到底是“登录”连接还是“注册”连接
//NO:Login; YES:Register
@property (assign, nonatomic, getter=isRegisterOperation)BOOL registerOperation;

//XMPP Login
-(void)xmppLogin:(XMPPResultBlock)resultBlock;
//XMPP Logout
-(void)xmppLogout;

//XMPP Register
-(void)xmppRegister:(XMPPResultBlock)resultBlock;

@end

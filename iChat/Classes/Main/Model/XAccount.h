//
//  XAccount.h
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XAccount : NSObject

//登录的用户名和密码
@property (copy, nonatomic)NSString *loginUser;
@property (copy, nonatomic)NSString *loginPwd;

//判断用户是否登录
@property (assign, nonatomic,getter=isLogin)BOOL login;

//注册的用户名和密码
@property (copy, nonatomic)NSString *registerUser;
@property (copy, nonatomic)NSString *registerPwd;

+(instancetype)shareAccount;

//保存最新的数据到沙盒里
-(void)saveToSandBox;

//服务器的域名
@property(copy, nonatomic, readonly)NSString *domain;
//服务器的IP
@property(copy, nonatomic, readonly)NSString *host;
//服务器的Port
@property(assign, nonatomic, readonly)int port;

@end

//
//  XAccount.m
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//
// 实现单例模式

#import "XAccount.h"

#define kUserKey @"usr"
#define kPwdKey @"pwd"
#define kLoginKey @"login"

static NSString *domain = @"dengw";
static NSString *host = @"127.0.0.1";
static int port = 5222;

@implementation XAccount

+(instancetype)shareAccount
{
    return [[self alloc]init];
}

#pragma mark 分配内存创建对象
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    //单例模式
    NSLog(@"%s",__func__);
    static XAccount *account;
    
    //为了线程安全
    //三个线程同时调用该方法,保证只有一个account
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (account == nil) {
            account = [super allocWithZone:zone];
            
            //从沙盒获取上次登录的信息
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            account.loginUser = [defaults objectForKey:kUserKey];
            account.loginPwd = [defaults objectForKey:kPwdKey];
            account.login = [defaults boolForKey:kLoginKey];
        //}

    });
    
    return account;
}

#pragma mark 保存最新的数据到沙盒里
-(void)saveToSandBox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.loginUser forKey:kUserKey];
    [defaults setObject:self.loginPwd forKey:kPwdKey];
    [defaults setBool:self.isLogin forKey:kLoginKey];
    XLog(@"isLogin = %d", self.isLogin);
    [defaults synchronize];
}

-(NSString *)domain
{
    return domain;
}

-(NSString *)host
{
    return host;
}

-(int)port
{
    return port;
}

@end

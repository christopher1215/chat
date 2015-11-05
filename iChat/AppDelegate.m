//
//  AppDelegate.m
//  iChat
//
//  Created by dengwei on 15/7/25.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "AppDelegate.h"

//XMPP日志开关，能查看和服务器的交互xml数据
#define XMPP_LOG_EN 1

#if XMPP_LOG_EN
#import "DDTTYLogger.h"
#import "DDLog.h"
#endif

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#if XMPP_LOG_EN
    //配置XMPP的日志启动
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
    
    //判断用户是否登录
    if ([XAccount shareAccount].isLogin) {
        //进入主界面
        id mainVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
        self.window.rootViewController = mainVc;
        //自动登录
        [[XXMPPTool sharedXXMPPTool] xmppLogin:nil];
    }
    
    return YES;
}


@end

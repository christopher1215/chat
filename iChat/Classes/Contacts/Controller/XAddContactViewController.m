//
//  XAddContactViewController.m
//  iChat
//
//  Created by dengwei on 15/7/27.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "XAddContactViewController.h"

@interface XAddContactViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFeild;
- (IBAction)addContactBtnClick:(id)sender;

@end

@implementation XAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 添加好友
- (IBAction)addContactBtnClick:(id)sender {
    //添加好友
    //获取用户输入的好友名称
    NSString *usr = self.textFeild.text;
    
    //1.不能添加自己为好友
    if ([usr isEqualToString:[XAccount shareAccount].loginUser]) {
        [self showMsg:@"不能添加自己为好友"];
        return;
    }
    
    //2.已经存在的好友无需添加
    XMPPJID *usrJid = [XMPPJID jidWithUser:usr domain:[XAccount shareAccount].domain resource:nil];
    BOOL usrExist = [[XXMPPTool sharedXXMPPTool].rosterStorage userExistsWithJID:usrJid xmppStream:[XXMPPTool sharedXXMPPTool].xmppStream];
    
    if (usrExist) {
        [self showMsg:@"好友已经存在"];
        return;
    }
    
    //3.添加好友(订阅)
    [[XXMPPTool sharedXXMPPTool].roster subscribePresenceToUser:usrJid];
    
    /*添加好友在现有的openfire存在的问题
      1.添加不存在的好友，通讯录里面也会显示好友
      解决办法1：服务器可以拦截好友添加的请求，如当前请求的好友不存在，不要返回信息。
      解决办法2:过滤数据库的Subscription字段查询请求，
        none 对方没有同意添加好友
        to 好友关系请求发起方
        from 好友关系请求接受方
        both 双方互为好友
     */
}

#pragma mark 显示提示
-(void)showMsg:(NSString *)msg
{
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    
    [av show];
}

@end

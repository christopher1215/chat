//
//  XRegisterViewController.m
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "XRegisterViewController.h"

@interface XRegisterViewController ()
- (IBAction)cancelBtnClick:(id)sender;
- (IBAction)registerBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *usrField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation XRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtnClick:(id)sender {
    [UIStoryboard showInitialVCWithName:@"Login"];
}

- (IBAction)registerBtnClick:(id)sender {
    //注册
    //保存注册的用户名和密码
    [XAccount shareAccount].registerUser = self.usrField.text;
    [XAccount shareAccount].registerPwd = self.pwdField.text;
    
    [MBProgressHUD showMessage:@"正在注册..."];
    
    //调用注册方法
    //block会对self进行强引用，修改为弱引用
    __weak typeof(self) selfVc = self;
    //自己写的block，有强引用的时候，使用弱引用，系统的block，基本可以不用管
    [XXMPPTool sharedXXMPPTool].registerOperation = YES;
    [[XXMPPTool sharedXXMPPTool] xmppRegister:^(XMPPResultType resultType) {
        [selfVc handleXMPPResult:resultType];
    }];
}

#pragma mark 处理注册的结果
-(void)handleXMPPResult:(XMPPResultType)resultType
{
    //回到主线程工作
    dispatch_async(dispatch_get_main_queue(), ^{
        //隐藏提示
        [MBProgressHUD hideHUD];
        
        if (resultType == XMPPResultTypeRegisterSuccess) {
            [MBProgressHUD showSuccess:@"注册成功"];
            //注册成功切换到主界面
            
            
        }else{
            [MBProgressHUD showError:@"注册失败,用户已存在"];
        }
    });
}
@end

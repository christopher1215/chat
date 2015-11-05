//
//  XLoginViewController.m
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "XLoginViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD+HM.h"

@interface XLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
- (IBAction)LoginBtnClick:(id)sender;

@end

@implementation XLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)LoginBtnClick:(id)sender {
    //1.判断有没有输入用户名和密码
    if (self.userField.text.length == 0 || self.pwdField.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入用户名和密码"];
        
        return;
    }
    
    //给用户提示
    [MBProgressHUD showMessage:@"正在登录..."];
    
    //2.登录服务器
//    //2.1把用户名和密码保存到沙盒
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:self.userField.text forKey:@"usr"];
//    [defaults setObject:self.pwdField.text forKey:@"pwd"];
//    [defaults synchronize];
    //2.1把用户名和密码保存到Account单例
    [XAccount shareAccount].loginUser = self.userField.text;
    [XAccount shareAccount].loginPwd = self.pwdField.text;
    
    //2.2调用AppDelegate的xmppLogin方法
    //怎么把appdelegate的登录结果告诉XLoginViewController
    //delegate
    //block
    //notification
    
    //block会对self进行强引用，修改为弱引用
    __weak typeof(self) selfVc = self;
    //自己写的block，有强引用的时候，使用弱引用，系统的block，基本可以不用管
    
    //设置标示，标示是“登录”
    [XXMPPTool sharedXXMPPTool].registerOperation = NO;
    
    [[XXMPPTool sharedXXMPPTool] xmppLogin:^(XMPPResultType resultType) {
        [selfVc handleXMPPResultType:resultType];
        
    }];
    
}

#pragma mark 处理结果
-(void)handleXMPPResultType:(XMPPResultType)resultType
{
    //回到主线程更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        
        if (resultType == XMPPResultTypeLoginSuccess) {
            NSLog(@"%s 登录成功",__func__);
            //3.登录成功切换到主界面
            [self changeToMain];
            //设置当前登录状态
            [XAccount shareAccount].login = YES;
            //保存登录账户信息到沙盒
            [[XAccount shareAccount] saveToSandBox];

            
        }else{
            NSLog(@"%s 登录失败",__func__);
            [MBProgressHUD showError:@"用户名或密码不正确"];
        }
    });
    
}

#pragma mark 切换到主界面
-(void)changeToMain
{
//    //1.获取main.storyboard的第一个控制器
//    id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
//    
//    //2.切换window的根控制器
//    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
    [UIStoryboard showInitialVCWithName:@"Main"];
    
}
@end

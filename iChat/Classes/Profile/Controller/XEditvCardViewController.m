//
//  XEditvCardViewController.m
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "XEditvCardViewController.h"

@interface XEditvCardViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)saveBtnClick:(id)sender;

@end

@implementation XEditvCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题
    self.title = self.cell.textLabel.text;
    
    //设置输入框的默认数值
    self.textField.text = self.cell.detailTextLabel.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveBtnClick:(id)sender {
    //1.把cell的detailTextLabel的值修改
    self.cell.detailTextLabel.text = self.textField.text;
    
    //处理第一次修改个人信息，点击保存之后在个人信息页面无显示这个BUG
    [self.cell layoutSubviews];
    
    //2.当前控制器销毁
    [self.navigationController popViewControllerAnimated:YES];
    //3.通知上一个控制器
    if ([self.delegate respondsToSelector:@selector(editvCardViewController:didFinishedSave:)]) {
        [self.delegate editvCardViewController:self didFinishedSave:sender];
    }
}
@end

//
//  XMeTableViewController.m
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "XMeTableViewController.h"
#import "AppDelegate.h"

#import "XMPPvCardTemp.h"

@interface XMeTableViewController ()
- (IBAction)logoutBtnClick:(id)sender;
//登录用户的头像
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
//登录用户微信号
@property (weak, nonatomic) IBOutlet UILabel *iChatNumLabel;

@end

@implementation XMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示头像和微信号
    //从数据库里取用户数据信息
    //获取登录用户信息，使用电子名片模块
    
    //登录用户的电子名片信息
    //1.它内部会去数据查找
    XMPPvCardTemp *myvCard = [XXMPPTool sharedXXMPPTool].vCard.myvCardTemp;
    
    //获取头像
    if (myvCard.photo) {
        self.avatarImageView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    //微信号(显示用户名)
    //为什么JID是nil？因为服务器返回的电子名片xml数据中没有JABBERJID节点
    //self.iChatNumLabel.text = myvCard.jid.user;
    self.iChatNumLabel.text = [@"微信号: " stringByAppendingString:[XAccount shareAccount].loginUser];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logoutBtnClick:(id)sender {
    //注销
    [[XXMPPTool sharedXXMPPTool] xmppLogout];
    
    //把沙盒的登录状态设置为NO
    [XAccount shareAccount].login = NO;
    [[XAccount shareAccount] saveToSandBox];
    
    //回到登录的控制器
    [UIStoryboard showInitialVCWithName:@"Login"];
    
}
@end

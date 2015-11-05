//
//  XProfileViewController.m
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "XProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "XEditvCardViewController.h"

@interface XProfileViewController ()<XEditvCardViewControllerDelegate, UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;//头像
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;//昵称
@property (weak, nonatomic) IBOutlet UILabel *iChatNumLabel;//微信号
@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel;//公司
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;//部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//职位
@property (weak, nonatomic) IBOutlet UILabel *telLabel;//电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;//邮箱

@end

@implementation XProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.它内部会去数据查找
    //为什么电子名片模型是temp，因为解析电子名片的xml没有完善，有些节点并未解析，例如，电话节点。
    XMPPvCardTemp *myvCard = [XXMPPTool sharedXXMPPTool].vCard.myvCardTemp;
    //获取头像
    if (myvCard.photo) {
        self.avatarImageView.image = [UIImage imageWithData:myvCard.photo];
    }
    
    //微信号(显示用户名)
    self.iChatNumLabel.text = [XAccount shareAccount].loginUser;
    
    self.nickNameLabel.text = myvCard.nickname;//昵称
    self.orgNameLabel.text = myvCard.orgName;//公司
    //部门
    if (myvCard.orgUnits.count > 0) {
        self.departmentLabel.text = myvCard.orgUnits[0];
    }
    //职位
    self.titleLabel.text = myvCard.title;
    //电话,使用note充当电话
    self.telLabel.text = myvCard.note;

    //解析邮箱
    NSArray *emails = myvCard.emailAddresses;
    if(emails.count > 0)
    {
        self.emailLabel.text = emails[0];
    }
    //邮箱,使用mailer充当
    //self.emailLabel.text = myvCard.mailer;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     根据cell不同的tag进行相应的操作
     tag ＝ 0，换头像
     tag ＝ 1，进行到下一个控制器
     tag ＝ 2，不做任何操作
     */
    
    //获取cell
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    switch (selectedCell.tag) {
        case 0:
            XLog(@"换头像");
            [self choseImage];
            break;
        case 1:
            XLog(@"进行到下一个控制器");
            [self performSegueWithIdentifier:@"toEditVcSegue" sender:selectedCell];
            break;
        case 2:
            XLog(@"不做任何操作");
            break;
            
        default:
            break;
    }
    
}

#pragma mark 选择图片
-(void)choseImage
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"图片库", nil];
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    XLog(@"%ld", buttonIndex);
    if (buttonIndex == 2) {//取消
        return;
    }
    
    //图片选择器
    UIImagePickerController *imagePC = [[UIImagePickerController alloc]init];
    
    //设置代理
    imagePC.delegate = self;
    
    //允许编辑图片
    imagePC.allowsEditing = YES;
    
    if (buttonIndex == 0) { //照相
        imagePC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{//图片库
        imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //显示控制器
    [self presentViewController:imagePC animated:YES completion:nil];
}

#pragma mark 图片选择器的代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    XLog(@"%@",info);
    //获取修改后的图片
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    //更改cell图片
    self.avatarImageView.image = editedImage;
    
    //移除图片选择控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //把新的头像图片数据保存到服务器
    [self editvCardViewController:nil didFinishedSave:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取目标控制器
    id destVc = segue.destinationViewController;
    //设置编辑电子名片控制器的cell属性
    if ([destVc isKindOfClass:[XEditvCardViewController class]]) {
        XEditvCardViewController *editVc = destVc;
        editVc.cell = sender;
        //设置代理
        editVc.delegate = self;
    }
}

#pragma mark 编辑电子名片控制器代理
-(void)editvCardViewController:(XEditvCardViewController *)editVc didFinishedSave:(id)sender
{
    XLog(@"完成保存");
    //获取当前电子名片
    XMPPvCardTemp *myvCard = [XXMPPTool sharedXXMPPTool].vCard.myvCardTemp;
    
    //重新设置头像,以原图的0.75倍上传
    myvCard.photo = UIImageJPEGRepresentation(self.avatarImageView.image, 0.75);
    
    //重新设置myvCard里的属性
    myvCard.nickname = self.nickNameLabel.text;
    myvCard.orgName = self.orgNameLabel.text;
    if (self.departmentLabel.text != nil) {
        myvCard.orgUnits = @[self.departmentLabel.text];
    }
    myvCard.title = self.titleLabel.text;
    myvCard.note = self.telLabel.text;
    //解析邮箱
    //myvCard.mailer = self.emailLabel.text;
    if (self.emailLabel.text.length > 0) {
        //只保存一个邮箱
        myvCard.emailAddresses = @[self.emailLabel.text];
        XLog(@"保存邮箱");
    }
    
    //把数据保存到服务器
    [[XXMPPTool sharedXXMPPTool].vCard updateMyvCardTemp:myvCard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

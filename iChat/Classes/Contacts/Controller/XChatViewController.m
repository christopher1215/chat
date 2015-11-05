//
//  XChatViewController.m
//  iChat
//
//  Created by dengwei on 15/7/28.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "XChatViewController.h"

@interface XChatViewController ()<NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSFetchedResultsController *_resultControl;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//输入框容器距离底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
- (IBAction)imageChoseBtnClick:(id)sender;

@end

@implementation XChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //键盘监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //加载数据库的聊天记录
    
    //1.上下文
    NSManagedObjectContext *msgContext = [XXMPPTool sharedXXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    
    //2.查询请求
    NSFetchRequest  *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    //过滤(当前登录用户并且是好友的聊天消息)
    NSString *loginUsrJid = [XXMPPTool sharedXXMPPTool].xmppStream.myJID.bare;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",loginUsrJid, self.friendJid];
    request.predicate = pre;
    
    //设置时间排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    //3.执行请求
    _resultControl = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultControl.delegate = self;
    NSError *err = nil;
    [_resultControl performFetch:&err];
    if (err) {
        XLog(@"err:%@",err);
    }
    XLog(@"%@",_resultControl.fetchedObjects);

}

#pragma mark 键盘将显示
-(void)kbWillShow:(NSNotification *)noti
{
    //显示的时候改变bottomConstraint
    
    //获取键盘高度
    CGFloat kbHeight = [noti.userInfo[UIKeyboardFrameBeginUserInfoKey]CGRectValue].size.height;
    
    self.bottomConstraint.constant = kbHeight;
    
}

#pragma mark 键盘将隐藏
-(void)kbWillHide:(NSNotification *)noti
{
    self.bottomConstraint.constant = 0;
}

#pragma mark 表格滚动隐藏键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark 发送聊天数据
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //按钮已经判断文本是否为空，不需要再判断
    NSString *text = textField.text;
    
    //怎么发送聊天数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:text];
    [[XXMPPTool sharedXXMPPTool].xmppStream sendElement:msg];
    
    //清空输入框文本
    textField.text = nil;
    
    
    return YES;
}

#pragma mark 数据库内容改变则调用
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    XLog(@"数据库内容改变则调用");
    [self.tableView reloadData];
    
    //表格滚动到底部
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_resultControl.fetchedObjects.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark 表格数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultControl.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ChatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //获取聊天信息
    XMPPMessageArchiving_Message_CoreDataObject *msgObject = _resultControl.fetchedObjects[indexPath.row];
    
    //判断消息的类型有没有附件
    //1.获取原始的xml数据
    XMPPMessage *message = msgObject.message;
    //获取附件的类型
    NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
    
    if ([bodyType isEqualToString:@"image"]) { //图片
        //2.遍历message的子节点
        NSArray *child = message.children;
        for (XMPPElement *node in child) {
            //获取节点的名字
            if([[node name] isEqualToString:@"attachment"])
            {
                XLog(@"获得附件...");
                //获取附件的字符串，然后转成NSData，接着转成图片
                NSString *imageBase64Str = [node stringValue];
                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageBase64Str options:0];
                UIImage *image = [UIImage imageWithData:imageData];
                cell.imageView.image = image;
            }
        }
        
    }else if ([bodyType isEqualToString:@"sound"]) { //音频
        
    }else{ //纯文本
        cell.textLabel.text = msgObject.body;

    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 图片发送（文件发送）
- (IBAction)imageChoseBtnClick:(id)sender {
    //从图片库选择图片
    UIImagePickerController *imagePC = [[UIImagePickerController alloc]init];
    imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePC.delegate = self;
    [self presentViewController:imagePC animated:YES completion:nil];
}

#pragma mark 用户选择的图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    XLog(@"%@",info);
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //发送图片附件
    [self sendAttachmentWithData:UIImagePNGRepresentation(image) bodyType:@"image"];
    
    //隐藏图片选择的控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

#pragma mark 发送附件
-(void)sendAttachmentWithData:(NSData *)data bodyType:(NSString *)bodyType
{
    //发送附件
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    //设置类型
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
#pragma mark 没有body救不认识
    [msg addBody:bodyType]; //image,doc,sound....
    
    //把附件经过“base64编码”转成字符串
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    
    //定义附件
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64Str];
    
    //添加子节点
    [msg addChild:attachment];
    
    [[XXMPPTool sharedXXMPPTool].xmppStream sendElement:msg];
}

//#pragma mark 发送图片附件
//-(void)sendAttachmentWithImage:(UIImage *)image
//{
//    //发送图片
//    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
//    
//#pragma mark 没有body救不认识
//    [msg addBody:@"image"]; //image,doc,sound....
//    
//    //把图片经过“base64编码”转成字符串
//    //1)把图片转成NSData
//    NSData *imageData = UIImagePNGRepresentation(image);
//    //2)NSData转成base64的字符串
//    NSString *imageBase64Str = [imageData base64EncodedStringWithOptions:0];
//    
//    //定义附件
//    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:imageBase64Str];
//    
//    //添加子节点
//    [msg addChild:attachment];
//    
//    [[XXMPPTool sharedXXMPPTool].xmppStream sendElement:msg];
//}

@end

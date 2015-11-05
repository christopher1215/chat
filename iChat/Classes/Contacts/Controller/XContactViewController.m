//
//  XContactViewController.m
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import "XContactViewController.h"
#import "XChatViewController.h"

@interface XContactViewController ()<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_resultsControl;
}

//好友
@property (strong, nonatomic)NSArray *usrs;

@end

@implementation XContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadUser_B];
    
}

#pragma mark 加载好友数据方法1
-(void)loadUser_A
{
    //显示好友数据 （保存XMPPRoster.sqlite文件）
    //1.上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [XXMPPTool sharedXXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    //2.Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //设置一下排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    //3.执行请求
    NSError *err = nil;
    NSArray *users = [rosterContext executeFetchRequest:request error:&err];
    if (err) {
        XLog(@"%@",err);
    }
    //XLog(@"%@",users);
    self.usrs = users;
}

#pragma mark 加载好友数据方法2
-(void)loadUser_B
{
    //显示好友数据 （保存XMPPRoster.sqlite文件）
    //1.上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [XXMPPTool sharedXXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    //2.Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //过滤(添加联系人时，对方没有同意的不显示)
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@",@"none"];
    request.predicate = pre;
    
    
    //3.执行请求
    //3.1创建结果控制器
    //数据库的查询，如果数据很多，会放在子线程查询。
    //移动客户端的数据库数据不会很多，所以很多数据库的查询操作都在主线程
    _resultsControl = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    //设置代理
    _resultsControl.delegate = self;
    NSError *err = nil;
    //3.2执行
    [_resultsControl performFetch:&err];
    if (err) {
        XLog(@"err:%@",err);
    }
    
}

#pragma mark － 结果控制器的代理
#pragma mark 数据库内容改变就会调用
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    XLog(@"%@",[NSThread currentThread]);
    //刷新表格
    [self.tableView reloadData];
}

#pragma mark 返回多少行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return self.usrs.count;
    return _resultsControl.fetchedObjects.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //获取对应的好友
    //XMPPUserCoreDataStorageObject *user = self.usrs[indexPath.row];
    XMPPUserCoreDataStorageObject *user = _resultsControl.fetchedObjects[indexPath.row];
    //标识用户是否在线
    //user.sectionNum,0：表示“在线”，1:表示“离开”，2：表示“离线”
    XLog(@"%@:在线状态%@",user.displayName,user.sectionNum);
    
    cell.textLabel.text = user.displayName;
    
    //1.通过KVO监听用户状态的改变
    //[user addObserver:self forKeyPath:@"sectionNum" options:NSKeyValueObservingOptionNew context:nil];
    
    //2.监听整个数据库的改变,controllerDidChangeContent
    
    
    switch ([user.sectionNum integerValue]) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
            
        default:
            break;
    }
    
    //好友头像的显示
    if (user.photo) {//默认的情况下，不是程序一启动就有头像
        cell.imageView.image = user.photo;
    }else{
        //从服务器获取头像
        NSData *imageData = [[XXMPPTool sharedXXMPPTool].avatar photoDataForJID:user.jid];
        cell.imageView.image = [UIImage imageWithData:imageData];
    }
    
    return cell;
}

#pragma mark 删除好友
//实现此方法，就会出现Delete按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //好友
    XMPPUserCoreDataStorageObject *user = _resultsControl.fetchedObjects[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除好友
        [[XXMPPTool sharedXXMPPTool].roster removeUser:user.jid];
    }
    
    //刷新表格？不需要，删除之后直接从数据库里删除了。数据库内容改变，controllerDidChangeContent会被调用。
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取friendJid
    XMPPJID *friendJid = [_resultsControl.fetchedObjects[indexPath.row] jid];
    //进入聊天控制器
    [self performSegueWithIdentifier:@"toChatVcSegue" sender:friendJid];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[XChatViewController class]]) {
        XChatViewController *chatVc = destVc;
        chatVc.friendJid = sender;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

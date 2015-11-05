//
//  XEditvCardViewController.h
//  iChat
//
//  Created by dengwei on 15/7/26.
//  Copyright (c) 2015年 dengwei. All rights reserved.
//

#import <UIKit/UIKit.h>


@class XEditvCardViewController;
@protocol XEditvCardViewControllerDelegate <NSObject>

-(void)editvCardViewController:(XEditvCardViewController *)editVc didFinishedSave:(id)sender;

@end

@interface XEditvCardViewController : UITableViewController

//上一个控制器(个人信息控制器)传入的cell
@property (strong, nonatomic)UITableViewCell *cell;

@property (weak, nonatomic)id<XEditvCardViewControllerDelegate> delegate;

@end

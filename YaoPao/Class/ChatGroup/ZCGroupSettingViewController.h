//
//  ZCGroupSettingViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/27.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSDKFull.h"
#import "ContactSelectionViewController.h"
#import "GroupSettingViewController.h"
#import "CNNetworkHandler.h"


@interface ZCGroupSettingViewController : UIViewController<IChatManagerDelegate, EMChooseViewDelegate,groupMemberDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSString* chatGroupId;
@property (strong, nonatomic) EMGroup *chatGroup;
@property (assign, nonatomic) BOOL isOwner;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UIView *view_member;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button_exit;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (weak, nonatomic) IBOutlet UIButton *button_clear;

@end

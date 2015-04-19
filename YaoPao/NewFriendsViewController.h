//
//  NewFriendsViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/9.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
@class FriendInfo;

@interface NewFriendsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,agreeMakeFriendsDelegate>
@property (strong, nonatomic) FriendInfo* friendOnHandle;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray* friendsToInvite;//没有使用app的人，可以邀请

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

@end

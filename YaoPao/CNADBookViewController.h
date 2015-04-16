//
//  CNADBookViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/9.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"

@interface CNADBookViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,friendsListDelegate,sendMakeFriendsRequestDelegate,agreeMakeFriendsDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;


@property (strong, nonatomic) NSMutableArray* keys;
@property (strong, nonatomic) NSMutableDictionary* groupedMap;

@property (strong, nonatomic) NSMutableArray* friends;//已经是好友列表
@property (strong, nonatomic) NSMutableArray* friendsIWant;//我申请加别人好友列表（新的朋友组成之1）
@property (strong, nonatomic) NSMutableArray* frinedsWantMe;//别人申请加我的列表（新的朋友组成之2）
//@property (strong, nonatomic) NSMutableArray* myContactUseApp;//我的通讯录里使用app的所有人,改为appdelegate下获取
@property (strong, nonatomic) NSMutableArray* myContactUseAppButNotFriend;//推荐的好友=myContactUseApp(A)-A中的好友-A中friendsIWant-A中frinedsWantMe（新的朋友组成之3）
@property (strong, nonatomic) NSMutableArray* friendsNew;//新的朋友列表myContactUseAppButNotFriend+frinedsWantMe+friendsIWant
@property (assign, nonatomic) BOOL haveNewFriends;//和上次比较是否有新的朋友


@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
- (IBAction)button_clicked:(id)sender;

@end

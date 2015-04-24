//
//  SearchFriendViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/20.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
@class FriendInfo;

@interface SearchFriendViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,agreeMakeFriendsDelegate,searchFriendDelegate>
@property (strong,nonatomic) NSMutableArray* searchResult;
@property (strong, nonatomic) FriendInfo* friendOnHandle;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

@end

//
//  CNADBookViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/9.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsHandler.h"
@class CNCustomButton;

@interface CNADBookViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,requestFriendsDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;


@property (weak, nonatomic) IBOutlet CNCustomButton *button_add;
@property (strong, nonatomic) NSMutableArray* keys;
@property (strong, nonatomic) NSMutableDictionary* groupedMap;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) NSMutableArray* keysJustFriend;
- (IBAction)button_clicked:(id)sender;

@end

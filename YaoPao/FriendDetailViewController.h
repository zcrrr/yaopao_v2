//
//  FriendDetailViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/14.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendInfo;
#import "CNNetworkHandler.h"

@interface FriendDetailViewController : UIViewController<UIAlertViewDelegate,deleteFriendDelegate>

@property (strong, nonatomic) NSString* from;
@property (weak, nonatomic) IBOutlet UIButton *button_deletefriend;
@property (strong, nonatomic) FriendInfo* friend;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_phone;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_sex;
- (IBAction)button_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (weak, nonatomic) IBOutlet UIButton *button_chat;
@property (weak, nonatomic) IBOutlet UIButton *button_clearHistory;

@end

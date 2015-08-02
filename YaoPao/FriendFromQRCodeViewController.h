//
//  FriendFromQRCodeViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/7/30.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"

@class FriendInfo;

@interface FriendFromQRCodeViewController : UIViewController<agreeMakeFriendsDelegate>

@property (strong,nonatomic) FriendInfo* friend;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_phone;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_sex;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button_action;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

@end

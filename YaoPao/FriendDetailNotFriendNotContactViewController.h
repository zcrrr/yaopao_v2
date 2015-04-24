//
//  FriendDetailNotFriendNotContactViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/20.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendInfo;

@interface FriendDetailNotFriendNotContactViewController : UIViewController
@property (strong, nonatomic) FriendInfo* friend;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_phone;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_sex;
- (IBAction)button_clicked:(id)sender;

@end

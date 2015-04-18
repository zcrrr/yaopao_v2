//
//  FriendDetailFromChatViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendInfo;

@interface FriendDetailFromChatViewController : UIViewController

@property (strong, nonatomic) FriendInfo* friend;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_phone;
- (IBAction)button_clicked:(id)sender;

@end

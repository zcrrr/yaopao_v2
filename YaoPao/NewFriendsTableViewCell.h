//
//  NewFriendsTableViewCell.h
//  YaoPao
//
//  Created by 张驰 on 15/4/14.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (weak, nonatomic) IBOutlet UILabel *label_username;
@property (weak, nonatomic) IBOutlet UIButton *button_action;

@end

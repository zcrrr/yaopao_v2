//
//  CNFinishViewController.h
//  YaoPao
//
//  Created by zc on 14-8-27.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNFinishViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *image_avatar;
@property (strong, nonatomic) IBOutlet UILabel *label_username;
@property (strong, nonatomic) IBOutlet UILabel *label_teamname;
- (IBAction)button_back_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

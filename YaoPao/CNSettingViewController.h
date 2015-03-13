//
//  CNSettingViewController.h
//  YaoPao
//
//  Created by zc on 14-8-29.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNSettingViewController : UIViewController
- (IBAction)button_back_clicked:(id)sender;
- (IBAction)button_list_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UIView *view_user;
@property (strong, nonatomic) IBOutlet UIView *view_about;
@property (strong, nonatomic) IBOutlet UIView *view_ad;
@property (strong, nonatomic) IBOutlet UIButton *button_user;
@property (strong, nonatomic) IBOutlet UIButton *button_about;
@property (strong, nonatomic) IBOutlet UIButton *button_ad;
@property (strong, nonatomic) IBOutlet UIView *view_service;
@property (strong, nonatomic) IBOutlet UIButton *button_service;

@end

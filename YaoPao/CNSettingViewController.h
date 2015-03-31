//
//  CNSettingViewController.h
//  YaoPao
//
//  Created by zc on 14-8-29.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstLevelViewController.h"

@interface CNSettingViewController : FirstLevelViewController
@property (weak, nonatomic) IBOutlet UIButton *button_personal;
@property (weak, nonatomic) IBOutlet UIButton *button_system;
@property (weak, nonatomic) IBOutlet UIButton *button_update;
@property (weak, nonatomic) IBOutlet UIButton *button_feedback;
@property (weak, nonatomic) IBOutlet UIButton *button_service;
@property (weak, nonatomic) IBOutlet UIButton *button_about;

- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_personal;
@property (weak, nonatomic) IBOutlet UIView *view_system;
@property (weak, nonatomic) IBOutlet UIView *view_update;
@property (weak, nonatomic) IBOutlet UIView *view_feedback;
@property (weak, nonatomic) IBOutlet UIView *view_service;
@property (weak, nonatomic) IBOutlet UIView *view_about;
@property (weak, nonatomic) IBOutlet UIView *view_line1;
@property (weak, nonatomic) IBOutlet UIView *view_line2;
@property (weak, nonatomic) IBOutlet UIView *view_line3;
@property (weak, nonatomic) IBOutlet UIView *view_line4;

@end

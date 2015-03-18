//
//  HomeViewController.h
//  AssistUI
//
//  Created by 张驰 on 15/3/10.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstLevelViewController.h"
#import "CNCustomButton.h"

@interface HomeViewController : FirstLevelViewController
@property (weak, nonatomic) IBOutlet CNCustomButton *button_cloud;
@property (weak, nonatomic) IBOutlet UIButton *button_go_login;
@property (weak, nonatomic) IBOutlet UIButton *button_setting;
@property (weak, nonatomic) IBOutlet UIButton *button_running;
@property (weak, nonatomic) IBOutlet UIImageView *image_avatar;
@property (weak, nonatomic) IBOutlet UILabel *label_username;
@property (weak, nonatomic) IBOutlet UILabel *label_km;
@property (weak, nonatomic) IBOutlet UILabel *label_count;
@property (weak, nonatomic) IBOutlet UILabel *label_secondPerKm;
@property (weak, nonatomic) IBOutlet UILabel *label_score;
@property (weak, nonatomic) IBOutlet UILabel *label_target_type;
@property (weak, nonatomic) IBOutlet UILabel *label_gps;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

- (IBAction)button_clicked:(id)sender;



@end

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
#import "CNNetworkHandler.h";

@interface HomeViewController : FirstLevelViewController<weatherDelegate>
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
@property (weak, nonatomic) IBOutlet UILabel *label_temp;
@property (weak, nonatomic) IBOutlet UILabel *label_pmLevel;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_weather;
@property (weak, nonatomic) IBOutlet UIProgressView *progressview_cloud;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

- (IBAction)button_clicked:(id)sender;

- (IBAction)button_logout:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *view_part1;
@property (weak, nonatomic) IBOutlet UIView *view_part2;
@property (weak, nonatomic) IBOutlet UIView *view_part3;
@property (weak, nonatomic) IBOutlet UIView *view_part4;
@property (weak, nonatomic) IBOutlet UIView *view_line_verticle;
@property (weak, nonatomic) IBOutlet UIView *view_line_horizontal1;
@property (weak, nonatomic) IBOutlet UIView *view_line_horizontal2;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_part1;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_part2;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_part3;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *weather_progress;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_matchlogo;

@end

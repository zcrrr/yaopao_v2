//
//  CNMainViewController.h
//  YaoPao
//
//  Created by zc on 14-7-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
@class CNDistanceImageView;
@class CNNumImageView;
@class CNSpeedImageView;
@class CNNumImageView;
#import "GADBannerView.h"
#import "ASIHTTPRequest.h"

@interface CNMainViewController : UIViewController<ASIProgressDelegate>
@property (strong, nonatomic) IBOutlet UILabel *label_username;
@property (strong, nonatomic) IBOutlet UILabel *label_des;
@property (strong, nonatomic) IBOutlet UIButton *button_goLogin;
@property (strong, nonatomic) IBOutlet UIImageView *image_avatar;
@property (strong, nonatomic) IBOutlet UIView *view_total_count;
@property (strong, nonatomic) IBOutlet UIView *view_total_speed;
@property (strong, nonatomic) IBOutlet UIView *view_total_score;
@property (strong, nonatomic) IBOutlet UIImageView *imageview_dot;
@property (strong, nonatomic) IBOutlet UIButton *button_setting;
@property (strong, nonatomic) IBOutlet UIButton *button_cloud;
@property (strong, nonatomic) IBOutlet UIView *view_record;
@property (strong, nonatomic) IBOutlet UIButton *button_record;

@property (strong, nonatomic) IBOutlet UIView *view_message;
@property (strong, nonatomic) IBOutlet UIView *view_match;
@property (strong, nonatomic) IBOutlet UIButton *button_message;
@property (strong, nonatomic) IBOutlet UIButton *button_match;

@property (strong, nonatomic) CNDistanceImageView* div;
@property (strong, nonatomic) UIImageView* image_km;
@property (strong, nonatomic) CNNumImageView* niv_count;
@property (strong, nonatomic) CNSpeedImageView* siv;
@property (strong, nonatomic) CNNumImageView* niv;
@property (strong, nonatomic) GADBannerView *bannerView_;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

- (IBAction)logout:(id)sender;

- (IBAction)button_clicked:(id)sender;

@end

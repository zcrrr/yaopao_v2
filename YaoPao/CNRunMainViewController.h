//
//  CNRunMainViewController.h
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBSliderView.h"
@class AMBlurView;
@class CNDistanceImageView;
@class CNTimeImageView;
@class CNSpeedImageView;

@interface CNRunMainViewController : UIViewController<MBSliderViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet MBSliderView *sliderview;
@property (strong, nonatomic) IBOutlet UIView *view_bottom_bar;
@property (strong, nonatomic) IBOutlet UIButton *button_complete;
@property (strong, nonatomic) IBOutlet UIButton *button_reset;
@property (strong, nonatomic) IBOutlet UIView *view_progress;
@property (strong, nonatomic) IBOutlet UILabel *label_dis;
@property (strong, nonatomic) IBOutlet UILabel *label_time;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;
@property (strong, nonatomic) IBOutlet UIView *view_bottom_slider;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview_test;
@property (strong, nonatomic) IBOutlet UILabel *label_target;
@property (strong, nonatomic) NSTimer* timer_dispalyTime;


@property (strong, nonatomic) CNDistanceImageView* big_div;
@property (strong, nonatomic) CNTimeImageView* big_tiv;
@property (strong, nonatomic) CNDistanceImageView* div;
@property (strong, nonatomic) CNTimeImageView* tiv;
@property (strong, nonatomic) CNSpeedImageView* siv;

@property (strong, nonatomic) IBOutlet AMBlurView *view_blur;

@property (assign, nonatomic) double distance_add;//用于计算积分
@property (assign, nonatomic) int second_add;//用户计算积分

@property (assign , nonatomic) int pass_km;//刚刚过的km
@property (assign, nonatomic) BOOL playkm;//是否播放过整公里
@property (assign, nonatomic) BOOL reachTarget;//是否达到目标
@property (assign, nonatomic) BOOL playTarget;//是否播报过达到目标
@property (assign, nonatomic) BOOL reachHalf;//是否达到一半
@property (assign, nonatomic) BOOL playHalf;//是否播报过一半
@property (assign, nonatomic) BOOL closeToTarget;//接近目标

@property (assign, nonatomic) int pass_5munite;//刚过的第几个5分钟
@property (assign, nonatomic) BOOL play5munite;//是否播放过整5分钟

- (IBAction)button_map_clicked:(id)sender;
- (IBAction)button_control_clicked:(id)sender;

@end

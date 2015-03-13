//
//  CNMatchMainRecomeViewController.h
//  YaoPao
//
//  Created by zc on 14-9-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
@class CNDistanceImageView;
@class CNTimeImageView;
@class CNSpeedImageView;

@interface CNMatchMainRecomeViewController : UIViewController<endMatchDelegate,matchOnekmDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *image_avatar;
@property (strong, nonatomic) IBOutlet UILabel *label_name;
@property (strong, nonatomic) IBOutlet UILabel *label_team;
@property (strong, nonatomic) IBOutlet UILabel *label_nextArea;
- (IBAction)button_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview_test;
@property (strong, nonatomic) IBOutlet UIView *view_offtrack;
@property (strong, nonatomic) IBOutlet UIView *view_distance;

@property (strong, nonatomic) CNDistanceImageView* big_div;
@property (strong, nonatomic) CNTimeImageView* tiv;
@property (strong, nonatomic) CNSpeedImageView* siv;


@property (assign, nonatomic) double nextDis;
@property (assign, nonatomic) BOOL isIn;

@property (assign, nonatomic) int tryCount;
@property (assign, nonatomic) long long lastKMTime;
@end

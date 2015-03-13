//
//  CNGroupInfoViewController.h
//  YaoPao
//
//  Created by zc on 14-8-17.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "CNNetworkHandler.h"
@class CNDistanceImageView;

@interface CNGroupInfoViewController : UIViewController<MAMapViewDelegate,teamSimpleInfoDelegate>
@property (nonatomic, strong) NSString* from;
@property (nonatomic, strong) NSTimer* timer_refresh_data;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAPointAnnotation *annotation;

@property (strong, nonatomic) IBOutlet UIView *view_mapContainer;
@property (strong, nonatomic) IBOutlet UILabel *label_tName;
@property (strong, nonatomic) IBOutlet UILabel *label_date;
@property (strong, nonatomic) IBOutlet UILabel *label_time;
@property (strong, nonatomic) IBOutlet UILabel *label_pspeed;
@property (strong, nonatomic) IBOutlet UILabel *label_avr_speed;
@property (strong, nonatomic) IBOutlet UILabel *label_uname;
@property (strong, nonatomic) IBOutlet UIImageView *image_avatar;
@property (strong, nonatomic) IBOutlet UIButton *button_map;
@property (strong, nonatomic) IBOutlet UIButton *button_me;
@property (strong, nonatomic) IBOutlet UIButton *button_list;
@property (strong, nonatomic) IBOutlet UIButton *button_message;
@property (strong, nonatomic) IBOutlet UIButton *button_relay;

@property (strong, nonatomic) CNDistanceImageView* div;
@property (strong, nonatomic) UIImageView* image_km;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

@property (strong, nonatomic) NSString* imagePath;
@property (strong, nonatomic) UIImage* avatarImage;
@property (assign, nonatomic) double lon;//最新位置
@property (assign, nonatomic) double lat;//最新位置
@property (strong, nonatomic) IBOutlet UIView *view_message;
@property (strong, nonatomic) IBOutlet UIView *view_transmit;
@property (strong, nonatomic) IBOutlet UIView *view_me;
@property (strong, nonatomic) IBOutlet UIView *view_list;

@property (strong, nonatomic) IBOutlet UIImageView *imageview_dot;
- (IBAction)button_back_clicked:(id)sender;

- (IBAction)button_clicked:(id)sender;

@end

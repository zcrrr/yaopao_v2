//
//  CNRecordMapViewController.h
//  YaoPao
//
//  Created by zc on 14-8-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunClass.h"
#import <MAMapKit/MAMapKit.h>
@class CNCustomButton;
@interface CNRecordMapViewController : UIViewController<MAMapViewDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAPolyline* polyline_back;
@property (nonatomic, strong) MAPolyline* polyline_forward;
@property (strong, nonatomic) RunClass* oneRun;
@property (strong, nonatomic) IBOutlet UILabel *label_title;
- (IBAction)button_back_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *label_dis;
@property (strong, nonatomic) IBOutlet UILabel *label_during;
@property (strong, nonatomic) IBOutlet UILabel *label_pspeed;
@property (strong, nonatomic) IBOutlet UILabel *label_aver_speed;
@property (strong, nonatomic) IBOutlet UILabel *label_date;
@property (strong, nonatomic) IBOutlet UILabel *label_date1;
@property (strong, nonatomic) IBOutlet UILabel *label_date2;
@property (strong, nonatomic) IBOutlet UILabel *label_date3;
@property (strong, nonatomic) IBOutlet UILabel *label_date4;

@property (strong, nonatomic) IBOutlet UIImageView *image_type;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_mood;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_way;
@property (strong, nonatomic) IBOutlet UIView *view_map_container;
@property (strong, nonatomic) IBOutlet CNCustomButton *button_back;

@end

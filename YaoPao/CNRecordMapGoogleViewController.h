//
//  CNRecordMapGoogleViewController.h
//  YaoPao
//
//  Created by zc on 15-1-3.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "RunClass.h"

@interface CNRecordMapGoogleViewController : UIViewController

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSPolyline* polyline_back;
@property (nonatomic, strong) GMSPolyline* polyline_forward;
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
@property (strong, nonatomic) IBOutlet UIView *view_map_container;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

//
//  CNMatchMapViewController.h
//  YaoPao
//
//  Created by zc on 14-9-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
@class CNGPSPoint4Match;

@interface CNMatchMapViewController : UIViewController<MAMapViewDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSTimer* timer_match_map;
@property (nonatomic, strong) CNGPSPoint4Match* lastDrawPoint;
- (IBAction)button_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (strong, nonatomic) IBOutlet UILabel *label_uname;
@property (strong, nonatomic) IBOutlet UILabel *label_tname;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) IBOutlet UIButton *button_relay;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

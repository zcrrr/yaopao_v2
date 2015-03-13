//
//  CNNoRunMapViewController.h
//  YaoPao
//
//  Created by zc on 14-9-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "CNNetworkHandler.h"

@interface CNNoRunMapViewController : UIViewController<MAMapViewDelegate,teamSimpleInfoDelegate>
@property (nonatomic, strong) NSTimer* timer_refresh_data;
@property (nonatomic, strong) MAMapView *mapView;
@property (strong, nonatomic) NSString* imagePath;
@property (assign, nonatomic) double lon;//最新位置
@property (assign, nonatomic) double lat;//最新位置
@property (strong, nonatomic) UIImage* avatarImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (nonatomic, strong) MAPointAnnotation *annotation;
- (IBAction)button_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

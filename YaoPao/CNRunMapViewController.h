//
//  CNRunMapViewController.h
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "MBSliderView.h"
#import "CNCustomButton.h"
@class CNGPSPoint;

@interface CNRunMapViewController : UIViewController<MAMapViewDelegate,MBSliderViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSTimer* timer_map;
@property (nonatomic, strong) CNGPSPoint* lastDrawPoint;

@property (strong, nonatomic) IBOutlet MBSliderView *sliderview;
@property (strong, nonatomic) IBOutlet UIView *view_bottom_bar;
@property (strong, nonatomic) IBOutlet UIView *view_bottom_slider;

@property (strong, nonatomic) IBOutlet CNCustomButton *button_complete;
@property (strong, nonatomic) IBOutlet CNCustomButton *button_reset;

- (IBAction)button_clicked:(id)sender;


@end

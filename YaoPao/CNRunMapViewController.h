//
//  CNRunMapViewController.h
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
@class CNGPSPoint;
@class CircularLock;

@interface CNRunMapViewController : UIViewController<MAMapViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSTimer* timer_map;
@property (nonatomic, strong) CNGPSPoint* lastDrawPoint;
@property (strong, nonatomic) CircularLock *pauseButoon;


@property (strong, nonatomic) IBOutlet UIButton *button_complete;

- (IBAction)button_clicked:(id)sender;


@end

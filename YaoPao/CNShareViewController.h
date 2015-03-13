//
//  CNShareViewController.h
//  YaoPao
//
//  Created by zc on 14-8-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "RunClass.h"

@interface CNShareViewController : UIViewController<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (strong, nonatomic) NSString* dataSource;
@property (strong, nonatomic) RunClass* oneRun;
- (IBAction)button_jump_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (strong, nonatomic) IBOutlet UILabel *label_distance;
@property (strong, nonatomic) IBOutlet UILabel *label_feel;
@property (strong, nonatomic) IBOutlet UILabel *label_time;
@property (strong, nonatomic) IBOutlet UILabel *label_pspeed;
@property (strong, nonatomic) IBOutlet UILabel *label_hspeed;
- (IBAction)button_share_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *view_map_container;
@property (strong, nonatomic) IBOutlet UIImageView *image_mood;
@property (strong, nonatomic) IBOutlet UIImageView *image_way;
@property (strong, nonatomic) IBOutlet UIButton *button_jump;
@property (strong, nonatomic) IBOutlet UIButton *button_share;
@property (strong, nonatomic) IBOutlet UIView *view_shareview;

@end

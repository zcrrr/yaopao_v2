//
//  CNShareNewViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/7/31.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "CNImageEditerViewController.h"
@class CNCustomButton;
@class OnlyTrackView4share;
@class RunClass;
@interface CNShareNewViewController : UIViewController<MAMapViewDelegate,UIScrollViewDelegate,EditImageDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (strong, nonatomic) RunClass* oneRun;
@property (assign, nonatomic) int currentpage;
@property (strong, nonatomic) NSString* shareText;
@property (strong, nonatomic) NSString* from;

@property (weak, nonatomic) IBOutlet CNCustomButton *button_jump_or_back;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UITextField *textfield_remark;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_feel;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_way;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *view_mapContainer;
@property (weak, nonatomic) IBOutlet OnlyTrackView4share *view_onlytrack;
@property (weak, nonatomic) IBOutlet UILabel *label_dis1;
@property (weak, nonatomic) IBOutlet UILabel *label_date1;
@property (weak, nonatomic) IBOutlet UILabel *label_time1;
@property (weak, nonatomic) IBOutlet UILabel *label_dis2;
@property (weak, nonatomic) IBOutlet UILabel *label_date2;
@property (weak, nonatomic) IBOutlet UILabel *label_time2;
@property (weak, nonatomic) IBOutlet UIButton *button_scrollview;
@property (weak, nonatomic) IBOutlet UILabel *label_during;
@property (weak, nonatomic) IBOutlet UILabel *label_pace;
@property (weak, nonatomic) IBOutlet UILabel *label_score;
@property (weak, nonatomic) IBOutlet UILabel *label_page;
@property (weak, nonatomic) IBOutlet UIButton *button_left;
@property (weak, nonatomic) IBOutlet UIButton *button_right;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_share;
@property (weak, nonatomic) IBOutlet UIView *view_water;

@end

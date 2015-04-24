//
//  CNRecordDetailViewController.h
//  YaoPao
//
//  Created by zc on 14-8-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunClass.h"
#import <MAMapKit/MAMapKit.h>
@class CNCustomButton;

@interface CNRecordDetailViewController : UIViewController<MAMapViewDelegate,UITextFieldDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (assign, nonatomic) int currentpage;
@property (strong ,nonatomic) RunClass* oneRun;
@property (strong, nonatomic) IBOutlet UILabel *label_title;
- (IBAction)button_back_clicked:(id)sender;
- (IBAction)button_share_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIView *view_map_container;
@property (strong, nonatomic) IBOutlet UIImageView *imageview_type;
@property (strong, nonatomic) IBOutlet UILabel *label_date;
@property (strong, nonatomic) IBOutlet UILabel *label_date1;
@property (strong, nonatomic) IBOutlet UILabel *label_date2;
@property (strong, nonatomic) IBOutlet UILabel *label_date3;
@property (strong, nonatomic) IBOutlet UILabel *label_date4;
@property (strong, nonatomic) IBOutlet UITextField *textfield_remark;

@property (strong, nonatomic) IBOutlet UILabel *label_during;
@property (strong, nonatomic) IBOutlet UILabel *label_pspeed;
@property (strong, nonatomic) IBOutlet UILabel *label_aver_speed;
@property (strong, nonatomic) IBOutlet UIImageView *image_mood;
@property (strong, nonatomic) IBOutlet UIImageView *image_way;
@property (strong, nonatomic) IBOutlet UILabel *label_feel;
- (IBAction)button_gotoMap_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet CNCustomButton *button_back;
@property (strong, nonatomic) IBOutlet CNCustomButton *button_share;
@property (weak, nonatomic) IBOutlet UIButton *button_left;
@property (weak, nonatomic) IBOutlet UIButton *button_right;
- (IBAction)button_left_clicked:(id)sender;
- (IBAction)button_right_clicked:(id)sender;
- (IBAction)button_imageEdit_clicked:(id)sender;

@end

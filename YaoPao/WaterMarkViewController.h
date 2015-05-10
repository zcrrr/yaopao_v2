//
//  WaterMarkViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/3/26.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
@class OnlyTrackView;
@protocol addWaternDelegate <NSObject>
//登录接口成功或者失败的协议，如果失败了会有原因mes
- (void)addWaterDidSuccess:(UIImage*)image;
@end

@interface WaterMarkViewController : UIViewController<UIScrollViewDelegate>
@property (assign, nonatomic) int whiteOrBlack;
@property (assign, nonatomic) int currentPage;
@property (nonatomic, strong) MAMapView *mapView;
@property (strong, nonatomic) UIImage* image_datasource;
@property (nonatomic, strong) id<addWaternDelegate> delegate_addWater;
@property (weak, nonatomic) IBOutlet UIView *view_italic;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *button_whiteBlackConvert;
@property (weak, nonatomic) IBOutlet UIView *view_water1;
@property (weak, nonatomic) IBOutlet UIView *view_water3;
@property (weak, nonatomic) IBOutlet UIView *view_water4;
@property (weak, nonatomic) IBOutlet UIView *view_hidemap;
@property (weak, nonatomic) IBOutlet OnlyTrackView *view_onlyTrack;
@property (weak, nonatomic) IBOutlet UILabel *label_water1_km;
@property (weak, nonatomic) IBOutlet UILabel *label_water2_km;
@property (weak, nonatomic) IBOutlet UILabel *label_water2_speed;
@property (weak, nonatomic) IBOutlet UILabel *label_water2_time;
@property (weak, nonatomic) IBOutlet UILabel *label_water3_km;
@property (weak, nonatomic) IBOutlet UILabel *label_water3_date;
@property (weak, nonatomic) IBOutlet UILabel *label_water3_time;
@property (weak, nonatomic) IBOutlet UILabel *label_water4_km;
@property (weak, nonatomic) IBOutlet UIView *view_water3_line;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_water3_weather;
@property (weak, nonatomic) IBOutlet UIView *view_savaImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_water5;
@property (weak, nonatomic) IBOutlet UILabel *label_water5_km;



@property (weak, nonatomic) IBOutlet UIImageView *imageview_yaopaoyiqipao;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_logo_cn;


- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_bottom;

@end

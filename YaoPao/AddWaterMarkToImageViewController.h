//
//  AddWaterMarkToImageViewController.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/28.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMScrollView.h"
#import "BGImageView.h"
#import "WMGroupScrollView.h"
#import "WMGroupInfo.h"

@protocol addWaterDelegate <NSObject>
- (void)addWaterDidSuccess:(UIImage*)image;
- (void)addWaterDidFailed:(NSString*)desc;
@end

@interface AddWaterMarkToImageViewController : UIViewController<WMScrollViewDataSource,WMScrollViewDelegate,WMGroupScrollViewDataSource,WMGroupScrollViewDelegate>

/*------需要传入的参数-------*/
@property (strong, nonatomic) NSString *distanceText;        //距离信息
@property (strong, nonatomic) NSString *secondPerKMText;     //每千米耗时信息
@property (strong, nonatomic) NSString *duringText;          //全程耗时信息
@property (strong, nonatomic) NSDate *date;            //日期信息
@property (strong, nonatomic) NSMutableArray *pointArray;    //轨迹点信息
@property (strong, nonatomic) UIImage  *weatherImage_w;    //天气图片（白）
@property (strong, nonatomic) UIImage  *weatherImage_b;    //天气图片（黑）
/*-------------------------*/


@property (strong, nonatomic) UIImage *workImage;               //工作区图片，用来添加水印
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *wmGroupArray;     //存储水印组信息
@property (assign, nonatomic) NSInteger currentGroup;
@property (assign, nonatomic) id<addWaterDelegate> AddWMDelegate;
@property (assign, nonatomic, setter=isWhite:) BOOL white;

@property (weak, nonatomic) IBOutlet BGImageView *ImageView;
@property (weak, nonatomic) IBOutlet WMScrollView *scrollView;
@property (weak, nonatomic) IBOutlet WMGroupScrollView *groupScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

- (IBAction)saveBtnClick:(id)sender;
- (IBAction)backBtnClick:(id)sender;

@end

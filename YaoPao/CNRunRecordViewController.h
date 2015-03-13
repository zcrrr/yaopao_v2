//
//  CNRunRecordViewController.h
//  YaoPao
//
//  Created by zc on 14-8-8.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "GADBannerView.h"


@interface CNRunRecordViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (assign, nonatomic) int page;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSString* from;
@property (strong, nonatomic) NSMutableArray* recordList;
@property (assign, nonatomic) int pageNumber;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UILabel *label_dis;
@property (strong, nonatomic) IBOutlet UILabel *label_count;
@property (strong, nonatomic) IBOutlet UILabel *label_total_time;
- (IBAction)button_cloud_clicked:(id)sender;
- (IBAction)button_back_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *view_dis;
@property (strong, nonatomic) IBOutlet UIImageView *image_dis1;
@property (strong, nonatomic) IBOutlet UIImageView *image_dis2;
@property (strong, nonatomic) IBOutlet UIImageView *image_dis3;
@property (strong, nonatomic) IBOutlet UIImageView *image_dis4;
@property (strong, nonatomic) IBOutlet UIImageView *image_dis5;
@property (strong, nonatomic) IBOutlet UIImageView *image_dis6;
@property (strong, nonatomic) IBOutlet UIView *view_count;
@property (strong, nonatomic) IBOutlet UIImageView *image_count1;
@property (strong, nonatomic) IBOutlet UIImageView *image_count2;
@property (strong, nonatomic) IBOutlet UIImageView *image_count3;
@property (strong, nonatomic) IBOutlet UIView *view_time;
@property (strong, nonatomic) IBOutlet UIImageView *image_time1;
@property (strong, nonatomic) IBOutlet UIImageView *image_time2;
@property (strong, nonatomic) IBOutlet UIImageView *image_time3;
@property (strong, nonatomic) IBOutlet UIImageView *image_time4;
@property (strong, nonatomic) IBOutlet UIImageView *image_time5;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UIButton *button_cloud;
@property (strong, nonatomic) IBOutlet UIImageView *image_time6;
@property (assign, nonatomic) CGRect frame_dis;
@property (assign, nonatomic) CGRect frame_count;
@property (assign, nonatomic) CGRect frame_time;
@end

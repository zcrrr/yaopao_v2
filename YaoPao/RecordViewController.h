//
//  RecordViewController.h
//  AssistUI
//
//  Created by 张驰 on 15/3/10.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstLevelViewController.h"

@interface RecordViewController : FirstLevelViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
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
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UIButton *button_cloud;

@end

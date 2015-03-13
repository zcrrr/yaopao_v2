//
//  CNFinishTeamMatchViewController.h
//  YaoPao
//
//  Created by zc on 14-10-2.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
@class CNDistanceImageView;

@interface CNFinishTeamMatchViewController : UIViewController<UIScrollViewDelegate,listPersonalDelegate>
@property (strong, nonatomic) NSMutableArray* imageviewList;
@property (strong, nonatomic) NSMutableArray* urlList;
@property (strong, nonatomic) IBOutlet UILabel *label_tname;
@property (strong, nonatomic) IBOutlet UILabel *label_tname2;
@property (strong, nonatomic) IBOutlet UIScrollView *view_list;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) IBOutlet UIButton *button_ok;
@property (strong, nonatomic) IBOutlet UIButton *button_share;

@property (strong, nonatomic) CNDistanceImageView* div;
@property (strong, nonatomic) UIImageView* image_km;
- (IBAction)button_ok_clicked:(id)sender;
- (IBAction)button_share_clicked:(id)sender;

@end

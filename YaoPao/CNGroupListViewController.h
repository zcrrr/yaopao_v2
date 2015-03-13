//
//  CNGroupListViewController.h
//  YaoPao
//
//  Created by zc on 14-9-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
@class CNDistanceImageView;

@interface CNGroupListViewController : UIViewController<listPersonalDelegate,matchListInfoDelegate>
@property (strong, nonatomic) NSTimer* timer_personal;
@property (strong, nonatomic) NSTimer* timer_km;
@property (assign, nonatomic) int tabIndex;
@property (strong, nonatomic) NSMutableArray* imageviewList;
@property (strong, nonatomic) NSMutableArray* urlList;
- (IBAction)button_back_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UILabel *label_tname;
@property (strong, nonatomic) IBOutlet UIButton *button_personal;
@property (strong, nonatomic) IBOutlet UIButton *button_km;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) CNDistanceImageView* big_div;
@property (strong, nonatomic) UIImageView* image_km;
- (IBAction)button_tab_clicked:(id)sender;

@end

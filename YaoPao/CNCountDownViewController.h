//
//  CNCountDownViewController.h
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNCountDownViewController : UIViewController
@property (strong, nonatomic) NSTimer* timer_countdown;
@property (assign, nonatomic) int count;
- (IBAction)view_touched:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *image1;
@property (strong, nonatomic) IBOutlet UIImageView *image2;
@property (strong, nonatomic) IBOutlet UIView *view_num;
- (IBAction)button_clicked:(id)sender;

@end

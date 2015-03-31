//
//  CNRunTypeViewController.h
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNRunTypeViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary* runSettingDic;
@property (assign, nonatomic) int selectedIndex;
@property (strong, nonatomic) IBOutlet UIImageView *image_choose1;
@property (strong, nonatomic) IBOutlet UIImageView *image_choose2;
@property (strong, nonatomic) IBOutlet UIImageView *image_choose3;
- (IBAction)button_choose_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@property (weak, nonatomic) IBOutlet UIView *view_line1;
@property (weak, nonatomic) IBOutlet UIView *view_line2;
@property (weak, nonatomic) IBOutlet UIView *view_line3;


- (IBAction)button_back_clicked:(id)sender;

@end

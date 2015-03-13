//
//  CNStartRunViewController.h
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNStartRunViewController : UIViewController


@property (strong, nonatomic) NSMutableDictionary* runSettingDic;

@property (assign, nonatomic) int howToMove;
@property (assign, nonatomic) int targetType;
@property (assign, nonatomic) int targetValue;

@property (strong, nonatomic) IBOutlet UILabel *label_target;
@property (strong, nonatomic) IBOutlet UILabel *label_type;
@property (strong, nonatomic) IBOutlet UISwitch *switch_countdown;
@property (strong, nonatomic) IBOutlet UISwitch *switch_voice;
@property (strong, nonatomic) IBOutlet UIImageView *image_target;
@property (strong, nonatomic) IBOutlet UIImageView *image_type;

@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UIView *view_target;
@property (strong, nonatomic) IBOutlet UIView *view_type;
@property (strong, nonatomic) IBOutlet UIView *view_countdown;
@property (strong, nonatomic) IBOutlet UIView *view_voice;
@property (strong, nonatomic) IBOutlet UIButton *button_target;
@property (strong, nonatomic) IBOutlet UIButton *button_type;



- (IBAction)button_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_start;

@end

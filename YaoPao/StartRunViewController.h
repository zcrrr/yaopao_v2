//
//  StartRunViewController.h
//  AssistUI
//
//  Created by 张驰 on 15/3/13.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartRunViewController : UIViewController
@property (assign, nonatomic) int howToMove;
@property (assign, nonatomic) int targetType;
@property (assign, nonatomic) int targetValue;
@property (weak, nonatomic) IBOutlet UILabel *label_target;
@property (weak, nonatomic) IBOutlet UILabel *label_type;
@property (weak, nonatomic) IBOutlet UIView *view_target;
@property (weak, nonatomic) IBOutlet UIView *view_type;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_target;
@property (weak, nonatomic) IBOutlet UIButton *button_target;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_type;
@property (weak, nonatomic) IBOutlet UIButton *button_type;
@property (weak, nonatomic) IBOutlet UISwitch *switch_countdown;
@property (weak, nonatomic) IBOutlet UISwitch *switch_voice;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_line1;
@property (weak, nonatomic) IBOutlet UIView *view_line2;
@property (weak, nonatomic) IBOutlet UIView *view_line3;
@property (weak, nonatomic) IBOutlet UIView *view_line4;
@property (weak, nonatomic) IBOutlet UIView *view_line5;
@property (weak, nonatomic) IBOutlet UIView *view_line6;

@end

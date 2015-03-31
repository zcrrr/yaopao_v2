//
//  CNRunTargetViewController.h
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNRunTargetViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) NSMutableDictionary* runSettingDic;
@property (assign, nonatomic) int selectedIndex;
@property (assign, nonatomic) int distance;
@property (assign, nonatomic) int time;

@property (strong, nonatomic) NSMutableArray* dis_array;
@property (strong, nonatomic) NSMutableArray* time_array;

@property (strong, nonatomic) IBOutlet UIButton *button_choose1;
@property (strong, nonatomic) IBOutlet UIButton *button_choose2;
@property (strong, nonatomic) IBOutlet UIButton *button_choose3;
@property (strong, nonatomic) IBOutlet UIImageView *image_choose1;
@property (strong, nonatomic) IBOutlet UIImageView *image_choose2;
@property (strong, nonatomic) IBOutlet UIImageView *image_choose3;
@property (strong, nonatomic) IBOutlet UITextField *textfield_choose2;
@property (strong, nonatomic) IBOutlet UITextField *textfield_choose3;
@property (strong, nonatomic) IBOutlet UIPickerView *pickview_dis;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar_dis;
- (IBAction)dis_selected:(id)sender;
@property (strong, nonatomic) IBOutlet UIPickerView *pickview_time;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar_time;
- (IBAction)time_selected:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (weak, nonatomic) IBOutlet UIView *view_line1;
@property (weak, nonatomic) IBOutlet UIView *view_line2;
@property (weak, nonatomic) IBOutlet UIView *view_line3;
@property (weak, nonatomic) IBOutlet UIView *view_line4;




- (IBAction)button_back_clicked:(id)sender;
- (IBAction)button_choose_target:(id)sender;
- (IBAction)view_touched:(id)sender;

@end

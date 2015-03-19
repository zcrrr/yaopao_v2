//
//  FeelingViewController.h
//  AssistUI
//
//  Created by 张驰 on 15/3/18.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNCustomButton;
@class CNOverlayViewController;
@interface FeelingViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate>
@property (assign, nonatomic) int currentpage;
@property (strong, nonatomic) UIImagePickerController* cameraPicker;
@property (strong, nonatomic) CNOverlayViewController* overlayVC;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet CNCustomButton *button_delete;
@property (weak, nonatomic) IBOutlet CNCustomButton *button_save;
@property (weak, nonatomic) IBOutlet UIButton *button_left;
@property (weak, nonatomic) IBOutlet UIButton *button_right;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UILabel *label_whichpage;
@property (weak, nonatomic) IBOutlet UIButton *button_mood1;
@property (weak, nonatomic) IBOutlet UIButton *button_mood2;
@property (weak, nonatomic) IBOutlet UIButton *button_mood3;
@property (weak, nonatomic) IBOutlet UIButton *button_mood4;
@property (weak, nonatomic) IBOutlet UIButton *button_mood5;
@property (weak, nonatomic) IBOutlet UIButton *button_way1;
@property (weak, nonatomic) IBOutlet UIButton *button_way2;
@property (weak, nonatomic) IBOutlet UIButton *button_way3;
@property (weak, nonatomic) IBOutlet UIButton *button_way4;
@property (weak, nonatomic) IBOutlet UIButton *button_way5;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
- (IBAction)button_clicked:(id)sender;
- (IBAction)button_mood_clicked:(id)sender;
- (IBAction)button_way_clicked:(id)sender;

@end

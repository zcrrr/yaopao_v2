//
//  CNUserinfoViewController.h
//  YaoPao
//
//  Created by zc on 14-7-24.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
@class CNCustomButton;


@interface CNUserinfoViewController : UIViewController<UITextFieldDelegate,updateUserinfoDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource,updateAvatarDelegate>

@property (strong, nonatomic) NSString* selectedSex;
@property (strong, nonatomic) NSString* from;
@property (strong, nonatomic) NSMutableArray* height_array;
@property (strong, nonatomic) NSMutableArray* weight_array1;
@property (strong, nonatomic) NSMutableArray* weight_array2;


@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryView;

@property (weak, nonatomic) IBOutlet UIButton *button_avatar;
@property (weak, nonatomic) IBOutlet UIButton *button_back;

@property (strong, nonatomic) IBOutlet CNCustomButton *button_save;
@property (strong, nonatomic) IBOutlet UITextField *textfield_username;
@property (strong, nonatomic) IBOutlet UIButton *button_man;
@property (strong, nonatomic) IBOutlet UIButton *button_women;
@property (strong, nonatomic) IBOutlet UITextField *textfield_realname;
@property (strong, nonatomic) IBOutlet UITextField *textfield_phone;
@property (strong, nonatomic) IBOutlet UITextField *textfield_birthday;
@property (strong, nonatomic) IBOutlet UITextField *textfield_height;
@property (strong, nonatomic) IBOutlet UITextField *textfield_weight;
@property (strong, nonatomic) IBOutlet UITextField *textfield_des;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerview_weight;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerview_height;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar_weight;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar_height;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
- (IBAction)button_weight_ok:(id)sender;
- (IBAction)button_height_ok:(id)sender;
- (IBAction)button_edit_nickname:(id)sender;

- (IBAction)button_save_clicked:(id)sender;
- (IBAction)button_back_clicked:(id)sender;

- (IBAction)button_sex_clicked:(id)sender;
- (IBAction)dataChanged:(id)sender;
- (IBAction)doneEditing:(id)sender;
- (IBAction)button_avatar_clicked:(id)sender;


@end

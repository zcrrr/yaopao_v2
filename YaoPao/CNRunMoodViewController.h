//
//  CNRunMoodViewController.h
//  YaoPao
//
//  Created by zc on 14-8-5.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNRunMoodViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
- (IBAction)button_delete_clicked:(id)sender;
- (IBAction)button_photo_clicked:(id)sender;
- (IBAction)button_save_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageview_photo;
- (IBAction)button_mood_clicked:(id)sender;
- (IBAction)button_track_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *textfield_feel;
@property (strong, nonatomic) IBOutlet UIButton *button_mood1;
@property (strong, nonatomic) IBOutlet UIButton *button_mood2;
@property (strong, nonatomic) IBOutlet UIButton *button_mood3;
@property (strong, nonatomic) IBOutlet UIButton *button_mood4;
@property (strong, nonatomic) IBOutlet UIButton *button_mood5;
@property (strong, nonatomic) IBOutlet UIButton *button_way1;
@property (strong, nonatomic) IBOutlet UIButton *button_way2;
@property (strong, nonatomic) IBOutlet UIButton *button_way3;
@property (strong, nonatomic) IBOutlet UIButton *button_way4;
@property (strong, nonatomic) IBOutlet UIButton *button_way5;
@property (strong, nonatomic) UIImage* image_small;
@property (strong, nonatomic) IBOutlet UILabel *label_title;
@property (assign, nonatomic) BOOL hasPhoto;
@property (strong, nonatomic) IBOutlet UIButton *button_delete;
@property (strong, nonatomic) IBOutlet UIButton *button_save;
@property (strong, nonatomic) IBOutlet UIButton *button_takephoto;

@end

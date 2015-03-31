//
//  CNForgetPwdViewController.h
//  YaoPao
//
//  Created by zc on 14-7-28.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"
#import "SectionsViewController.h"

@interface CNForgetPwdViewController : UIViewController<UITextFieldDelegate,findPwdDelegate,SecondViewControllerDelegate>
@property (assign, nonatomic) BOOL isVerify;
@property (strong, nonatomic) NSString* areaCode;
@property (strong, nonatomic) NSTimer* timer;
@property (assign, nonatomic) int count;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UIButton *button_vcode;
@property (strong, nonatomic) IBOutlet UIButton *button_ok;
@property (strong, nonatomic) IBOutlet UITextField *textfield_phone;
@property (strong, nonatomic) IBOutlet UITextField *textfield_pwd;
@property (strong, nonatomic) IBOutlet UITextField *textfield_vcode;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) IBOutlet UILabel *label_country;
@property (strong, nonatomic) IBOutlet UILabel *label_countryandarea;
@property (strong, nonatomic) IBOutlet UIButton *button_country;
@property (weak, nonatomic) IBOutlet UIView *view_country;

- (IBAction)button_clicked:(id)sender;
- (IBAction)view_touched:(id)sender;
- (IBAction)button_country_clicked:(id)sender;

@end

//
//  CNVCodeViewController.m
//  YaoPao
//
//  Created by zc on 14-12-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNVCodeViewController.h"
#import "SMS_SDK/SMS_SDK.h"
#import "SectionsViewController.h"
#import "CNNetworkHandler.h"

@interface CNVCodeViewController ()

@end

@implementation CNVCodeViewController
@synthesize isVerify;
@synthesize timer;
@synthesize count;
@synthesize areaCode;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textfield_vcode.delegate = self;
    self.textfield_phone.delegate = self;
    self.areaCode = @"86";
    [self.button_country addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
}
- (void)changeViewColor:(id)sender{
    self.view_country.backgroundColor = [UIColor lightGrayColor];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if(kApp.vcodeSecond == 0){
        [self.button_vcode setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.button_vcode.userInteractionEnabled = YES;
    }else{
        [self.button_vcode setTitle:[NSString stringWithFormat:@"%i",kApp.vcodeSecond] forState:UIControlStateNormal];
        self.button_vcode.userInteractionEnabled = NO;
    }
    [kApp addObserver:self forKeyPath:@"vcodeSecond" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [kApp removeObserver:self forKeyPath:@"vcodeSecond"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            [self.navigationController popViewControllerAnimated:YES];
            //logout
            kApp.isLogin = 0;
            kApp.userInfoDic = nil;
            kApp.imageData = nil;
            NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
            [CNPersistenceHandler DeleteSingleFile:filePath];
            break;
        }
        case 1:
        {
            if ([self checkPhoneNO]) {
                NSLog(@"获取验证码");
                [self getVCode];
            }
            break;
        }
        case 2:
        {
            if([self checkPhoneNO]){
                if ([self checkVcode]) {
                    if(isVerify){//验证过
                        //自动登录
                        NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
                        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
                        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                        [params setObject:[userInfo objectForKey:@"uid"] forKey:@"uid"];
                        [kApp.networkHandler doRequest_autoLogin:params];
                        kApp.isLogin = 2;
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{//未验证
                        [self verifyVCode];
                    }
                    
                }
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)view_touched:(id)sender {
    [self.textfield_phone resignFirstResponder];
    [self.textfield_vcode resignFirstResponder];
    [self resetViewFrame];
}
- (void)countdown{
    kApp.vcodeSecond -- ;
    if(kApp.vcodeSecond == 0){
        [kApp.vcodeTimer invalidate];
    }
}
- (void)getVCode{
    NSLog(@"code is %@",self.areaCode);
    [SMS_SDK getVerifyCodeByPhoneNumber:self.textfield_phone.text AndZone:self.areaCode result:^(enum SMS_GetVerifyCodeResponseState state) {
        if (1==state) {
            NSLog(@"block 获取验证码成功");
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:@"获取验证码成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            self.button_vcode.userInteractionEnabled = NO;
            kApp.vcodeSecond = 60;
            kApp.vcodeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        }
        else if(0==state)
        {
            NSLog(@"block 获取验证码失败");
            NSString* str=[NSString stringWithFormat:@"验证码发送失败 请稍后重试"];
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"发送失败" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        else if (SMS_ResponseStateMaxVerifyCode==state)
        {
            NSString* str=[NSString stringWithFormat:@"请求验证码超上限 请稍后重试"];
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"超过上限" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(SMS_ResponseStateGetVerifyCodeTooOften==state)
        {
            NSString* str=[NSString stringWithFormat:@"客户端请求发送短信验证过于频繁"];
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (void)verifyVCode{
    [SMS_SDK commitVerifyCode:self.textfield_vcode.text result:^(enum SMS_ResponseState state) {
        if (1==state) {
            NSLog(@"block 验证成功");
            self.isVerify = YES;
            //自动登录
            NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            [params setObject:[userInfo objectForKey:@"uid"] forKey:@"uid"];
            [kApp.networkHandler doRequest_autoLogin:params];
            kApp.isLogin = 2;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if(0==state)
        {
            NSLog(@"block 验证失败");
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:@"验证码验证失败" delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (IBAction)button_country_clicked:(id)sender {
    self.view_country.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array) {
        if (1==state)
        {
            NSLog(@"block 获取区号成功");
            //区号数据
            NSMutableArray* areaArray=[NSMutableArray arrayWithArray:array];
            NSLog(@"弹出国家和地区列表用于选择区号");
            SectionsViewController* country2=[[SectionsViewController alloc] init];
            country2.delegate=self;
            [country2 setAreaArray:areaArray];
            [self presentViewController:country2 animated:YES completion:^{
                ;
            }];
        }
        else if (0==state)
        {
            NSLog(@"block 获取区号失败");
        }
    }];
}
#pragma mark - SecondViewControllerDelegate的方法
- (void)setSecondData:(CountryAndAreaCode *)data {
    NSLog(@"从Second传过来的数据：%@,%@", data.areaCode,data.countryName);
    self.areaCode = data.areaCode;
    self.label_country.text = [NSString stringWithFormat:@"%@",data.countryName];
}
- (BOOL)checkPhoneNO{
    NSString* string_alert = @"";
    BOOL result = NO;
    if (self.textfield_phone.text != nil && ![self.textfield_phone.text isEqualToString:@""])
    {
//        if ([self.textfield_phone.text length] != 11)
//        {
//            string_alert = @"手机号码不符合规范，应为11位的数字";
//        }
//        else
//        {
            for (int i = 0; i < [self.textfield_phone.text length]; i++)
            {
                char c = [self.textfield_phone.text characterAtIndex:i];
                if (c <'0' || c >'9')
                {
                    string_alert = @"手机号码不符合规范，应全部为数字";
                    break;
                }
            }
//        }
    }else{
        string_alert = @"手机号不能为空";
    }
    if (![string_alert isEqualToString:@""])
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:string_alert delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        result = NO;
    }else{
        result = YES;
    }
    return result;
}

- (BOOL)checkVcode{
    NSString* string_alert = @"";
    BOOL result = NO;
    if (self.textfield_vcode.text != nil && ![self.textfield_vcode.text isEqualToString:@""])
    {
        if ([self.textfield_vcode.text length] != 4)
        {
            string_alert = @"验证码不符合规范，应为4位的数字";
        }
        else
        {
            for (int i = 0; i < [self.textfield_vcode.text length]; i++)
            {
                char c = [self.textfield_vcode.text characterAtIndex:i];
                if (c <'0' || c >'9')
                {
                    string_alert = @"验证码不符合规范，应为4位的数字";
                    break;
                }
            }
        }
    }else{
        string_alert = @"验证码不能为空";
    }
    if (![string_alert isEqualToString:@""])
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:string_alert delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alert show];
        result = NO;
    }else{
        result = YES;
    }
    return result;
}
#pragma mark- textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self resetViewFrame];
    return YES;
}
- (void)keyboardWillShow:(NSNotification *)noti
{
    //键盘输入的界面调整
    //键盘的高度
    float height = 216.0;
    CGRect frame = self.view.frame;
    frame.size = CGSizeMake(frame.size.width, frame.size.height - height);
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:frame];
    [UIView commitAnimations];
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint point = [textField.superview convertPoint:textField.frame.origin toView:nil];
    int offset = point.y + 80 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}
- (void)resetViewFrame{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(kApp.vcodeSecond == 0){
        [self.button_vcode setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.button_vcode.userInteractionEnabled = YES;
    }else{
        [self.button_vcode setTitle:[NSString stringWithFormat:@"%i",kApp.vcodeSecond] forState:UIControlStateNormal];
        self.button_vcode.userInteractionEnabled = NO;
    }
}
@end

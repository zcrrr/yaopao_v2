//
//  CNLoginPhoneViewController.m
//  YaoPao
//
//  Created by zc on 14-7-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNLoginPhoneViewController.h"
#import "CNNetworkHandler.h"
#import "CNForgetPwdViewController.h"
#import "CNUserinfoViewController.h"
#import "CNServiceViewController.h"
#import "Toast+UIView.h"
#import "CNRegisterPhoneViewController.h"
#import "SMS_SDK/SMS_SDK.h"
#import "SectionsViewController.h"
#import "CNCloudRecord.h"
#import "ColorValue.h"
#import "CNCustomButton.h"
#import "EMSDKFull.h"

@interface CNLoginPhoneViewController ()

@end

@implementation CNLoginPhoneViewController
@synthesize agree;
@synthesize timer;
@synthesize count;
@synthesize isVerify;
@synthesize areaCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.agree = 1;
    self.textfield_pwd.delegate = self;
    self.textfield_phone.delegate = self;
    self.textfield_vcode.delegate = self;
    [self.button_goRegister fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    [self.button_country addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    self.areaCode = @"86";
}
- (void)changeViewColor:(id)sender{
    self.view_country.backgroundColor = [UIColor lightGrayColor];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
        case 0:{
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            //登录
            [self resignAllText];
            if ([self checkPhoneNO]) {
                if ([self checkPwd]) {
                    if(self.agree == 1){
                        //先验证验证码
                        //测试代码
                        self.isVerify = YES;
                        if(self.isVerify){//已经验证
                            //登录
                            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                            [params setObject:self.textfield_phone.text forKey:@"phone"];
                            [params setObject:self.textfield_pwd.text forKey:@"passwd"];
                            kApp.networkHandler.delegate_loginPhone = self;
                            [kApp.networkHandler doRequest_loginPhone:params];
                            [self displayLoading];
                        }else{//未验证
                            [self verifyVCode];
                        }
                    }else{
                        [kApp.window makeToast:@"您需要同意要跑服务协议才能进行后续操作"];
                    }
                }
            }
            break;
        }
        case 2:
        {
            CNForgetPwdViewController* forgetPwdVC = [[CNForgetPwdViewController alloc]init];
            [self.navigationController pushViewController:forgetPwdVC animated:YES];
            break;
        }
        case 3:
        {
            CNServiceViewController* serviceVC = [[CNServiceViewController alloc]init];
            [self.navigationController pushViewController:serviceVC animated:YES];
            break;
        }
        case 4:
        {
            CNRegisterPhoneViewController* registerVC = [[CNRegisterPhoneViewController alloc]init];
            [self.navigationController pushViewController:registerVC animated:YES];
            break;
        }
        case 5:
        {
            if ([self checkPhoneNO]) {
                NSLog(@"获取验证码");
                [self getVCode];
                [self displayLoading];
            }
            break;
        }
        default:
            break;
    }
}
- (void)getVCode{
    NSLog(@"code is %@",self.areaCode);
    [SMS_SDK getVerifyCodeByPhoneNumber:self.textfield_phone.text AndZone:self.areaCode result:^(enum SMS_GetVerifyCodeResponseState state) {
        [self hideLoading];
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
- (void)countdown{
    kApp.vcodeSecond -- ;
    if(kApp.vcodeSecond == 0){
        [kApp.vcodeTimer invalidate];
    }
}
- (void)verifyVCode{
    [SMS_SDK commitVerifyCode:self.textfield_vcode.text result:^(enum SMS_ResponseState state) {
        if (1==state) {
            NSLog(@"block 验证成功");
            self.isVerify = YES;
            //登录
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            [params setObject:self.textfield_phone.text forKey:@"phone"];
            [params setObject:self.textfield_pwd.text forKey:@"passwd"];
            kApp.networkHandler.delegate_loginPhone = self;
            [kApp.networkHandler doRequest_loginPhone:params];
            [self displayLoading];
            
        }
        else if(0==state)
        {
            NSLog(@"block 验证失败");
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:@"验证码验证失败" delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (IBAction)button_checkbox_clicked:(id)sender {
    if(self.agree == 0){
        self.agree = 1;
        [self.button_checkbox setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    }else{
        self.agree = 0;
        [self.button_checkbox setBackgroundImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)view_touched:(id)sender {
    [self resignAllText];
}
- (void)resignAllText{
    [self.textfield_phone resignFirstResponder];
    [self.textfield_pwd resignFirstResponder];
    [self.textfield_vcode resignFirstResponder];
    [self resetViewFrame];
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
- (BOOL)checkPwd{
    NSString* string_alert = @"";
    BOOL result = NO;
    if (self.textfield_pwd.text != nil && ![self.textfield_pwd.text isEqualToString:@""])
    {
        
        for (int i = 0; i < [self.textfield_pwd.text length]; i++)
        {
            char c = [self.textfield_pwd.text characterAtIndex:i];
            if (('a' <= c && 'z' >= c) || ('A' <= c && 'Z' >= c) || ('0' <= c && '9' >= c))
            {
                
            }
            else
            {
                string_alert = @"密码不符合规范，应为6-16位字母、数字、符号组成，区分大小写。";
                break;
            }
        }
        
        if ([self.textfield_pwd.text length] < 6 || [self.textfield_pwd.text length] > 16)
        {
            string_alert = @"密码不符合规范，应为6-16位字母、数字、符号组成，区分大小写。";
        }
    }else{
        string_alert = @"密码不能为空";
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
- (void)loginPhoneDidSuccess:(NSDictionary *)resultDic{
    //测试账号：18611101410
//    if([self.textfield_phone.text isEqualToString:@"18611101410"]){
//        [CNAppDelegate saveRun];
//    }
    [self hideLoading];
    //登录、注册之后的一系列操作
    [self.navigationController popToRootViewControllerAnimated:YES];
    //向mob提交用户信息
    [kApp needRegisterMobUser];
    NSString* phoneNO = [kApp.userInfoDic objectForKey:@"phone"];
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:phoneNO password:phoneNO completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error && loginInfo) {
            NSLog(@"登录环信成功!!");
            kApp.isLoginHX = 1;
            [CNAppDelegate howManyMessageToRead];
        }
    } onQueue:nil];
    
    [CNCloudRecord ClearRecordAfterUserLogin];
    //用户登录之后先同步
    [CNAppDelegate popupWarningCloud:NO];
    
//    CNUserinfoViewController* userInfoVC = [[CNUserinfoViewController alloc]init];
//    [self.navigationController pushViewController:userInfoVC animated:YES];
}
- (void)loginPhoneDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
}
#pragma mark - SecondViewControllerDelegate的方法
- (void)setSecondData:(CountryAndAreaCode *)data {
    NSLog(@"从Second传过来的数据：%@,%@", data.areaCode,data.countryName);
    self.areaCode = data.areaCode;
    self.label_country.text = [NSString stringWithFormat:@"%@",data.countryName];
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

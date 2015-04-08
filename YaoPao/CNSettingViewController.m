//
//  CNSettingViewController.m
//  YaoPao
//
//  Created by zc on 14-8-29.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNSettingViewController.h"
#import "CNAboutViewController.h"
#import "CNRegisterPhoneViewController.h"
#import "CNUserinfoViewController.h"
#import "CNADViewController.h"
#import "CNServiceViewController.h"
#import "CNLoginPhoneViewController.h"
#import "AboutViewController.h"

@interface CNSettingViewController ()

@end

@implementation CNSettingViewController
@synthesize bannerView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)changeLineOne:(UIView*)line{
    CGRect frame_new = line.frame;
    frame_new.size = CGSizeMake(frame_new.size.width, 0.5);
    line.frame = frame_new;
}
- (void)viewDidLoad
{
    self.selectIndex = 3;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self changeLineOne:self.view_line1];
    [self changeLineOne:self.view_line2];
    [self changeLineOne:self.view_line3];
    [self changeLineOne:self.view_line4];
    [self.button_about addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    [self.button_feedback addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    [self.button_personal addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    [self.button_service addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    [self.button_system addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    [self.button_update addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    
    NSArray* array = [kApp.showad componentsSeparatedByString:@","];
    //广告：
    if([array count] == 2){
        if([[array objectAtIndex:0] isEqualToString:ClIENT_VERSION]){
            if([[array objectAtIndex:1] isEqualToString:@"1"]){
                [self addAd];
            }
        }
    }
}
- (void)changeViewColor:(id)sender{
    switch ([sender tag]) {
        case 1:
            self.view_personal.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:48.0/255.0 blue:62.0/255.0 alpha:1];
            break;
        case 2:
            self.view_system.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:48.0/255.0 blue:62.0/255.0 alpha:1];
            break;
        case 3:
            self.view_update.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:48.0/255.0 blue:62.0/255.0 alpha:1];
            break;
        case 4:
            self.view_feedback.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:48.0/255.0 blue:62.0/255.0 alpha:1];
            break;
        case 5:
            self.view_service.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:48.0/255.0 blue:62.0/255.0 alpha:1];
            break;
        case 6:
            self.view_about.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:48.0/255.0 blue:62.0/255.0 alpha:1];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}

- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 1:
        {
            NSLog(@"个人");
            self.view_personal.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1];
            if(kApp.isLogin == 0){
                [self showAlert:@"请先登录"];
                CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
                [self.navigationController pushViewController:loginVC animated:YES];
            }else{
                CNUserinfoViewController* userInfoVC = [[CNUserinfoViewController alloc]init];
                userInfoVC.from = @"setting";
                [self.navigationController pushViewController:userInfoVC animated:YES];
            }
            break;
        }
        case 2:
        {
            NSLog(@"消息");
            self.view_system.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1];
            break;
        }
        case 3:
        {
            NSLog(@"更新");
            self.view_update.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1];
            break;
        }
        case 4:
        {
            NSLog(@"反馈");
            self.view_feedback.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1];
            break;
        }
        case 5:
        {
            NSLog(@"服务条款");
            self.view_service.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1];
            CNServiceViewController* serviceVC = [[CNServiceViewController alloc]init];
            [self.navigationController pushViewController:serviceVC animated:YES];
            break;
        }
        case 6:
        {
            NSLog(@"关于");
            self.view_about.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1];
            AboutViewController* aboutVC = [[AboutViewController alloc]init];
            [self.navigationController pushViewController:aboutVC animated:YES];
            break;
        }
        default:
            break;
    }
}
- (void)addAd{
    self.bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    if(iPhone5){
        self.bannerView_.frame = CGRectMake(0, 476, 320, 50);
    }else{
        self.bannerView_.frame = CGRectMake(0, 388, 320, 50);
    }
    // 指定广告单元ID。
    self.bannerView_.adUnitID = @"ca-app-pub-2147750945893708/7542258473";
    self.bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    [bannerView_ loadRequest:[GADRequest request]];
}
@end

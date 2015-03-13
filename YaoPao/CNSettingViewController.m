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

@interface CNSettingViewController ()

@end

@implementation CNSettingViewController

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
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    
    [self.button_user addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_about addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_service addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_ad addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
//    NSArray* array = [kApp.showad componentsSeparatedByString:@","];
//    if([array count] == 2){
//        if([[array objectAtIndex:0] isEqualToString:ClIENT_VERSION]){
//            if([[array objectAtIndex:1] isEqualToString:@"1"]){
//                self.view_ad.hidden = NO;
//            }
//        }
//    }
}
- (void)button_white_down:(id)sender{
    switch ([sender tag]) {
        case 0:
            self.view_user.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        case 1:
            self.view_about.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        case 2:
            self.view_service.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        case 3:
            self.view_ad.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
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
- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)button_list_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            self.view_user.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
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
        case 1:
        {
            self.view_about.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CNAboutViewController* aboutVC = [[CNAboutViewController alloc]init];
            [self.navigationController pushViewController:aboutVC animated:YES];
            break;
        }
        case 2:
        {
            self.view_service.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CNServiceViewController* serviceVC = [[CNServiceViewController alloc]init];
            [self.navigationController pushViewController:serviceVC animated:YES];
            break;
        }
        case 3:
        {
            self.view_ad.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CNADViewController* adVC = [[CNADViewController alloc]init];
            [self.navigationController pushViewController:adVC animated:YES];
            break;
        }
        default:
            break;
    }
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end

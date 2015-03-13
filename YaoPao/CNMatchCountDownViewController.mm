//
//  CNMatchCountDownViewController.m
//  YaoPao
//
//  Created by zc on 14-8-17.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNMatchCountDownViewController.h"
#import "CNTestGEOS.h"
#import "CNMatchMainViewController.h"
#import "CNMatchMainRecomeViewController.h"
#import "Toast+UIView.h"
#import "CNNumImageView.h"

@interface CNMatchCountDownViewController ()

@end

@implementation CNMatchCountDownViewController
@synthesize timer_countdown;
@synthesize startSecond;
@synthesize niv;
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
    self.niv = [[CNNumImageView alloc]initWithFrame:CGRectMake(-27.5, 180, 375, 120)];
    [self.view addSubview:self.niv];
    self.niv.num = self.startSecond;
    self.niv.color = @"red";
    [self.niv fitToSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.timer_countdown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
}

- (void)countdown{
    //不在出发区提示:
    if([CNAppDelegate isInStartZone] == NO){
        self.label_isInStart.text = @"你尚未进入出发区，请于倒计时结束前进入出发区，否则将无法开始比赛!";
    }else{
        self.label_isInStart.text = @"已经进入出发区!";
    }
    self.startSecond--;
    if(self.startSecond >= 0){
        self.niv.num = self.startSecond;
        self.niv.color = @"red";
        [self.niv fitToSize];
    }
    if(self.startSecond == 0){
        [self.timer_countdown invalidate];
        if([CNAppDelegate isInStartZone]){//在出发区
            CNMatchMainViewController* matchVC = [[CNMatchMainViewController alloc]init];
            [self.navigationController pushViewController:matchVC animated:YES];
        }else{//不在出发区
            kApp.canStartButNotInStartZone = YES;
            [CNAppDelegate popupWarningNotInStartZone];
        }
    }
}

@end

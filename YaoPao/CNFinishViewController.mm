//
//  CNFinishViewController.m
//  YaoPao
//
//  Created by zc on 14-8-27.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNFinishViewController.h"
#import "CNTestGEOS.h"
#import "CNUtil.h"
#import "CNGroupInfoViewController.h"
#import "CNFinishTeamMatchViewController.h"
#import "CNDistanceImageView.h"
#import "CNTimeImageView.h"
#import "CNSpeedImageView.h"

@interface CNFinishViewController ()

@end

@implementation CNFinishViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    kApp.isRunning = 0;
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.image_avatar.image = [[UIImage alloc] initWithData:imageData];
    }
    self.label_username.text = [kApp.userInfoDic objectForKey:@"nickname"];
    self.label_teamname.text = [kApp.matchDic objectForKey:@"groupname"];
    
    double this_dis = (kApp.match_currentLapDis - kApp.match_startdis)+kApp.match_countPass*kLapLength;
    double match_totaldis = this_dis+kApp.match_historydis;
    int speed_second;
    if(match_totaldis < 1){
        speed_second = 0;
    }else{
        speed_second = 1000*(kApp.match_historySecond/match_totaldis);
    }
    CNDistanceImageView* big_div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(-2.5, 138, 325, 80)];
    big_div.distance = (match_totaldis+5)/1000.0;
    big_div.color = @"white";
    [big_div fitToSize];
    [self.view addSubview:big_div];
    
    CNTimeImageView* tiv = [[CNTimeImageView alloc]initWithFrame:CGRectMake(10, 245+IOS7OFFSIZE, 140, 32)];
    tiv.time = kApp.match_historySecond;
    tiv.color = @"white";
    [tiv fitToSize];
    [self.view addSubview:tiv];
    
    CNSpeedImageView* siv = [[CNSpeedImageView alloc]initWithFrame:CGRectMake(190, 245+IOS7OFFSIZE, 100, 32)];
    siv.time = speed_second;
    siv.color = @"white";
    [siv fitToSize];
    [self.view addSubview:siv];
}
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
    if(kApp.hasFinishTeamMatch){//比赛已经结束
        CNFinishTeamMatchViewController* finishvc = [[CNFinishTeamMatchViewController alloc]init];
        [self.navigationController pushViewController:finishvc animated:YES];
    }else{
        CNGroupInfoViewController* groupInfoVC = [[CNGroupInfoViewController alloc]init];
        [self.navigationController pushViewController:groupInfoVC animated:YES];
    }
    
    
}
@end

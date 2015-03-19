//
//  HomeViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/10.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "HomeViewController.h"
#import "ColorValue.h"
#import "StartRunViewController.h"
#import "CNVCodeViewController.h"
#import "CNUtil.h"
#import "ASIHTTPRequest.h"
#import "MobClick.h"
#import <CoreLocation/CoreLocation.h>
#import "CountDownViewController.h"
#import "RunningViewController.h"
#import "CNRunManager.h"
#import "CNLocationHandler.h"
#import "FeelingViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    self.selectIndex = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_cloud fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginDone) name:@"loginDone" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initData) name:@"REFRESH" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:@"gps" object:nil];
    [self setGPSImage];
    if(kApp.isLogin == 2){//正在登录
        [self displayLoading];
    }else{
        if(kApp.isLogin == 11){//老用户需要自动登录
            CNVCodeViewController* vcodeVC = [[CNVCodeViewController alloc]init];
            [self.navigationController pushViewController:vcodeVC animated:YES];
        }
    }
}
- (void)setGPSImage{
    self.label_gps.text = [NSString stringWithFormat:@"%i",kApp.gpsSignal];
}
- (void)loginDone{
    [self hideLoading];
    //加载用户信息
    [self initUI];
}
- (void)initData{
    NSMutableDictionary* record_dic = [CNUtil getPersonalSummary];
    float totaldistance = [[record_dic objectForKey:@"total_distance"]floatValue]/1000;
    self.label_km.text = [NSString stringWithFormat:@"%0.2fkm",totaldistance];
    self.label_count.text = [record_dic objectForKey:@"total_count"];
    int total_time = [[record_dic objectForKey:@"total_time"]intValue];
    int average_pspeed = 1.0/totaldistance*total_time;
    self.label_secondPerKm.text = [CNUtil pspeedStringFromSecond:average_pspeed];
    self.label_score.text = [record_dic objectForKey:@"total_score"];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"mainPage"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self initUI];
    [self initData];
}
- (void)initUI{
    NSMutableDictionary* settingDic = [CNUtil getRunSetting];
    self.label_target_type.text = [NSString stringWithFormat:@"%@ %@",[settingDic objectForKey:@"targetDes"],[settingDic objectForKey:@"typeDes"]];
    if(kApp.userInfoDic != nil){//已经登录状态
        NSString* nickname = [kApp.userInfoDic objectForKey:@"nickname"];
        nickname = (nickname == nil ? [kApp.userInfoDic objectForKey:@"phone"] : nickname);
        self.label_username.text = nickname;
        NSString* signature = [kApp.userInfoDic objectForKey:@"signature"];
        signature = ((signature == nil || [signature isEqualToString:@""])? @"什么都没写" : signature);
        self.button_go_login.hidden = YES;
        NSString* imgpath = [kApp.userInfoDic objectForKey:@"imgpath"];
        if(imgpath != nil){
            //显示头像
            NSData* imageData = kApp.imageData;
            if(imageData){
                self.image_avatar.image = [[UIImage alloc] initWithData:imageData];
            }else{
                NSString *avatar = imgpath;
                NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,avatar];
                NSLog(@"avatar is %@",imageURL);
                NSURL *url = [NSURL URLWithString:imageURL];
                ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
                Imagerequest.tag = 1;
                Imagerequest.timeOutSeconds = 15;
                [Imagerequest setDelegate:self];
                [Imagerequest startAsynchronous];
            }
        }
    }else{//未登录状态
        self.image_avatar.image = [UIImage imageNamed:@"avatar_default.png"];
        self.label_username.text = @"未登录";
        self.button_go_login.hidden = NO;
    }
}
#pragma -mark ASIHttpRequest delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    UIImage *image = [[UIImage alloc] initWithData:[request responseData]];
    if(image){
        self.image_avatar.image = image;
        kApp.imageData = [request responseData];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"mainPage"];
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![CLLocationManager locationServicesEnabled]){//这里判断系统设置的定位打开没有
        NSLog(@"异常提示：系统没有打开gps");
        [CNAppDelegate popupWarningGPSOpen];
    }
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable){
        NSLog(@"异常提示：系统没有打开后台刷新");
        [CNAppDelegate popupWarningBackground];
    }
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
    [self disableAllButton];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
    [self enableAllButton];
}
- (void)disableAllButton{
    self.button_cloud.enabled = NO;
    self.button_go_login.enabled = NO;
    self.button_setting.enabled = NO;
    self.button_running.enabled = NO;
    
}
- (void)enableAllButton{
    self.button_cloud.enabled = YES;
    self.button_go_login.enabled = YES;
    self.button_setting.enabled = YES;
    self.button_running.enabled = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"同步");
            FeelingViewController* feelingVC = [[FeelingViewController alloc]init];
            [self.navigationController pushViewController:feelingVC animated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"登录");
            break;
        }
        case 2:
        {
            NSLog(@"设置目标");
            StartRunViewController* startRunVC = [[StartRunViewController alloc]init];
            [self.navigationController pushViewController:startRunVC animated:YES];
            break;
        }
        case 3:
        {
            NSLog(@"开始运动");
            if ([self prepareRun]) {
                kApp.isRunning = 1;
                kApp.gpsLevel = 4;
                NSMutableDictionary* settingDic = [CNUtil getRunSetting];
                //初始化runManager
                kApp.runManager = [[CNRunManager alloc]initWithSecond:2];
                kApp.runManager.howToMove = [[settingDic objectForKey:@"howToMove"]intValue];
                kApp.runManager.targetType = [[settingDic objectForKey:@"targetType"]intValue];
                kApp.runManager.targetValue = [[settingDic objectForKey:@"targetValue"]intValue];
                NSLog(@"howtomove is %d",kApp.runManager.howToMove);
                NSLog(@"targetType is %d",kApp.runManager.targetType);
                NSLog(@"targetValue is %d",kApp.runManager.targetValue);
                int countDonwOn = [[settingDic objectForKey:@"countdown"]intValue];
                if(countDonwOn == 1){
                    CountDownViewController* countdownVC = [[CountDownViewController alloc]init];
                    [self.navigationController pushViewController:countdownVC animated:YES];
                }else{
                    RunningViewController* runningVC = [[RunningViewController alloc]init];
                    [self.navigationController pushViewController:runningVC animated:YES];
                }
            }
            break;
        }
        default:
            break;
    }
}
- (BOOL)prepareRun{
    //测试代码
#ifdef SIMULATORTEST
    return YES;
#else
# endif
    
    if (0.001 > fabs(kApp.locationHandler.userLocation_lon) || 0.001 > fabs(kApp.locationHandler.userLocation_lat))
    {
        NSLog(@"异常提示：gps信号弱");
        [CNAppDelegate popupWarningGPSWeak];
        return NO;
    }else{
        if(kApp.locationHandler.rank >= kApp.gpsLevel){
            return YES;
        }else{
            NSLog(@"异常提示：gps信号弱");
            [CNAppDelegate popupWarningGPSWeak];
            return NO;
        }
    }
}
@end

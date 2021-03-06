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
#import "CNUtil.h"
#import "ASIHTTPRequest.h"
#import "MobClick.h"
#import <CoreLocation/CoreLocation.h>
#import "CountDownViewController.h"
#import "RunningViewController.h"
#import "CNRunManager.h"
#import "CNLocationHandler.h"
#import "CNShareViewController.h"
#import "CNLoginPhoneViewController.h"
#import "CNUserinfoViewController.h"
#import "WaterMarkViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import "CNADBookViewController.h"
#import "CNCloudRecord.h"
#import "SBJson.h"
#import "GCDAsyncUdpSocket.h"
#import "CNUtil.h"
#import "ToolClass.h"
#import "AvatarManager.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
NSString* weatherCode;
NSString* dayOrNight;
@synthesize weatherRefreshTime;

- (void)viewDidLoad {
    self.selectIndex = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_cloud fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginDone) name:@"loginDone" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initData) name:@"REFRESH" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:@"gps" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tellWeather) name:@"weather" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(displayEventIcon) name:@"eventIcon" object:nil];
    [self setGPSImage];
    [self displayEventIcon];
    if(kApp.isLogin == 2){//正在登录
        [self displayLoading];
        self.label_username.text = @"正在登录...";
    }else{
//        if(kApp.isLogin == 11){//老用户需要自动登录
//            CNVCodeViewController* vcodeVC = [[CNVCodeViewController alloc]init];
//            [self.navigationController pushViewController:vcodeVC animated:YES];
//        }
    }
    self.view_line_verticle.frame = CGRectMake(160, 267, 0.5, 160);
    self.view_line_horizontal1.frame = CGRectMake(0, 347, 320, 0.5);
    self.view_line_horizontal2.frame = CGRectMake(0, 427, 320, 0.5);
    if(!iPhone5){//4、4s
        CGRect frame_new1 = self.view_part1.frame;
        frame_new1.size = CGSizeMake(160, 50);
        self.view_part1.frame = frame_new1;
        
        CGRect frame_new2 = self.view_part2.frame;
        frame_new2.size = CGSizeMake(160, 50);
        self.view_part2.frame = frame_new2;
        
        CGRect frame_new3 = self.view_part3.frame;
        frame_new3.origin = CGPointMake(0, 317);
        frame_new3.size = CGSizeMake(160, 50);
        self.view_part3.frame = frame_new3;
        
        CGRect frame_new4 = self.view_part4.frame;
        frame_new4.origin = CGPointMake(160, 317);
        frame_new4.size = CGSizeMake(160, 50);
        self.view_part4.frame = frame_new4;
        
        self.view_line_verticle.frame = CGRectMake(160, 267, 0.5, 100);
        self.view_line_horizontal1.frame = CGRectMake(0, 317, 320, 0.5);
        self.view_line_horizontal2.frame = CGRectMake(0, 367, 320, 0.5);
        self.button_running.frame = CGRectMake(52, 382, 217, 42);
        
        self.imageview_part1.frame = CGRectMake(9, 3, 40, 40);
        self.imageview_part2.frame = CGRectMake(9, 3, 40, 40);
        self.imageview_part3.frame = CGRectMake(9, 3, 40, 40);
    }
    //开始上报udp
    kApp.timer_udp_running = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(sendMessageByUdp) userInfo:nil repeats:YES];
    //是否有新水印
    //请求时间戳
    [self requestTimeStamp];
}
- (void)requestTimeStamp{
    [kApp.networkHandler doRequest_WaterMarkTimeStamp];
    kApp.networkHandler.delegate_WaterMarkTimeStamp = self;
}
- (void)WaterMarkTimeStampDidSuccess:(NSString* ) newTimeStamp{
    NSString *filePath = [ToolClass getDocument:@"WMTimeStamp.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (dic) {
        NSString *oldTimeStamp = [dic objectForKey:@"timestamp"];
        if ([newTimeStamp isEqualToString:oldTimeStamp]) {
            kApp.hasNewWaterMaker = NO;
        }
        else{
            kApp.hasNewWaterMaker = YES;
            self.reddot_water.hidden = NO;
        }
    }
    else{
        kApp.hasNewWaterMaker = YES;
        self.reddot_water.hidden = NO;
    }
    kApp.waterTimeStampNew = newTimeStamp;
}

- (void)WaterMarkTimeStampDidFailed:(NSString* ) mes{
    //水印时间戳请求失败，为了妥善，认为有新的水印
    kApp.hasNewWaterMaker = YES;
    self.reddot_water.hidden = NO;
}
- (void)sendMessageByUdp{
    if(kApp.locationHandler.userLocation_lon < 1||kApp.locationHandler.userLocation_lat<1){
//        NSLog(@"没定位点不上报udp");
        return;
    }
    if(kApp.isLogin != 1){
//        NSLog(@"没登录不上报udp");
        return;
    }
    if(!kApp.isOpenShareLocation){
//        NSLog(@"从没打开过分享不上报udp");
        return;
    }
    NSMutableDictionary* udpParamDic = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [udpParamDic setObject:uid forKey:@"uid"];
    [udpParamDic setObject:[NSString stringWithFormat:@"%f",kApp.locationHandler.userLocation_lon] forKey:@"lon"];
    [udpParamDic setObject:[NSString stringWithFormat:@"%f",kApp.locationHandler.userLocation_lat] forKey:@"lat"];
    [udpParamDic setObject:[NSString stringWithFormat:@"%i",kApp.runManager.howToMove] forKey:@"howtomove"];
    [udpParamDic setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]] forKey:@"duration"];
    [udpParamDic setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
    [udpParamDic setObject:@"1.0" forKey:@"version"];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString* jsonString = [jsonWriter stringWithObject:udpParamDic];
    NSLog(@"jsonstring is %@",jsonString);
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    [kApp.udpSocket sendData:data toHost:ENDPOINTS_UDP port:28888 withTimeout:-1 tag:0];
}
- (void)displayEventIcon{
    if(kApp.isInEvent){
        self.imageview_matchlogo.hidden = NO;
        NSString* urlString = [[kApp.eventTimeString componentsSeparatedByString:@","] objectAtIndex:2];
        NSURL *url = [NSURL URLWithString:urlString];
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setCompletionBlock :^{
            UIImage* image = [[UIImage alloc] initWithData:[request responseData]];
            if(image != nil){
                self.imageview_matchlogo.image = image;
            }
        }];
        [request startAsynchronous ];
    }
}
- (void)tellWeather{
    //请求天气
    self.weather_progress.hidden = NO;
    [self.weather_progress startAnimating];
    kApp.networkHandler.delegate_weather = self;
    [kApp.networkHandler doRequest_weather:kApp.locationHandler.userLocation_lon :kApp.locationHandler.userLocation_lat];
}
- (void)weatherDidFailed:(NSString *)mes{
    self.weather_progress.hidden = YES;
    [self.weather_progress stopAnimating];
}
- (void)weatherDidSuccess:(NSDictionary *)resultDic{
    self.weatherRefreshTime = [CNUtil getNowTime];
    self.weather_progress.hidden = YES;
    [self.weather_progress stopAnimating];
    NSDictionary* weatherData = [resultDic objectForKey:@"data"];
    self.label_temp.text = [NSString stringWithFormat:@"%@%@",[weatherData objectForKey:@"weather"],[weatherData objectForKey:@"temp"]];
    if(self.label_temp.text.length >= 8){
        [self.label_temp setFont:[UIFont systemFontOfSize:13]];
    }
    NSString* pmlevel = [weatherData objectForKey:@"aq"];
    NSString* pmvalue = [NSString stringWithFormat:@"(%@)",[weatherData objectForKey:@"pm25"]];
    self.label_pmLevel.text = [NSString stringWithFormat:@"%@%@",pmlevel,pmvalue];
    weatherCode = [weatherData objectForKey:@"weatherCode"];
    dayOrNight = [CNUtil dayOrNight];
    NSString* imageName = [NSString stringWithFormat:@"weather_icon_%@_%@.png",dayOrNight,weatherCode];
    self.imageview_weather.image = [UIImage imageNamed:imageName];
}
- (void)setGPSImage{
    NSString* gpsDes = @"";
    switch (kApp.gpsSignal) {
        case 1:
            gpsDes = @"很差";
            break;
        case 2:
            gpsDes = @"偏弱";
            break;
        case 3:
            gpsDes = @"良好";
            break;
        case 4:
            gpsDes = @"非常好";
            break;
            
        default:
            break;
    }
    self.label_gps.text = gpsDes;
}
- (void)loginDone{
    self.label_username.text = @"未登录";
    [self hideLoading];
    //加载用户信息
    [self initUI];
}
- (void)initData{
    NSMutableDictionary* record_dic = [CNUtil getPersonalSummary];
    float totaldistance = [[record_dic objectForKey:@"total_distance"]floatValue]/1000;
    self.label_km.text = [NSString stringWithFormat:@"%0.2fKM",totaldistance];
    self.label_count.text = [record_dic objectForKey:@"total_count"];
    int total_time = [[record_dic objectForKey:@"total_time"]intValue];
    int average_pspeed = 1.0/totaldistance*total_time;
    self.label_secondPerKm.text = [CNUtil pspeedStringFromSecond:average_pspeed];
    self.label_score.text = [record_dic objectForKey:@"total_score"];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [CNUtil appendUserOperation:@"进入主页面"];
    if(kApp.unreadMessageCount != 0){
        self.reddot.hidden = NO;
    }else{
        self.reddot.hidden = YES;
    }
    [kApp addObserver:self forKeyPath:@"unreadMessageCount" options:NSKeyValueObservingOptionNew context:nil];
    [kApp.cloudManager addObserver:self forKeyPath:@"stepDes" options:NSKeyValueObservingOptionNew context:nil];
    [kApp.networkHandler addObserver:self forKeyPath:@"newprogress" options:NSKeyValueObservingOptionNew context:nil];
    [MobClick beginLogPageView:@"mainPage"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self initUI];
    [self initData];
    if(self.weatherRefreshTime != 0 && [CNUtil getNowTime] - self.weatherRefreshTime > 1*60*60){
        [self tellWeather];
    }
}
- (void)initUI{
    NSMutableDictionary* settingDic = [CNUtil getRunSettingWhole];
    self.label_target_type.text = [NSString stringWithFormat:@"%@ %@",[settingDic objectForKey:@"targetDes"],[settingDic objectForKey:@"typeDes"]];
    self.image_avatar.layer.cornerRadius = self.image_avatar.bounds.size.width/2;
    self.image_avatar.layer.masksToBounds = YES;
    if(kApp.userInfoDic != nil){//已经登录状态
        NSString* nickname = [kApp.userInfoDic objectForKey:@"nickname"];
        nickname = (nickname == nil ? [kApp.userInfoDic objectForKey:@"phone"] : nickname);
        self.label_username.text = nickname;
        NSString* signature = [kApp.userInfoDic objectForKey:@"signature"];
        signature = ((signature == nil || [signature isEqualToString:@""])? @"什么都没写" : signature);
        NSString* imgpath = [kApp.userInfoDic objectForKey:@"imgpath"];
        if(imgpath != nil){
            //显示头像
//            NSData* imageData = kApp.imageData;
//            if(imageData){
//                self.image_avatar.image = [[UIImage alloc] initWithData:imageData];
//            }else{
//                NSString *avatar = imgpath;
//                NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,avatar];
//                NSLog(@"avatar is %@",imageURL);
//                NSURL *url = [NSURL URLWithString:imageURL];
//                ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
//                Imagerequest.tag = 1;
//                Imagerequest.timeOutSeconds = 15;
//                [Imagerequest setDelegate:self];
//                [Imagerequest startAsynchronous];
//            }
            [kApp.avatarManager setImageToImageView:self.image_avatar fromUrl:imgpath];
        }
    }else{//未登录状态
        self.image_avatar.image = [UIImage imageNamed:@"avatar_default.png"];
        self.label_username.text = @"未登录";
        if(kApp.isLogin == 2){
            self.label_username.text = @"正在登录...";
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"mainPage"];
    [kApp.cloudManager removeObserver:self forKeyPath:@"stepDes"];
    [kApp.networkHandler removeObserver:self forKeyPath:@"newprogress"];
    [kApp removeObserver:self forKeyPath:@"unreadMessageCount"];
    self.progressview_cloud.hidden = YES;
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
    self.view.userInteractionEnabled = NO;
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
    self.view.userInteractionEnabled = YES;
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
- (void)testTimeOutDidFailed{
    NSLog(@"请检查网络");
    [self hideLoading];
}
- (void)testTimeOutDidSuccess{
    NSLog(@"请求成功");
    [self hideLoading];
}
- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"同步");
            [CNAppDelegate popupWarningCloud:YES];
            
//            [kApp.friendHandler checkNeedUploadAD];
//            [kApp.friendHandler userInADBook];
//            [kApp.networkHandler doRequest_testTimeOut];
//            kApp.networkHandler.delegate_testTimeOut = self;
//            [self displayLoading];
            [CNUtil appendUserOperation:@"点击同步"];
            break;
        }
        case 1:
        {
            NSLog(@"登录");
            [CNUtil appendUserOperation:@"点击头像"];
            if(kApp.isLogin == 0){
                CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
                [self.navigationController pushViewController:loginVC animated:YES];
            }else{
                CNUserinfoViewController* userInfoVC = [[CNUserinfoViewController alloc]init];
                userInfoVC.from = @"home";
                [self.navigationController pushViewController:userInfoVC animated:YES];
            }
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
//            if ([self prepareRun]) {
                kApp.isRunning = 1;
                kApp.gpsLevel = 4;
                NSMutableDictionary* settingDic = [CNUtil getRunSettingWhole];
                int voice = [[settingDic objectForKey:@"voice"]intValue];
                if(voice == 0){
                    kApp.voiceOn = 0;
                }else{
                    kApp.voiceOn = 1;
                }
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
                    RunningViewController* runningVC = [[RunningViewController alloc]init];
                    runningVC.count = 5;
                    [self.navigationController pushViewController:runningVC animated:YES];
                }else{
                    RunningViewController* runningVC = [[RunningViewController alloc]init];
                    runningVC.count = 0;
                    [self.navigationController pushViewController:runningVC animated:YES];
                }
            [CNUtil appendUserOperation:[NSString stringWithFormat:@"开始运动：类型为:%d,目标类型是:%d,目标值:%d,是否有语音:%d,是否倒计时:%d",kApp.runManager.howToMove,kApp.runManager.targetType,kApp.runManager.targetValue,kApp.voiceOn,countDonwOn]];
//            }
            break;
        }
        case 4:
        {
            [FriendsHandler AddPeople];
            break;
        }
        case 5:
        {
            [FriendsHandler DeletePeople];
            [CNUtil showAlert:@"删除成功"];
            break;
        }
            
        default:
            break;
    }
}

- (IBAction)button_logout:(id)sender {
    kApp.isLogin = 0;
    kApp.userInfoDic = nil;
    NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
    [self initUI];
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
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"stepDes"]){
        if([kApp.cloudManager.stepDes isEqualToString:@"同步完毕！"]||[kApp.cloudManager.stepDes hasPrefix:@"同步失败"]){
            self.progressview_cloud.hidden = YES;
            self.button_cloud.enabled = YES;
        }
    }else if([keyPath isEqualToString:@"newprogress"]){
        if(kApp.isLogin == 1 && ![kApp.cloudManager.stepDes isEqualToString:@"同步完毕！"]){
            if(kApp.cloudManager.isSynServerTime){//已经同步了时间
                self.progressview_cloud.hidden = NO;
                [self.progressview_cloud setProgress:kApp.networkHandler.newprogress];
                self.button_cloud.enabled = NO;
            }
        }
    }else if([keyPath isEqualToString:@"unreadMessageCount"]){
        NSLog(@"--------------unreadMessageCount is %i",kApp.unreadMessageCount);
        if(kApp.unreadMessageCount != 0){
            self.reddot.hidden = NO;
        }else{
            self.reddot.hidden = YES;
        }
    }
}
@end

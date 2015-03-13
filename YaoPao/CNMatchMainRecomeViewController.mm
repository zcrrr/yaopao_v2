//
//  CNMatchMainRecomeViewController.m
//  YaoPao
//
//  Created by zc on 14-9-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNMatchMainRecomeViewController.h"
#import "CNUtil.h"
#import "CNGPSPoint4Match.h"
#import "CNLocationHandler.h"
#import "CNTestGEOS.h"
#import "CNEncryption.h"
#import "CNGiveRelayViewController.h"
#import "CNGroupListViewController.h"
#import "CNMatchMapViewController.h"
#import "SBJson.h"
#import "CNNetworkHandler.h"
#import "CNNotInTakeOverViewController.h"
#import "CNVoiceHandler.h"
#import "CNDistanceImageView.h"
#import "CNTimeImageView.h"
#import "CNSpeedImageView.h"

#define kMatchInterval 2
#define kkmInterval 1000

@interface CNMatchMainRecomeViewController ()

@end

@implementation CNMatchMainRecomeViewController
@synthesize nextDis;
@synthesize isIn;
@synthesize big_div;
@synthesize tiv;
@synthesize siv;
@synthesize tryCount;
@synthesize lastKMTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)initMatch{
    kApp.match_pointList = [[NSMutableArray alloc]init];
    NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
    NSDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    //把已经跑过的距离作为基准值
    kApp.match_historydis = [[dic objectForKey:@"match_historydis"]doubleValue];
    kApp.match_totalDisTeam = [[dic objectForKey:@"match_totalDisTeam"]doubleValue];
    kApp.match_targetkm = [[dic objectForKey:@"match_targetkm"]intValue];
    kApp.match_historySecond = [[dic objectForKey:@"match_historySecond"]intValue];
    kApp.match_startdis = [[dic objectForKey:@"match_startdis"]doubleValue];
    kApp.match_currentLapDis = [[dic objectForKey:@"match_currentLapDis"]doubleValue];
    kApp.match_countPass = [[dic objectForKey:@"match_countPass"]intValue];
    kApp.match_time_last_in_track = [[dic objectForKey:@"match_time_last_in_track"]intValue];
//    kApp.match_pointsString = [NSMutableString stringWithString:[dic objectForKey:@"match_pointsString"]];
    kApp.match_score = [[dic objectForKey:@"match_score"]intValue];
    kApp.match_km_target_personal = [[dic objectForKey:@"match_km_target_personal"]intValue];
    kApp.match_km_start_time = [[dic objectForKey:@"match_km_start_time"]intValue];
    //解析match_pointsString得到match_pointList
//    NSArray* strList = [kApp.match_pointsString componentsSeparatedByString:@";"];
//    for(int i = 0;i<[strList count];i++){
//        NSString* onePointStr = [strList objectAtIndex:i];
//        if([onePointStr isEqualToString:@""]){
//            CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
//            point.lon = 0;
//            point.lat = 0;
//            [kApp.match_pointList addObject:point];
//        }else{
//            NSArray* lonlat = [onePointStr componentsSeparatedByString:@","];
//            CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
//            point.lon = [[lonlat objectAtIndex:0]doubleValue];
//            point.lat = [[lonlat objectAtIndex:1]doubleValue];
//            [kApp.match_pointList addObject:point];
//        }
//    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initMatch];
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    kApp.isRunning = 1;
    self.big_div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(-2.5, 25, 325, 80)];
    self.big_div.distance = 0;
    self.big_div.color = @"white";
    [self.big_div fitToSize];
    [self.view_distance addSubview:self.big_div];
    
    self.tiv = [[CNTimeImageView alloc]initWithFrame:CGRectMake(10, 245+IOS7OFFSIZE, 140, 32)];
    self.tiv.time = 0;
    self.tiv.color = @"white";
    [self.tiv fitToSize];
    [self.view addSubview:self.tiv];
    
    self.siv = [[CNSpeedImageView alloc]initWithFrame:CGRectMake(190, 245+IOS7OFFSIZE, 100, 32)];
    self.siv.time = 0;
    self.siv.color = @"white";
    [self.siv fitToSize];
    [self.view addSubview:self.siv];
    
    //测试代码
    kApp.array4Test = [[NSMutableArray alloc]init];
    [self pushTestArray:@"----上次闪退！！----"];
    
    double this_dis = (kApp.match_currentLapDis - kApp.match_startdis)+kApp.match_countPass*kLapLength;
    kApp.match_totaldis = this_dis+kApp.match_historydis;
    self.big_div.distance = (kApp.match_totaldis+5)/1000.0;
    [self.big_div fitToSize];
    self.tiv.time = kApp.match_historySecond;
    [self.tiv fitToSize];
    
    int speed_second = 1000*(kApp.match_historySecond/kApp.match_totaldis);
    self.siv.time = speed_second;
    [self.siv fitToSize];
    [self pushTestArray:[NSString stringWithFormat:@"起始参数%0.2f,%0.2f,%i",kApp.match_startdis,kApp.match_currentLapDis,kApp.match_countPass]];
    
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.image_avatar.image = [[UIImage alloc] initWithData:imageData];
    }
    self.label_name.text = [kApp.userInfoDic objectForKey:@"nickname"];
    self.label_team.text = [kApp.matchDic objectForKey:@"groupname"];
    [self startTimer];
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
- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            CNGroupListViewController* listVC = [[CNGroupListViewController alloc]init];
            [self.navigationController pushViewController:listVC animated:YES];
            break;
        }
        case 1:
        {
            CNGPSPoint4Match* gpspoint = [kApp.match_pointList lastObject];
#ifdef SIMULATORTEST
            int isInTakeOverZone = 0;
#else
            int isInTakeOverZone = [kApp.geosHandler isInTheTakeOverZones:gpspoint.lon :gpspoint.lat];
# endif
            NSLog(@"是否在交接区:%i",isInTakeOverZone);
            if(isInTakeOverZone != -1){
                [self pushTestArray:@"-----在交接区点击-----"];
                CNGiveRelayViewController* relayVC = [[CNGiveRelayViewController alloc]init];
                [self.navigationController pushViewController:relayVC animated:YES];
            }else{
                [self pushTestArray:@"-----在外面点击-----"];
                CNNotInTakeOverViewController* notVC = [[CNNotInTakeOverViewController alloc]init];
                [self.navigationController pushViewController:notVC animated:YES];
            }
            break;
        }
        case 2:
        {
            CNMatchMapViewController* mapVC = [[CNMatchMapViewController alloc]init];
            [self.navigationController pushViewController:mapVC animated:YES];
            break;
        }
        default:
            break;
    }
}
- (void)displayTime{
    kApp.match_historySecond++;
    self.tiv.time = kApp.match_historySecond;
    [self.tiv fitToSize];
}
- (void)startTimer{
    kApp.timer_one_point = [NSTimer scheduledTimerWithTimeInterval:kMatchInterval target:self selector:@selector(pushOnePoint) userInfo:nil repeats:YES];
    kApp.timer_secondplusplus = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
    kApp.match_timer_report = [NSTimer scheduledTimerWithTimeInterval:kMatchReportInterval target:self selector:@selector(matchReport) userInfo:nil repeats:YES];
}
- (CNGPSPoint4Match*)getOnePoint{//得到点就是02坐标
    //测试代码
#ifdef SIMULATORTEST
    kApp.testIndex++;
    if(kApp.testIndex == kApp.matchtestdatalength-1){
        kApp.testIndex = 0;
    }
    return [CNAppDelegate test_getOnePoint];
#else
# endif
    
    CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(kApp.locationHandler.userLocation_lat, kApp.locationHandler.userLocation_lon);
    CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
    CNGPSPoint4Match* gpsPoint = [[CNGPSPoint4Match alloc]init];
    gpsPoint.lon = encryptionPoint.longitude;
    gpsPoint.lat = encryptionPoint.latitude;
    gpsPoint.time = kApp.locationHandler.gpsTime;
    gpsPoint.course = kApp.locationHandler.course;
    return gpsPoint;
}
- (void)pushOnePoint{
    //得到新的一个点压入数组
    CNGPSPoint4Match* gpsPoint = [self getOnePoint];
    [self pushTestArray:[NSString stringWithFormat:@"得到一个点:%0.6f,%0.6f",gpsPoint.lon,gpsPoint.lat]];
    BOOL isInTheTracks = [kApp.geosHandler isInTheTracks:gpsPoint.lon :gpsPoint.lat];
    int timeFromLastInTrack = (int)(gpsPoint.time - kApp.match_time_last_in_track);
    if(isInTheTracks){//在赛道内
        [self pushTestArray:@"-----在赛道内-----"];
        if(self.view_distance.hidden == YES){
            self.view_distance.hidden = NO;
        }
        if(self.view_offtrack.hidden == NO){
            self.view_offtrack.hidden = YES;
        }
        kApp.match_time_last_in_track = gpsPoint.time;
        [kApp.geosHandler match:gpsPoint.lon :gpsPoint.lat :gpsPoint.course];
        double point2Dis = [kApp.geosHandler runningLength];
        //将点的坐标改为匹配坐标
        gpsPoint.lon = kApp.geosHandler.lon_after_convert;
        gpsPoint.lat = kApp.geosHandler.lat_after_convert;
        gpsPoint.isInTrack = 1;
        if(timeFromLastInTrack < kBoundary1*60){//小于十分钟
            [self pushTestArray:@"-----十分钟之内-----"];
            if(point2Dis > kApp.match_currentLapDis){
                if(point2Dis - kApp.match_currentLapDis>kLapLength/2){//大的很多，证明是往回跑，并且经过起点了
                    [self pushTestArray:@"-----往回跑了，并且经过起点-----"];
                }else{//大的不多，正常向前跑
                    [self pushTestArray:@"-----正常向前-----"];
                    kApp.match_currentLapDis = point2Dis;
                }
            }else{
                if(kApp.match_currentLapDis - point2Dis > kLapLength/2){//小的太多，证明往前跑并且跨圈了
                    [self pushTestArray:@"-----往前跑并且跨圈-----"];
                    kApp.match_currentLapDis = point2Dis;
                    kApp.match_countPass++;
                }else{//小的不是很多，证明往回跑了，什么都不干
                    [self pushTestArray:@"-----往回跑了，没跨圈-----"];
                }
            }
            double this_dis = (kApp.match_currentLapDis - kApp.match_startdis)+kApp.match_countPass*kLapLength;
            kApp.match_totaldis = this_dis;
             NSLog(@"kApp.match_historydis is %f",kApp.match_historydis);
            if(kApp.match_totalDisTeam + kApp.match_totaldis > kApp.match_targetkm*kkmInterval){
                [self pushTestArray:[NSString stringWithFormat:@"整公里上报:%i",kApp.match_targetkm]];
                //整公里上报
                [self oneKmReport:gpsPoint.time];
                //播报语音
                [self onekmvoice];
                kApp.match_targetkm ++;
            }
            self.big_div.distance = (kApp.match_totaldis+5)/1000.0;
            [self.big_div fitToSize];
            //计算配速
            if(kApp.match_totaldis > 1){
                int speed_second = 1000*(kApp.match_historySecond/kApp.match_totaldis);
                self.siv.time = speed_second;
                [self.siv fitToSize];
            }
            //距离下一交接区
            self.nextDis = [kApp.geosHandler getDistanceToNextTakeOverZone:point2Dis];
            self.label_nextArea.text = [NSString stringWithFormat:@"距离下一交接区还有:%0.2f公里",self.nextDis/1000.0];
            
            
            //算积分
            if(kApp.match_totaldis > 1000*kApp.match_km_target_personal){
                int minute = (kApp.match_historySecond - kApp.match_km_start_time)/60;
                kApp.match_score += [self score4speed:minute];
                kApp.match_km_target_personal++;
                kApp.match_km_start_time = kApp.match_historySecond;
            }
        }else{//大于十分钟，但是回来了
            [self pushTestArray:@"超过10分钟回来"];
            kApp.match_historydis += (kApp.match_currentLapDis - kApp.match_startdis)+kApp.match_countPass*kLapLength;
            //通过该点初始化比赛信息，意味着重新开始一段新的跑步
            kApp.match_startdis = point2Dis;
            kApp.match_currentLapDis = point2Dis;
            kApp.match_countPass = 0;
//            [kApp.match_pointsString appendString:@";"];
            CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
            point.lon = 0;
            point.lat = 0;
            [kApp.match_pointList addObject:point];
        }
    }else{//不在赛道内
        [self pushTestArray:@"-----偏离赛道-----"];
        if(self.view_distance.hidden == NO){
            self.view_distance.hidden = YES;
        }
        if(self.view_offtrack.hidden == YES){
            self.view_offtrack.hidden = NO;
        }
        gpsPoint.isInTrack = 0;
        if(timeFromLastInTrack >= kBoundary2*60){//已经偏离了1个小时了
            //结束比赛
            [self pushTestArray:@"-----偏离赛道1小时，结束比赛-----"];
            [self finishMatch];
        }
    }
    [kApp.match_pointList addObject:gpsPoint];//在不在赛道内都压入数组
    
    int isInTakeOverZone = [kApp.geosHandler isInTheTakeOverZones:gpsPoint.lon :gpsPoint.lat];
    NSLog(@"是否在交接区:%i",isInTakeOverZone);
    if(isInTakeOverZone != -1){//在交接区
        if(self.isIn == NO){
            self.isIn = YES;
            //播放语音
            [kApp.voiceHandler voiceOfapp:@"match_running_in_take_over" :nil];
        }
    }else{//不在交接区
        self.isIn = NO;
    }
    //将总距离存储到文件
    if([kApp.match_pointList count]%5 == 0){
        [self pushTestArray:@"-----存储到文件-----"];
        [CNAppDelegate match_save2plist];
    }
    
}
- (void)pushTestArray:(NSString*)aString{
    return;
    [kApp.array4Test addObject:[NSString stringWithFormat:@"%i:%@",kApp.run_second,aString]];
    int count = [kApp.array4Test count];
    UILabel* label_test = [[UILabel alloc]initWithFrame:CGRectMake(0, 20*(count-1), 320, 20)];
    label_test.textAlignment = NSTextAlignmentLeft;
    label_test.font = [UIFont systemFontOfSize:12];
    label_test.textColor = [UIColor yellowColor];
    label_test.text = [NSString stringWithFormat:@"%i:%@",kApp.run_second,aString];
    [self.scrollview_test addSubview:label_test];
    [self.scrollview_test setContentSize:CGSizeMake(320, 20*count)];
}
- (void)matchReport{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    NSMutableArray* pointList = [[NSMutableArray alloc]init];
    NSMutableDictionary* onepoint = [[NSMutableDictionary alloc]init];
    CNGPSPoint4Match* gpsPoint = [kApp.match_pointList lastObject];
    [onepoint setObject:[NSString stringWithFormat:@"%llu",gpsPoint.time*1000] forKey:@"uptime"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",kApp.match_totaldis] forKey:@"distanceur"];
    [onepoint setObject:[NSString stringWithFormat:@"%i",gpsPoint.isInTrack] forKey:@"inrunway"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",gpsPoint.lat] forKey:@"slat"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",gpsPoint.lon] forKey:@"slon"];
    [onepoint setObject:@"1" forKey:@"mstate"];
    [pointList addObject:onepoint];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString* pointJson = [jsonWriter stringWithObject:pointList];
    [params setObject:pointJson forKey:@"longitude"];
    [kApp.networkHandler doRequest_matchReport:params];
}
- (void)oneKmReport:(long long)time{
    self.lastKMTime = time;
    self.tryCount++;
    [self pushTestArray:[NSString stringWithFormat:@"%i公里",kApp.match_targetkm]];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    [params setObject:[NSString stringWithFormat:@"%i",kApp.match_targetkm] forKey:@"km"];
    [params setObject:[NSString stringWithFormat:@"%llu",time*1000] forKey:@"uptime"];
    kApp.networkHandler.delegate_matchOnekm = self;
    [kApp.networkHandler doRequest_matchOnekm:params];
}
- (void)onekmvoice{
    //播报语音
    CNGPSPoint4Match* gpspoint = [kApp.match_pointList lastObject];
    int isInTakeOverZone = [kApp.geosHandler isInTheTakeOverZones:gpspoint.lon :gpspoint.lat];
    NSLog(@"是否在交接区:%i",isInTakeOverZone);
    if(isInTakeOverZone != -1){//在交接区
        NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
        [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.match_targetkm] forKey:@"km"];
        [kApp.voiceHandler voiceOfapp:@"match_one_km_and_not_in_take_over" :voice_params];
    }else{//不在交接区
        NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
        [voice_params setObject:[NSString stringWithFormat:@"%f",self.nextDis] forKey:@"distanceFromTakeOver"];
        [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.match_targetkm] forKey:@"km"];
        NSLog(@"self.nextDis is %f",self.nextDis);
        NSLog(@"kApp.match_targetkm is %i",kApp.match_targetkm);
        [kApp.voiceHandler voiceOfapp:@"match_one_km_and_not_in_take_over" :voice_params];
    }
}
- (void)matchOnekmDidSuccess:(NSDictionary *)resultDic{
    self.tryCount = 0;
}
- (void)matchOnekmDidFailed:(NSString *)mes{
    if(self.tryCount < 4){
        [self oneKmReport:self.lastKMTime];
    }
}
- (void)finishMatch{
    [CNAppDelegate saveMatchToRecord];
    [kApp.timer_one_point invalidate];
    [kApp.timer_secondplusplus invalidate];
    [kApp.match_timer_report invalidate];
    NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
    //调用服务器接口
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    CNGPSPoint4Match* gpsPoint = [kApp.match_pointList lastObject];
    NSMutableArray* pointList = [[NSMutableArray alloc]init];
    NSMutableDictionary* onepoint = [[NSMutableDictionary alloc]init];
    [onepoint setObject:[NSString stringWithFormat:@"%llu",gpsPoint.time*1000] forKey:@"uptime"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",kApp.match_totaldis] forKey:@"distanceur"];
    [onepoint setObject:[NSString stringWithFormat:@"%i",gpsPoint.isInTrack] forKey:@"inrunway"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",gpsPoint.lat] forKey:@"slat"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",gpsPoint.lon] forKey:@"slon"];
    [onepoint setObject:@"3" forKey:@"mstate"];
    [pointList addObject:onepoint];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString* pointJson = [jsonWriter stringWithObject:pointList];
    [params setObject:pointJson forKey:@"longitude"];
    kApp.networkHandler.delegate_endMatch = self;
    [kApp.networkHandler doRequest_endMatch:params];
}
- (void)endMatchInfoDidSuccess:(NSDictionary *)resultDic{
    [CNAppDelegate ForceGoMatchPage:@"finish"];
}
- (void)endMatchInfoDidFailed:(NSString *)mes{
    
}
- (int)score4speed:(int)minute{
    if(minute < 5){
        return 24;
    }
    if(minute < 6){
        return 20;
    }
    if(minute < 7){
        return 18;
    }
    if(minute < 8){
        return 16;
    }
    if(minute < 9){
        return 14;
    }
    if(minute < 10){
        return 12;
    }
    if(minute < 11){
        return 10;
    }
    if(minute < 12){
        return 8;
    }
    if(minute < 13){
        return 6;
    }
    return 0;
}

@end

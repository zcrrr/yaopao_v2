//
//  CNLocationHandler.m
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNLocationHandler.h"
#import "CNUtil.h"
#import "CNGPSPoint4Match.h"
#import "SBJson.h"
#import "CNNetworkHandler.h"
#import "CNTestGEOS.h"

@implementation CNLocationHandler
@synthesize userLocation_lat;
@synthesize userLocation_lon;
@synthesize altitude;
@synthesize course;
@synthesize speed;
@synthesize rank;
@synthesize gpsTime;
@synthesize isStart;
@synthesize num;


- (void)startGetLocation{
    if([CLLocationManager locationServicesEnabled]){
        self.isStart = 1;
        self.locationManager = [[CLLocationManager alloc] init];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) { [self.locationManager requestAlwaysAuthorization]; }
        [self.locationManager setDelegate:self];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    }
}
- (void)stopLocation{
    self.isStart = 0;
    [self.locationManager stopUpdatingLocation];
}
#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation* newLocation = [locations lastObject];
    if (newLocation.horizontalAccuracy > 200)
        self.rank = 1;
    else if (newLocation.horizontalAccuracy > 50)
        self.rank = 2;
    else if (newLocation.horizontalAccuracy > 20)
        self.rank = 3;
    else self.rank = 4;
//    NSLog(@"rank is %i",self.rank);
    if(self.rank != kApp.gpsSignal){
        kApp.gpsSignal = self.rank;
        //广播
        NSString* NOTIFICATION_GPS = @"gps";
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GPS object:nil];
    }
    if(self.rank >= kApp.gpsLevel && newLocation.coordinate.latitude > 1 && newLocation.coordinate.longitude > 1){//误差小于50米
        self.userLocation_lat = newLocation.coordinate.latitude;
        self.userLocation_lon = newLocation.coordinate.longitude;
        self.altitude = newLocation.altitude;
        self.course = newLocation.course;
        self.speed = newLocation.speed;
    }
    self.gpsTime = [CNUtil getNowTimeDelta];
    if(kApp.isKnowCountry == NO){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"weather" object:nil];
        kApp.isInChina = [CNTestGEOS isInChina:newLocation.coordinate.longitude :newLocation.coordinate.latitude];
        kApp.isKnowCountry = YES;
        NSLog(@"是否在中国：%d",kApp.isInChina);
//        if(kApp.isInChina){
//            [self showAlert:@"在中国"];
//        }else{
//            [self showAlert:@"不在中国"];
//        }
    }
    
    
    //测试代码：
//    self.userLocation_lat = 39.968191+0.0003*self.num;
//    self.userLocation_lon = 116.390053;
//    self.gpsTime = [CNUtil getNowTime];
//    self.num++;
    //进入出发区自动启动代码
    if(kApp.canStartButNotInStartZone){
        NSLog(@"lat is %f,lon is %f",self.userLocation_lat,self.userLocation_lon);
        if([CNAppDelegate isInStartZone]){//进入了出发区
            NSLog(@"进入出发去区");
            NSString* NOTIFICATION_NOT_IN_START_ZONE = @"not_in_start_zone";
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NOT_IN_START_ZONE object:nil];
            kApp.canStartButNotInStartZone = NO;
            [self performSelector:@selector(startMatch) withObject:nil afterDelay:0.5];
        }
    }
    
    //以下必须等待与服务器同步完时间再做
    if(kApp.hasCheckTimeFromServer && self.gpsTime > 1 && self.gpsTime > kApp.match_start_timestamp && self.gpsTime < kApp.match_end_timestamp){
        if(kApp.isMatch == 1){//参赛
            kApp.match_inMatch = YES;
        }
    }
    if(kApp.hasCheckTimeFromServer && self.gpsTime > 1 && kApp.match_inMatch == YES && self.gpsTime > kApp.match_end_timestamp){//比赛结束时间
        if(kApp.hasFinishTeamMatch == NO){
            kApp.hasFinishTeamMatch = YES;
            if(kApp.isbaton == 1){
                [self finishMatch];
            }else{
                [CNAppDelegate ForceGoMatchPage:@"finishTeam"];
            }
        }
    }
}
- (void)startMatch{
    [CNAppDelegate ForceGoMatchPage:@"matchRun_normal"];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            //Do something...
            [manager stopUpdatingLocation];
            NSLog(@"异常提示：系统不允许要跑使用gps");
            [CNAppDelegate popupWarningGPSOpen];
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            //Do something else...
            break;
        default:
            break;
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
    [onepoint setObject:@"2" forKey:@"mstate"];
    [pointList addObject:onepoint];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString* pointJson = [jsonWriter stringWithObject:pointList];
    [params setObject:pointJson forKey:@"longitude"];
    kApp.networkHandler.delegate_endMatch = self;
    [kApp.networkHandler doRequest_endMatch:params];
}
- (void)endMatchInfoDidSuccess:(NSDictionary *)resultDic{
    [CNAppDelegate ForceGoMatchPage:@"finishTeam"];
}
- (void)endMatchInfoDidFailed:(NSString *)mes{
    
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end

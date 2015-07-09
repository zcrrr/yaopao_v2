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
@synthesize accuracy;


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
    self.accuracy = newLocation.horizontalAccuracy;
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
        kApp.isInChina = [CNUtil isInChina:newLocation.coordinate.longitude :newLocation.coordinate.latitude];
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
@end

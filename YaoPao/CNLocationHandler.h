//
//  CNLocationHandler.h
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CNNetworkHandler.h"

@interface CNLocationHandler : NSObject<CLLocationManagerDelegate,endMatchDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (assign, nonatomic) int isStart;
@property (assign, nonatomic) int rank;
@property (assign, nonatomic) double userLocation_lon;
@property (assign, nonatomic) double userLocation_lat;
@property (assign, nonatomic) double altitude;//高程
@property (assign, nonatomic) double course;//方向
@property (assign, nonatomic) double speed;//速度
@property (assign, nonatomic) long long gpsTime;//gps时间

@property (assign, nonatomic) int num;

- (void)startGetLocation;
- (void)stopLocation;

@end

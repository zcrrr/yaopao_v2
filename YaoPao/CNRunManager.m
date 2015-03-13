//
//  CNRunManager.m
//  YaoPao
//
//  Created by zc on 14-12-22.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunManager.h"
#import "CNUtil.h"
#import "CNGPSPoint.h"
#import "CNLocationHandler.h"
#import "OneKMInfo.h"
#import "OneMileInfo.h"
#import "OneMinuteInfo.h"

@implementation CNRunManager
@synthesize runType;
@synthesize howToMove;
@synthesize targetType;
@synthesize targetValue;
@synthesize runStatus;
@synthesize runway;
@synthesize feeling;
@synthesize remark;
@synthesize pictrue;
@synthesize timeInterval;
@synthesize everyXMinute;
@synthesize timerUpdate;
@synthesize startTimeStamp;
@synthesize endTimeStamp;
@synthesize startPauseTimeStamp;
@synthesize pauseSecond;
@synthesize targetKM;
@synthesize targetMile;
@synthesize targetMinute;
@synthesize pauseCount;

@synthesize distance;
@synthesize secondPerKm;
@synthesize secondPerMile;
@synthesize averSpeedKm;
@synthesize averSpeedMile;
@synthesize score;
@synthesize completePercent;
@synthesize altitudeAdd;
@synthesize altitudeReduce;
@synthesize dataKm;
@synthesize dataMin;
@synthesize dataMile;
@synthesize GPSList;

@synthesize testnum;

- (id)initData{
    self = [super init];//调用父类的构造方法
    if(self)
    {
        self.dataKm = [[NSMutableArray alloc]init];
        self.dataMile = [[NSMutableArray alloc]init];
        self.dataMin = [[NSMutableArray alloc]init];
        self.GPSList = [[NSMutableArray alloc]init];
    }
    return self;
}
- (id)initWithSecond:(int)second{
    self = [super init];//调用父类的构造方法
    if(self)
    {
        self.timeInterval = second;
    }
    return self;
}
- (void)startRun{
    self.startTimeStamp = [CNUtil getNowTime1000];// 起始时间
    self.endTimeStamp = 0;
    // 初始化变量
    self.runType = 1;
    self.runStatus = 1;
    self.dataKm = [[NSMutableArray alloc]init];
    self.dataMile = [[NSMutableArray alloc]init];
    self.dataMin = [[NSMutableArray alloc]init];
    self.GPSList = [[NSMutableArray alloc]init];
    self.altitudeAdd = 0;
    self.altitudeReduce = 0;
    self.distance = 0;
    self.secondPerKm = 0;
    self.secondPerMile = 0;
    self.averSpeedKm = 0;
    self.averSpeedMile = 0;
    self.score = 0;
    self.targetKM = 1;
    self.targetMile = 1;
    self.targetMinute = 1;
    self.everyXMinute = 1;
    [self startTimer];
}
- (void)finishOneRun{
    //先去掉最后一段暂停的gps点：
    int count = [self.GPSList count];
    if(count > self.pauseCount){//去掉最后一小段从暂停到完成的距离
        for(int i=self.pauseCount;i<count;i++){
            [self.GPSList removeLastObject];
        }
    }
    //算上暂停时间
    self.pauseSecond += (int)([CNUtil getNowTime1000] - self.startPauseTimeStamp);
    self.endTimeStamp = [CNUtil getNowTime1000];
    [self stopTimer];
    // 计算一下积分的零头
    if (self.distance < 1000) {
        self.score = 1;
    } else {
        int meter = (int) self.distance % 1000;
        if (meter > 500) {
            self.score += 2;
        }
    }
}
- (void)saveOneRecord{
    
}
- (int)during{
    long long nowTimeStamp;
    if(self.endTimeStamp < 1){//正在运动
        nowTimeStamp = [CNUtil getNowTime1000];
    }else{
        nowTimeStamp = self.endTimeStamp;
    }
    int second = (int) (nowTimeStamp - self.startTimeStamp) - pauseSecond;
    return second >= 0 ? second : 0;
}
- (void)changeRunStatus:(int)status{
    if (self.runType == 1) {// 如果是日常跑步，计算pauseSecond；
        if (self.runStatus == 2 && status == 1) {// 由暂停变运动
            self.pauseSecond += (int)([CNUtil getNowTime1000] - self.startPauseTimeStamp);
        } else if (self.runStatus == 1 && status == 2) {// 由运动变暂停
            self.pauseCount = [self.GPSList count];
            self.startPauseTimeStamp = [CNUtil getNowTime1000];
        }
    }
    self.runStatus = status;
}
- (void)startTimer{
    [self updateDate];
    self.timerUpdate = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(updateDate) userInfo:nil repeats:YES];
}
- (void)stopTimer{
    [self.timerUpdate invalidate];
}
- (CNGPSPoint*)getOnePoint{
#ifdef SIMULATORTEST
    self.testnum++;
    return [[CNGPSPoint alloc]initWithLon:116.390053
                                   andLat:(39.968191 + 0.001 * testnum)
                                andStatus:self.runStatus
                                  andTime:[CNUtil getNowTime1000]
                                andCourse:0
                              andAltitude:0
                                 andSpeed:0];
#else
    return [[CNGPSPoint alloc]initWithLon:kApp.locationHandler.userLocation_lon
                                   andLat:kApp.locationHandler.userLocation_lat
                                andStatus:self.runStatus
                                  andTime:[CNUtil getNowTime1000]
                                andCourse:kApp.locationHandler.course
                              andAltitude:kApp.locationHandler.altitude
                                 andSpeed:kApp.locationHandler.speed];
# endif
}
- (void)updateDate
{
    CNGPSPoint* gpsPoint = [self getOnePoint];
    if ([self.GPSList count] == 0) {
        [self.GPSList addObject:gpsPoint];
        return;
    }
    // 不是第一个点
    CNGPSPoint* lastPoint = [self.GPSList lastObject];
    CLLocation *current=[[CLLocation alloc] initWithLatitude:gpsPoint.lat longitude:gpsPoint.lon];
    CLLocation *before=[[CLLocation alloc] initWithLatitude:lastPoint.lat longitude:lastPoint.lon];
    CLLocationDistance meter=[current distanceFromLocation:before];
    if (meter < 5) {// 离得特别近
        if (gpsPoint.status == lastPoint.status) {// 两点状态一样
            // 不保存这个点，算一下配速和进度条
            if (gpsPoint.status == 1) {// 运动中，计算
                // 计算一下平均配速：
                if (self.distance < 1) {// 距离太短
                    self.secondPerKm = 0;
                } else {
                    self.secondPerKm = [self during] / distance;
                }
            }
            lastPoint.time = gpsPoint.time;// 就不入数组了，而是更新时间
        } else {// 两点状态不一样，要计算配速、进度条和距离
            if (gpsPoint.status == 1) {// 运动中，计算
                // 计算一下平均配速：
                self.secondPerKm = [self during] / distance;
                self.distance += meter;
            }
            [GPSList addObject:gpsPoint];
        }
    } else {
        if (gpsPoint.status == 1) {
            // 计算一下平均配速：
            self.distance += meter;
            self.secondPerKm = [self during] / distance;
            // 计算一下高程增加量和高程减少量
            double altitudeOffsize = gpsPoint.altitude - lastPoint.altitude;
            if (altitudeOffsize > 0) {
                self.altitudeAdd += altitudeOffsize;
            } else {
                self.altitudeReduce += -altitudeOffsize;
            }
        }
        [GPSList addObject:gpsPoint];
    }
    // 算一下完成目标百分比
    switch (self.targetType) {
        case 1:// 自由
        {
            self.completePercent = 1;
            break;
        }
        case 2:// 距离
        {
            if (self.distance <= self.targetValue) {
                self.completePercent = (float)self.distance / (float)self.targetValue;
            } else {
                self.completePercent = 1;
            }
            break;
        }
        case 3:// 时间
        {
            if ([self during] <= self.targetValue) {
                self.completePercent = (float) [self during] / (float)self.targetValue;
            } else {
                self.completePercent = 1;
            }
            break;
        }
        default:
            break;
    }
    // 如果是刚好到达整公里，则计算一下相关数据
    if (self.distance > self.targetKM * 1000) {// 刚到达整公里
        int thisKmDistance = 0;
        int thisKmDuring = 0;
        double thisKmAltitudeAdd = 0;
        double thisKmAltitudeReduce = 0;
        if ([self.dataKm count] == 0) {
            thisKmDistance = self.distance;
            thisKmDuring = [self during];
            thisKmAltitudeAdd = self.altitudeAdd;
            thisKmAltitudeReduce = self.altitudeReduce;
        } else {
            OneKMInfo* lastKm = [dataKm lastObject];
            thisKmDistance = self.distance - lastKm.totalDistance;
            thisKmDuring = [self during] - lastKm.totalDuring;
            thisKmAltitudeAdd = self.altitudeAdd - lastKm.totalAltitudeAdd;
            thisKmAltitudeReduce = self.altitudeReduce - lastKm.totalAltitudeReduce;
        }
        self.score += [self score4speed:(thisKmDuring / 60000)];// 计算积分
        [dataKm addObject:[[OneKMInfo alloc]initWithNumber:targetKM
                                                    andLon:gpsPoint.lon
                                                    andLat:gpsPoint.lat
                                          andTotalDistance:self.distance
                                               andDisTance:thisKmDistance
                                            andTotalDuring:[self during]
                                                 andDuring:thisKmDuring
                                       andTotalAltitudeAdd:self.altitudeAdd
                                            andAltitudeAdd:thisKmAltitudeAdd
                                    andTotalAltitudeReduce:self.altitudeReduce
                                         andAltitudeReduce:thisKmAltitudeReduce]];
        self.targetKM++;
    }
    if (self.distance > self.targetMile * 1609.344) {// 刚到达整英里
        int thisMileDistance = 0;
        int thisMileDuring = 0;
        double thisMileAltitudeAdd = 0;
        double thisMileAltitudeReduce = 0;
        if ([self.dataMile count] == 0) {
            thisMileDistance = self.distance;
            thisMileDuring = [self during];
            thisMileAltitudeAdd = self.altitudeAdd;
            thisMileAltitudeReduce = self.altitudeReduce;
        } else {
            OneMileInfo* lastMile = [dataMile lastObject];
            thisMileDistance = self.distance - lastMile.totalDistance;
            thisMileDuring = [self during] - lastMile.totalDuring;
            thisMileAltitudeAdd = self.altitudeAdd - lastMile.totalAltitudeAdd;
            thisMileAltitudeReduce = self.altitudeReduce - lastMile.totalAltitudeReduce;
        }
        [dataMile addObject:[[OneMileInfo alloc]initWithNumber:targetMile
                                                    andLon:gpsPoint.lon
                                                    andLat:gpsPoint.lat
                                          andTotalDistance:self.distance
                                               andDisTance:thisMileDistance
                                            andTotalDuring:[self during]
                                                 andDuring:thisMileDuring
                                       andTotalAltitudeAdd:self.altitudeAdd
                                            andAltitudeAdd:thisMileAltitudeAdd
                                    andTotalAltitudeReduce:self.altitudeReduce
                                         andAltitudeReduce:thisMileAltitudeReduce]];
        self.targetMile++;
    }
    if ([self during] > self.targetMinute * everyXMinute * 60 * 1000 && self.runStatus == 1) {// 刚到达整分钟，切正在运动的时候
        NSLog(@"during is %i",[self during]);
        int thisMinDistance = 0;
        int thisMinDuring = 0;
        double thisMinAltitudeAdd = 0;
        double thisMinAltitudeReduce = 0;
        if ([self.dataMin count] == 0) {
            thisMinDistance = self.distance;
            thisMinDuring = [self during];
            thisMinAltitudeAdd = self.altitudeAdd;
            thisMinAltitudeReduce = self.altitudeReduce;
        } else {
            OneMinuteInfo* lastMinute = [dataMin lastObject];
            thisMinDistance = self.distance - lastMinute.totalDistance;
            thisMinDuring = [self during] - lastMinute.totalDuring;
            thisMinAltitudeAdd = self.altitudeAdd - lastMinute.totalAltitudeAdd;
            thisMinAltitudeReduce = self.altitudeReduce - lastMinute.totalAltitudeReduce;
        }
        [dataMin addObject:[[OneMinuteInfo alloc]initWithNumber:targetMinute
                                                        andLon:gpsPoint.lon
                                                        andLat:gpsPoint.lat
                                              andTotalDistance:self.distance
                                                   andDisTance:thisMinDistance
                                                andTotalDuring:[self during]
                                                     andDuring:thisMinDuring
                                           andTotalAltitudeAdd:self.altitudeAdd
                                                andAltitudeAdd:thisMinAltitudeAdd
                                        andTotalAltitudeReduce:self.altitudeReduce
                                             andAltitudeReduce:thisMinAltitudeReduce]];
        self.targetMinute++;
    }
//    NSLog(@"distance is %f",distance);
//    NSLog(@"pacekm is %i",paceKm);
//    NSLog(@"gps count is %i",[self.GPSList count]);
//    NSLog(@"km count is %i",[self.dataKm count]);
//    NSLog(@"mile count is %i",[self.dataMile count]);
//    NSLog(@"min count is %i",[self.dataMin count]);
//    NSLog(@"------------------------------------------");

}
- (int)score4speed:(int)minute{
    if (minute < 5) {
        return 12;
    }
    if (minute < 6) {
        return 10;
    }
    if (minute < 7) {
        return 9;
    }
    if (minute < 8) {
        return 8;
    }
    if (minute < 9) {
        return 7;
    }
    if (minute < 10) {
        return 6;
    }
    if (minute < 11) {
        return 5;
    }
    if (minute < 12) {
        return 4;
    }
    return 3;
}


@end

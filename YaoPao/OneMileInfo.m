//
//  OneMileInfo.m
//  YaoPao
//
//  Created by zc on 14-12-22.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "OneMileInfo.h"

@implementation OneMileInfo

@synthesize number;
@synthesize lon;
@synthesize lat;
@synthesize totalDistance;
@synthesize distance;
@synthesize totalDuring;
@synthesize during;
@synthesize totalAltitudeAdd;
@synthesize altitudeAdd;
@synthesize totalAltitudeReduce;
@synthesize altitudeReduce;

- (id)initWithNumber:(int)number1 andLon:(double)lon1 andLat:(double)lat1 andTotalDistance:(int)totalDistance1 andDisTance:(int)distance1 andTotalDuring:(int)totalDuring1 andDuring:(int)during1 andTotalAltitudeAdd:(double)totalAltitudeAdd1 andAltitudeAdd:(double)altitudeAdd1 andTotalAltitudeReduce:(double)totalAltitudeReduce1 andAltitudeReduce:(double)altitudeReduce1{
    self = [super init];//调用父类的构造方法
    if(self)
    {
        self.number = number1;
        self.lon = lon1;
        self.lat = lat1;
        self.totalDistance = totalDistance1;
        self.distance = distance1;
        self.totalDuring = totalDuring1;
        self.during = during1;
        self.totalAltitudeAdd = totalAltitudeAdd1;
        self.altitudeAdd = altitudeAdd1;
        self.totalAltitudeReduce = totalAltitudeReduce1;
        self.altitudeReduce = altitudeReduce1;
    }
    
    return self;
}
- (id)initWithNumber:(int)number1 andLon:(double)lon1 andLat:(double)lat1 andDisTance:(int)distance1 andDuring:(int)during1 andAltitudeAdd:(double)altitudeAdd1 andAltitudeReduce:(double)altitudeReduce1{
    self = [super init];//调用父类的构造方法
    if(self)
    {
        self.number = number1;
        self.lon = lon1;
        self.lat = lat1;
        self.distance = distance1;
        self.during = during1;
        self.altitudeAdd = altitudeAdd1;
        self.altitudeReduce = altitudeReduce1;
    }
    
    return self;
}

@end

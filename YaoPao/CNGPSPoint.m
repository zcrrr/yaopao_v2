//
//  CNGPSPoint.m
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNGPSPoint.h"

@implementation CNGPSPoint

@synthesize status;
@synthesize time;
@synthesize lon;
@synthesize lat;
@synthesize speed;
@synthesize course;
@synthesize altitude;


- (id)proxyForJson{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",self.status],@"status",nil];
}

- (id)initWithLon:(double)lon1 andLat:(double)lat1 andStatus:(int)status1 andTime:(long long)time1 andCourse:(int)course1 andAltitude:(double)altitude1 andSpeed:(int)speed1{
    self = [super init];//调用父类的构造方法
    //判断self是否为nil
    if(self)
    {
        self.lon = lon1;
        self.lat = lat1;
        self.status = status1;
        self.time = time1;
        self.course = course1;
        self.altitude = altitude1;
        self.speed = speed1;
    }
    
    return self;
}
@end

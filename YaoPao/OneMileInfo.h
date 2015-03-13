//
//  OneMileInfo.h
//  YaoPao
//
//  Created by zc on 14-12-22.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OneMileInfo : NSObject

@property(assign, nonatomic) int number;//第几英里
@property(assign, nonatomic) double lon;
@property(assign, nonatomic) double lat;
@property(assign, nonatomic) int totalDistance;//跑完这一英里一共的距离（加上之前的，是从运动开始算起）
@property(assign, nonatomic) int distance;//多少米，例如1005米
@property(assign, nonatomic) int totalDuring;//跑完这个英里一共用的时间（加上之前的，是从运动开始算起）
@property(assign, nonatomic) int during;//该英里用时
@property(assign, nonatomic) double totalAltitudeAdd;//跑完这一英里一共的高程增加值
@property(assign, nonatomic) double altitudeAdd;//每英里高程增加值
@property(assign, nonatomic) double totalAltitudeReduce;//跑完这一英里一共的高程降低值
@property(assign, nonatomic) double altitudeReduce;//每英里总高程降低值

- (id)initWithNumber:(int)number1 andLon:(double)lon1 andLat:(double)lat1 andTotalDistance:(int)totalDistance1 andDisTance:(int)distance1 andTotalDuring:(int)totalDuring1 andDuring:(int)during1 andTotalAltitudeAdd:(double)totalAltitudeAdd1 andAltitudeAdd:(double)altitudeAdd1 andTotalAltitudeReduce:(double)totalAltitudeReduce1 andAltitudeReduce:(double)altitudeReduce1;

- (id)initWithNumber:(int)number1 andLon:(double)lon1 andLat:(double)lat1 andDisTance:(int)distance1 andDuring:(int)during1 andAltitudeAdd:(double)altitudeAdd1 andAltitudeReduce:(double)altitudeReduce1;


@end

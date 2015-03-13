//
//  CNUtil.h
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNUtil : NSObject
+ (long long)getNowTime;
+ (long long)getNowTime1000;
+ (NSString*)getTimeFromTimestamp:(long long)timestamp;
+ (NSString*)dateStringFromTimeStamp:(long long)timestamp;
+ (NSString*)weekday2chinese:(int)weekday;
+ (NSString*)duringTimeStringFromSecond:(int)duringSecond;
+ (NSString*)pspeedStringFromSecond:(int)second;
+ (float)speedFromPspeed:(int)second;
+ (long long)getNowTimeDelta;
+ (NSString*)getMatchStage;
+ (NSString*)getYearMonth:(long long)timestamp;
+ (BOOL)canNetWork;
@end

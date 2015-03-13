//
//  CNUtil.m
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNUtil.h"
#import "Reachability.h"

@implementation CNUtil

+ (long long)getNowTime{
    NSDate *datenow = [NSDate date];
    //    NSLog(@"%@",datenow);
    NSTimeInterval timeinterval = [datenow timeIntervalSince1970];
    return timeinterval;
}
+ (long long)getNowTime1000{
    NSDate *datenow = [NSDate date];
    NSTimeInterval timeinterval = [datenow timeIntervalSince1970]*1000;
    return timeinterval;
}
+ (long long)getNowTimeDelta{
    return [CNUtil getNowTime]+kApp.deltaTime;
}
+ (NSString*)getTimeFromTimestamp:(long long)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}
+ (NSString*)dateStringFromTimeStamp:(long long)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = [componets weekday];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy年M月d日 周%@ HH:mm",[CNUtil weekday2chinese:weekday]]];
    return [dateFormatter stringFromDate:date];
}
+ (NSString*)weekday2chinese:(int)weekday{
    switch (weekday) {
        case 1:
            return @"日";
            break;
        case 2:
            return @"一";
            break;
        case 3:
            return @"二";
            break;
        case 4:
            return @"三";
            break;
        case 5:
            return @"四";
            break;
        case 6:
            return @"五";
            break;
        case 7:
            return @"六";
            break;
            
        default:
            return @"unknown";
            break;
    }
}
+ (NSString*)duringTimeStringFromSecond:(int)duringSecond{
    int hour = duringSecond/3600;
    int minute = (duringSecond-hour*3600)/60;
    int second = duringSecond%60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
}
+ (NSString*)pspeedStringFromSecond:(int)second{
    if(second < 0){
        return @"00'00\"";
    }
    int minute2 = second/60;
    int second2 = second%60;
    return [NSString stringWithFormat:@"%02i'%02i\"",minute2,second2];
}
+ (float)speedFromPspeed:(int)second{
    float hour = (float)second/3600.0;
    return 1.0/hour;
}
+ (NSString*)getMatchStage{
    long long nowTimeSecond = [CNUtil getNowTimeDelta];
    if(nowTimeSecond < kApp.match_before5min_timestamp){
        return @"beforeMatch";
    }else if(nowTimeSecond >= kApp.match_before5min_timestamp&&nowTimeSecond<kApp.match_start_timestamp){
        return @"closeToMatch";
    }else if(nowTimeSecond >= kApp.match_start_timestamp&&nowTimeSecond<=kApp.match_end_timestamp){
        return @"isMatching";
    }else{
        return @"afterMatch";
    }
}
+ (NSString*)getYearMonth:(long long)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMM"];
    return [dateFormatter stringFromDate:date];
}
+ (BOOL)canNetWork{
    Reachability *r= [Reachability reachabilityForInternetConnection];
    if ([r currentReachabilityStatus] == NotReachable) {
        NSLog(@"无网络连接");
        return NO;
    }else{
        NSLog(@"有网络连接");
        return YES;
    }
}

@end

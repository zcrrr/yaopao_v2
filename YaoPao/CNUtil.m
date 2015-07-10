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
+ (long long)getTimestampFromDate:(NSString*)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSTimeInterval timeinterval = [date timeIntervalSince1970];
    return timeinterval;
}
+ (NSString*)getTimeFromTimestamp_ymdhm:(long long)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}
+ (NSString*)getTimeFromTimestamp_ymd:(long long)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}
+ (NSString*)getTimeFromTimestamp_ms:(long long)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}
+ (NSString*)dateStringFromTimeStamp:(long long)timestamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = (int)[componets weekday];
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
    if(hour > 0){
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d",minute,second];
    }
    
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
+ (NSMutableDictionary*)getRunSetting{
    NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
    NSMutableDictionary* runSettingDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(runSettingDic == nil){
        runSettingDic = [[NSMutableDictionary alloc]init];
        [runSettingDic setObject:@"2" forKey:@"targetType"];
        [runSettingDic setObject:@"5" forKey:@"distance"];
        [runSettingDic setObject:@"30" forKey:@"time"];
        [runSettingDic setObject:@"1" forKey:@"howToMove"];
        [runSettingDic setObject:@"1" forKey:@"countdown"];
        [runSettingDic setObject:@"1" forKey:@"voice"];
    }
    return runSettingDic;
}
//可以得到targetType、targetDes、targetValue、typeDes、countdown、voice
+ (NSMutableDictionary*)getRunSettingWhole{
    NSMutableDictionary* runSettingDic = [self getRunSetting];
    int targetType = [[runSettingDic objectForKey:@"targetType"]intValue];
    switch (targetType) {
        case 1:
            [runSettingDic setObject:@"自由" forKey:@"targetDes"];
            [runSettingDic setObject:@"0" forKey:@"targetValue"];
            [runSettingDic setObject:@"targetType1.png" forKey:@"typeImageName"];
            break;
        case 2:
            [runSettingDic setObject:[NSString stringWithFormat:@"%@km",[runSettingDic objectForKey:@"distance"]] forKey:@"targetDes"];
            [runSettingDic setObject:[NSString stringWithFormat:@"%i",[[runSettingDic objectForKey:@"distance"] intValue]*1000] forKey:@"targetValue"];
            [runSettingDic setObject:@"targetType2.png" forKey:@"typeImageName"];
            break;
        case 3:
        {
            int second = [[runSettingDic objectForKey:@"time"]intValue]*60;
            NSString* timestr = [CNUtil duringTimeStringFromSecond:second];
            [runSettingDic setObject:timestr forKey:@"targetDes"];
            [runSettingDic setObject:[NSString stringWithFormat:@"%i",[[runSettingDic objectForKey:@"time"]intValue]*60*1000] forKey:@"targetValue"];
            [runSettingDic setObject:@"targetType3.png" forKey:@"typeImageName"];
            break;
        }
        default:
            break;
    }
    int howToMove = [[runSettingDic objectForKey:@"howToMove"]intValue];
    switch (howToMove) {
        case 1:
            [runSettingDic setObject:@"跑步" forKey:@"typeDes"];
            [runSettingDic setObject:@"howToMove1.png" forKey:@"htmImageName"];
            break;
        case 2:
            [runSettingDic setObject:@"步行" forKey:@"typeDes"];
            [runSettingDic setObject:@"howToMove2.png" forKey:@"htmImageName"];
            break;
        case 3:
            [runSettingDic setObject:@"自行车骑行" forKey:@"typeDes"];
            [runSettingDic setObject:@"howToMove3.png" forKey:@"htmImageName"];
            break;
            
        default:
            break;
    }
    return runSettingDic;
}
+ (NSMutableDictionary*)getPersonalSummary{
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
        [record_dic setObject:@"0" forKey:@"total_score"];
    }
    return record_dic;
}
+ (NSString*)dayOrNight{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self getNowTime]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    int hour = [strDate intValue];
    if(hour >= 6 && hour <= 18){
        return @"d";
    }else{
        return @"n";
    }
}
+ (BOOL)isInChina:(double)lon :(double)lat{
    if(lon > 73.740192 && lon < 135.039985 && lat > 18.156599 && lat < 53.545317){
        return YES;
    }else{
        return NO;
    }
}
+ (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
+ (void)saveImageToIphone4Test:(NSString*)name :(UIImage*)imageToSave{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png",name]];
    NSLog(@"存储到本地的路径：%@",filePath);
    [UIImagePNGRepresentation(imageToSave) writeToFile: filePath atomically:YES];
}
+ (void)appendUserOperation:(NSString*)str{
#ifdef kTestFlight
//    NSLog(@"userOperation is %@",kApp.userOperation);
    [kApp.userOperation appendString:str];
    [kApp.userOperation appendString:@"\n"];
    
#else
    
# endif
}
+ (void)checkUserPermission{
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
        NSLog(@"用户禁止了摄像头");
        [CNUtil showAlert:@"请前往“设置-隐私-相机”，允许要跑访问您的摄像头"];
    }
}

@end

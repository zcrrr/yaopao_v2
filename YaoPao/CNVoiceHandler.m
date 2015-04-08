//
//  CNVoiceHandler.m
//  YaoPao
//
//  Created by zc on 14-9-28.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNVoiceHandler.h"

@implementation CNVoiceHandler
@synthesize player;
@synthesize arrayOfTracks;

- (void)initPlayer{
    self.arrayOfTracks= [[NSMutableArray alloc]init];
    //后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
- (void)startPlay{//开始播放
    if([self.arrayOfTracks count]>0){
        NSString *path = [[NSBundle mainBundle] pathForResource:[self.arrayOfTracks objectAtIndex:0] ofType:@"mp3"];
        NSData* data = [NSData dataWithContentsOfFile:path];
        self.player = [[AVAudioPlayer alloc]initWithData:data error:nil];
        self.player.volume = 5.0;
        self.player.delegate = self;
        [self.player play];
        NSLog(@"播放音频%@",[self.arrayOfTracks objectAtIndex:0]);
    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"单个音频播放完毕");
    [self.arrayOfTracks removeObjectAtIndex:0];
    if([self.arrayOfTracks count]==0){
        NSLog(@"队列播放完毕");
    }else{
        NSString *string = [[NSBundle mainBundle] pathForResource:[self.arrayOfTracks objectAtIndex:0] ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:string];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.player.delegate = self;
        self.player.volume = 5.0;
        [self.player play];
        NSLog(@"播放音频%@",[self.arrayOfTracks objectAtIndex:0]);
    }
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"error");
}
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    NSLog(@"interruption");
    
}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    NSLog(@"EndInterruption");
}
- (NSMutableArray*)voiceOfTime:(int)second{
    int ss = second % 60;
    int mm = ( second / 60) % 60;
    int hh = ( second / 60) / 60;
    int day = hh / 24;
    int week = day / 7;
    hh = hh % 24;
    day = day % 7;
    NSMutableArray* r = [[NSMutableArray alloc]init];
    NSMutableArray* temp;
    // 星期
    if (week > 0) {
        temp = [self voiceOf5Digit:week :YES :NO];
        for(int i=0;i<[temp count];i++){
            [r addObject:[temp objectAtIndex:i]];
        }
        [r addObject:@"110028"];
    }
    // 天
    if (day > 0) {
        temp = [self voiceOf2Digit:day :YES :NO];
        for(int i=0;i<[temp count];i++){
            [r addObject:[temp objectAtIndex:i]];
        }
        [r addObject:@"110026"];
    }
    // 小时
    if (hh > 0) {
        if (week > 0 && day == 0)
            [r addObject:@"100000"];
        temp = [self voiceOf2Digit:hh :YES :NO];
        for(int i=0;i<[temp count];i++){
            [r addObject:[temp objectAtIndex:i]];
        }
        [r addObject:@"110025"];
    }
    // 分
    if (mm > 0&& ((week > 0 && (day == 0 || hh == 0)) || (day > 0 && hh == 0))) {
        [r addObject:@"100000"];
    }
    temp = [self voiceOf2Digit:mm :YES :NO];
    for(int i=0;i<[temp count];i++){
        [r addObject:[temp objectAtIndex:i]];
    }
    [r addObject:@"110022"];
    // 秒
    temp = [self voiceOf2Digit:ss :NO :YES];
    for(int i=0;i<[temp count];i++){
        [r addObject:[temp objectAtIndex:i]];
    }
    [r addObject:@"110021"];
    return r;
}
- (NSMutableArray*) voiceOfTime_munite:(int)minute {
    if (minute < 0)
        minute = 0;
    
    int mm = minute % 60;
    int hh = minute / 60;
    int day = hh / 24;
    int week = day / 7;
    hh = hh % 24;
    day = day % 7;
    
    NSMutableArray* r = [[NSMutableArray alloc]init];
    NSMutableArray* temp;
    
    // 星期
    if (week > 0) {
        temp = [self voiceOf5Digit:week :YES :NO];
        for(int i=0;i<[temp count];i++){
            [r addObject:[temp objectAtIndex:i]];
        }
        [r addObject:@"110028"];
    }
    // 天
    if (day > 0) {
        temp = [self voiceOf2Digit:day :YES :NO];
        for(int i=0;i<[temp count];i++){
            [r addObject:[temp objectAtIndex:i]];
        }
        [r addObject:@"110026"];
    }
    // 小时
    if (hh > 0) {
        if (week > 0 && day == 0)
            [r addObject:@"100000"];
        temp = [self voiceOf2Digit:hh :YES :NO];
        for(int i=0;i<[temp count];i++){
            [r addObject:[temp objectAtIndex:i]];
        }
        [r addObject:@"110025"];
    }
    // 分
    if (mm > 0) {
        if (week == 0 && day == 0 && hh == 0) {
            temp = [self voiceOf2Digit:mm :YES :NO];
        } else {
            temp = [self voiceOf2Digit:mm :YES :YES];
        }
        for(int i=0;i<[temp count];i++){
            [r addObject:[temp objectAtIndex:i]];
        }
        [r addObject:@"110024"];
    } else {
        if (week == 0 && day == 0 && hh == 0) {
            [r addObject:@"100000"];
            [r addObject:@"110024"];
        }
    }
    
    return r;
}
- (NSMutableArray*) voiceOf5Digit:(int)src :(BOOL)isLiang :(BOOL)isLing {
    if (src < 0 || src > 99999) {
        return nil;
    }
    
    if (src < 100) {
        return [self voiceOf2Digit:src :isLiang :isLing];
    }
    
    int d[6];
    d[5] = src / 10000;
    d[4] = src % 10000 / 1000;
    d[3] = src % 1000 / 100;
    d[2] = src % 100 / 10;
    d[1] = src % 10;
    d[0] = src;
    
    NSMutableArray* r;
    BOOL isRoundNumber;
    if (d[1] == 0 && d[2] == 0) {
        r = [[NSMutableArray alloc]init];
        isRoundNumber = YES;
    } else {
        r = [self voiceOf2Digit:d[2] * 10 + d[1] :NO :NO];
        isRoundNumber = NO;
    }
    
    if (d[3] != 0) {
        if (!isRoundNumber && d[2] == 0)
            [r insertObject:@"100000" atIndex:0];
        if (d[2] == 1)
            [r insertObject:@"100001" atIndex:0];
        if (isLiang && d[3] == 2) {
            [r insertObject:@"110011" atIndex:0];
        } else {
            [r insertObject:[NSString stringWithFormat:@"%i",(100000 + d[3])] atIndex:0];
        }
    }
    
    if (d[4] != 0) {
        if (!isRoundNumber && d[3] == 0) {
            if (d[2] == 1)
                [r insertObject:@"100001" atIndex:0];
            [r insertObject:@"100000" atIndex:0];
        }
        [r insertObject:@"110013" atIndex:0];
        if (isLiang && d[4] == 2) {
            [r insertObject:@"110011" atIndex:0];
        } else {
            [r insertObject:[NSString stringWithFormat:@"%i",(100000 + d[4])] atIndex:0];
        }
    }
    
    if (d[5] != 0) {
        if (!isRoundNumber && d[4] == 0) {
            if (d[3] == 0 && d[2] == 1)
                [r insertObject:@"100001" atIndex:0];
            [r insertObject:@"100000" atIndex:0];
        }
        [r insertObject:@"110014" atIndex:0];
        if (isLiang && d[5] == 2) {
            [r insertObject:@"110011" atIndex:0];
        } else {
            [r insertObject:[NSString stringWithFormat:@"%i",(100000 + d[5])] atIndex:0];
        }
    }
    
    return r;
}
- (NSMutableArray*) voiceOf2Digit:(int)src :(BOOL)isLiang :(BOOL)isLing{
    if (src < 0 || src > 99) {
        return nil;
    }
    
    NSMutableArray* r = [[NSMutableArray alloc]init];
    
    if (src >= 0 && src < 60) {
        if (isLiang && src == 2) {
            [r addObject:@"110011"];
            if (isLing && src >= 1 && src <= 9) {
                [r insertObject:@"100000" atIndex:0];
            }
        } else {
            [r addObject:[NSString stringWithFormat:@"%i",(100000 + src)]];
            if (isLing && src >= 1 && src <= 9) {
                [r insertObject:@"100000" atIndex:0];
            }
        }
        return r;
    }
    
    int d[3];
    d[2] = src % 100 / 10;
    d[1] = src % 10;
    d[0] = src;
    
    if (d[1] != 0) {
        [r addObject:[NSString stringWithFormat:@"%i",(100000 + d[1])]];
    }
    if (d[2] != 0) {
        [r insertObject:@"100010" atIndex:0];
        [r insertObject:[NSString stringWithFormat:@"%i",(100000 + d[1])] atIndex:0];
    }
    return r;
}

- (NSMutableArray*)voiceOfDouble:(double)number{
    if (number < 0)
        number = 0;
    
    long l = round(number * 100);
    int integer = (int) (l / 100);
    int decimal = (int) (l % 100);
    
    NSMutableArray* r = [[NSMutableArray alloc]init];
    NSMutableArray* temp;
    
    if (integer == 2 && decimal == 0) {
        [r addObject:@"110011"];
    } else if (integer == 200 && decimal == 0) {
        [r addObject:@"110011"];
        [r addObject:@"110012"];
    } else if (integer == 2000 && decimal == 0) {
        [r addObject:@"110011"];
        [r addObject:@"110013"];
    } else if (integer == 20000 && decimal == 0) {
        [r addObject:@"110011"];
        [r addObject:@"110014"];
    } else {
        r = [self voiceOf5Digit:integer :NO :NO];
        if (decimal != 0) {
            [r addObject:@"110001"];
            temp = [self voiceOf2Digit:decimal / 10 :NO :NO];
            for(int i=0;i<[temp count];i++){
                [r addObject:[temp objectAtIndex:i]];
            }
            if (decimal % 10 != 0) {
                temp = [self voiceOf2Digit:decimal % 10 :NO :NO];
                for(int i=0;i<[temp count];i++){
                    [r addObject:[temp objectAtIndex:i]];
                }
            }
        }
    }
    return r;
}
- (void)voiceOfapp:(NSString*)occasion :(NSDictionary*)params{
    //测试代码
#ifdef SIMULATORTEST
//    return;
#else
# endif
    if(kApp.voiceOn == 0){
        return;
    }
    double distance = 0;
    int second = 0;
    int speed = 0;
    int km = 0;//第几公里
    double target_distance = 0.0;//目标公里数
    int munite = 0;//整5分钟
    int target_second = 0;//时间目标
    double distanceFromTakeOver = 0.0;//距离交接区
    if(params != nil){
        distance = [[params objectForKey:@"distance"]doubleValue]/1000.0;
        second = [[params objectForKey:@"second"]intValue];
        speed = 1.0/distance*second;
        km = [[params objectForKey:@"km"]intValue];
        target_distance = [[params objectForKey:@"target_distance"]doubleValue]/1000.0;
        munite = [[params objectForKey:@"munite"]intValue];
        target_second = [[params objectForKey:@"target_second"]intValue];
        distanceFromTakeOver = [[params objectForKey:@"distanceFromTakeOver"]doubleValue]/1000.0;
    }
    NSMutableArray* voiceArray = [[NSMutableArray alloc]init];
    if([occasion isEqualToString:@"run_start"]){
        [voiceArray addObject:@"120201"];
    }else if([occasion isEqualToString:@"run_pause"]){
        [voiceArray addObject:@"120202"];
    }else if([occasion isEqualToString:@"run_continue"]){
        [voiceArray addObject:@"120203"];
    }else if([occasion isEqualToString:@"run_complete"]){
        [voiceArray addObject:@"120204"];
        [voiceArray addObject:@"120211"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120212"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
    }else if([occasion isEqualToString:@"every_km"]){
        [voiceArray addObject:@"120221"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:km]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120212"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        [voiceArray addObject:@"120213"];
        if(km == 1){
            [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        }else if(km == 2){
            [voiceArray addObjectsFromArray:[self voiceOfTime:second/2]];
        }else{
            [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
        }
    }else if([occasion isEqualToString:@"half_target_dis"]){
        [voiceArray addObject:@"120101"];
        [voiceArray addObject:@"120223"];
        [voiceArray addObject:@"120222"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:target_distance/2.0]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120212"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
    }else if([occasion isEqualToString:@"every_km_and_close_to_target"]){
        [voiceArray addObject:@"120102"];
        [voiceArray addObject:@"120224"];
        [voiceArray addObject:@"120222"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:target_distance-km]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120212"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
    }else if([occasion isEqualToString:@"reach_target_distance"]){
        [voiceArray addObject:@"120103"];
        [voiceArray addObject:@"120226"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:target_distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120227"];
        [voiceArray addObject:@"120212"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        [voiceArray addObject:@"120213"];
        if(km == 1){
            [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        }else if(km == 2){
            [voiceArray addObjectsFromArray:[self voiceOfTime:second/2]];
        }else{
            [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
        }
    }else if([occasion isEqualToString:@"every_km_and_pass_target"]){
        [voiceArray addObject:@"120221"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:km]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120225"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:km-target_distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120212"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        [voiceArray addObject:@"120213"];
        if(km == 1){
            [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        }else if(km == 2){
            [voiceArray addObjectsFromArray:[self voiceOfTime:second/2]];
        }else{
            [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
        }
    }else if([occasion isEqualToString:@"every_five_munite"]){
        [voiceArray addObject:@"120221"];
        [voiceArray addObjectsFromArray:[self voiceOfTime_munite:munite*kVoiceTimeInterval]];
        [voiceArray addObject:@"120211"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
    }else if([occasion isEqualToString:@"half_target_time"]){
        [voiceArray addObject:@"120101"];
        [voiceArray addObject:@"120223"];
        [voiceArray addObject:@"120222"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:target_second/2]];
        [voiceArray addObject:@"120211"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
    }else if([occasion isEqualToString:@"every_five_munite_and_close_to_target"]){
        [voiceArray addObject:@"120102"];
        [voiceArray addObject:@"120224"];
        [voiceArray addObject:@"120222"];
        [voiceArray addObjectsFromArray:[self voiceOfTime_munite:target_second/60-munite*kVoiceTimeInterval]];
        [voiceArray addObject:@"120211"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
    }else if([occasion isEqualToString:@"reach_target_time"]){
        [voiceArray addObject:@"120103"];
        [voiceArray addObject:@"120226"];
        [voiceArray addObjectsFromArray:[self voiceOfTime_munite:target_second/60]];
        [voiceArray addObject:@"120227"];
        [voiceArray addObject:@"120211"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
    }else if([occasion isEqualToString:@"every_five_munite_and_pass_target"]){
        [voiceArray addObject:@"120221"];
        [voiceArray addObjectsFromArray:[self voiceOfTime_munite:munite*kVoiceTimeInterval]];
        [voiceArray addObject:@"120225"];
        [voiceArray addObjectsFromArray:[self voiceOfTime_munite:munite*kVoiceTimeInterval-target_second/60]];
        [voiceArray addObject:@"120211"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
    }else if([occasion isEqualToString:@"open_gps"]){
        [voiceArray addObject:@"110101"];
    }else if([occasion isEqualToString:@"weak_gps"]){
        [voiceArray addObject:@"110102"];
    }else if([occasion isEqualToString:@"background_ios"]){
        [voiceArray addObject:@"110191"];
    }else if([occasion isEqualToString:@"match_one_km_and_not_in_take_over"]){
        [voiceArray addObject:@"131101"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:km]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"131102"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distanceFromTakeOver]];
        [voiceArray addObject:@"110041"];
    }else if([occasion isEqualToString:@"match_one_km_team"]){
        [voiceArray addObject:@"131101"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distance]];
        [voiceArray addObject:@"110041"];
    }else if([occasion isEqualToString:@"match_running_in_take_over"]){
        [voiceArray addObject:@"131103"];
    }else if([occasion isEqualToString:@"match_running_transmit_relay"]){
        [voiceArray addObject:@"131104"];
        [voiceArray addObject:@"120221"];
        [voiceArray addObjectsFromArray:[self voiceOfDouble:distance]];
        [voiceArray addObject:@"110041"];
        [voiceArray addObject:@"120212"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:second]];
        [voiceArray addObject:@"120213"];
        [voiceArray addObjectsFromArray:[self voiceOfTime:speed]];
        [voiceArray addObject:@"120103"];
        [voiceArray addObject:@"131105"];
    }else if([occasion isEqualToString:@"match_wait_get_relay"]){
        [voiceArray addObject:@"131107"];
        [voiceArray addObject:@"120112"];
        [voiceArray addObject:@"120102"];
    }else if([occasion isEqualToString:@"match_off_track"]){
        [voiceArray addObject:@"130201"];
    }else if([occasion isEqualToString:@"match_come_back"]){
        [voiceArray addObject:@"130202"];
    }
    
    if([self.arrayOfTracks count] == 0){//上一次播完了
        [self.arrayOfTracks addObjectsFromArray:voiceArray];
        [self startPlay];
    }else{
        [self.arrayOfTracks addObjectsFromArray:voiceArray];
    }
}


@end

//
//  CNRunMainViewController.m
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMainViewController.h"
#import "CNLocationHandler.h"
#import "CNGPSPoint.h"
#import "CNUtil.h"
#import "CNRunMapViewController.h"
#import "CNRunMoodViewController.h"
#import "CNDistanceImageView.h"
#import "CNTimeImageView.h"
#import "CNSpeedImageView.h"
#import "CNMainViewController.h"
#import "Toast+UIView.h"
#import "CNVoiceHandler.h"
#import "CNRunMapGoogleViewController.h"
#import "CNRunManager.h"

@interface CNRunMainViewController ()

@end

@implementation CNRunMainViewController
@synthesize distance_add;
@synthesize second_add;
@synthesize div;
@synthesize tiv;
@synthesize siv;
@synthesize big_div;
@synthesize big_tiv;
@synthesize timer_dispalyTime;
@synthesize pass_km;
@synthesize playkm;
@synthesize reachTarget;
@synthesize playTarget;
@synthesize reachHalf;
@synthesize playHalf;
@synthesize closeToTarget;
@synthesize pass_5munite;
@synthesize play5munite;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    switch (kApp.runManager.runStatus) {
        case 1:
        {
            self.view_bottom_slider.hidden = NO;
            self.timer_dispalyTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
            break;
        }
        case 2:
        {
            self.view_bottom_slider.hidden = YES;
            break;
        }
        default:
            break;
    }
    [kApp.runManager addObserver:self forKeyPath:@"distance" options:NSKeyValueObservingOptionNew context:nil];
    [kApp.runManager addObserver:self forKeyPath:@"secondPerKm" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //启动runmanager跑步
    [kApp.runManager startRun];
    
    [self.button_reset addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_complete addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    
    [kApp.voiceHandler voiceOfapp:@"run_start" :nil];
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    self.sliderview.delegate = self;
    [self.sliderview setBackgroundColor:[UIColor clearColor]];
    [self.sliderview setText:@"滑动暂停"];
    
    [self setGPSImage];
    
    self.big_div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(-2.5, 100+IOS7OFFSIZE, 325, 80)];
    self.big_div.distance = 0;
    self.big_div.color = @"white";
    [self.big_div fitToSize];
    [self.view addSubview:self.big_div];
    
    self.big_tiv = [[CNTimeImageView alloc]initWithFrame:CGRectMake(20, 108+IOS7OFFSIZE, 280, 64)];
    self.big_tiv.time = 0;
    self.big_tiv.color = @"white";
    [self.big_tiv fitToSize];
    [self.view addSubview:self.big_tiv];
    
    self.div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(15, 226+IOS7OFFSIZE, 130, 32)];
    self.div.distance = 0;
    self.div.color = @"white";
    [self.div fitToSize];
    [self.view addSubview:self.div];
    
    self.tiv = [[CNTimeImageView alloc]initWithFrame:CGRectMake(10, 226+IOS7OFFSIZE, 140, 32)];
    self.tiv.time = 0;
    self.tiv.color = @"white";
    [self.tiv fitToSize];
    [self.view addSubview:self.tiv];
    
    self.siv = [[CNSpeedImageView alloc]initWithFrame:CGRectMake(190, 226+IOS7OFFSIZE, 100, 32)];
    self.siv.time = 0;
    self.siv.color = @"white";
    [self.siv fitToSize];
    [self.view addSubview:self.siv];
    
    if(kApp.runManager.targetType == 1 || kApp.runManager.targetType == 2){//目标是距离
        self.label_dis.text = @"距离（公里）";
        self.label_time.text = @"时间";
        self.big_div.hidden = NO;
        self.big_tiv.hidden = YES;
        self.div.hidden = YES;
        self.tiv.hidden = NO;
    }else if(kApp.runManager.targetType == 3){
        self.label_dis.text = @"时间";
        self.label_time.text = @"距离（公里）";
        self.big_div.hidden = YES;
        self.big_tiv.hidden = NO;
        self.div.hidden = NO;
        self.tiv.hidden = YES;
    }
    if(kApp.runManager.targetType == 1){
        self.label_target.text = @"自由运动";
    }
    kApp.timer_playVoice = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkPlayVoice) userInfo:nil repeats:YES];
}
- (void)checkPlayVoice{
    int distance = kApp.runManager.distance;
    if(kApp.runManager.targetType == 1 || kApp.runManager.targetType == 2){//目标是距离
        if(kApp.runManager.targetType == 2){
            if(self.playTarget == NO && distance > kApp.runManager.targetValue){
                self.reachTarget = YES;//达到目标了
            }
            if(self.playHalf == NO && distance > kApp.runManager.targetValue/2){//达到目标一半
                self.reachHalf = YES;
            }
            if(kApp.runManager.distance > kApp.runManager.targetValue - 2000){//快达到目标
                self.closeToTarget = YES;
            }
        }
        if(distance > (self.pass_km+1)*1000){
            self.pass_km++;
            self.playkm = YES;
        }
    }else{//目标是时间
        int duringMiliSecond = [kApp.runManager during];
        if(self.playTarget == NO && duringMiliSecond > kApp.runManager.targetValue){
            self.reachTarget = YES;//达到目标了
        }
        if(self.playHalf == NO && duringMiliSecond > kApp.runManager.targetValue/2){//达到目标一半
            self.reachHalf = YES;
        }
        if(duringMiliSecond > kApp.runManager.targetValue - 10*60*1000){//快达到目标
            self.closeToTarget = YES;
        }
        if(duringMiliSecond > (self.pass_5munite + 1)*kVoiceTimeInterval*60*1000){//过了5分钟
            self.pass_5munite++;
            self.play5munite = YES;
        }
    }
    [self playVoice];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)displayTime{
    int duringMiliSecond = [kApp.runManager during];
    if(kApp.runManager.targetType == 3){
        float width = kApp.runManager.completePercent*300.0;
        CGRect newFrame = self.view_progress.frame;
        newFrame.size = CGSizeMake(width, 3);
        self.view_progress.frame = newFrame;
        self.big_tiv.time = duringMiliSecond/1000;
        [self.big_tiv fitToSize];
    }else{
        self.tiv.time = duringMiliSecond/1000;
        [self.tiv fitToSize];
    }
}
- (IBAction)button_map_clicked:(id)sender {
//    kApp.isInChina = NO;
    if(kApp.isInChina){
        CNRunMapViewController* mapVC = [[CNRunMapViewController alloc]init];
        [self.navigationController pushViewController:mapVC animated:YES];
    }else{
        CNRunMapGoogleViewController* mapVC = [[CNRunMapGoogleViewController alloc]init];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.timer_dispalyTime invalidate];
    [kApp.runManager removeObserver:self forKeyPath:@"distance"];
    [kApp.runManager removeObserver:self forKeyPath:@"secondPerKm"];
}

- (IBAction)button_control_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"完成");
            self.button_complete.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"你已经完成这次的运动了吗?" delegate:self cancelButtonTitle:@"不，还没完成" destructiveButtonTitle:nil otherButtonTitles:@"是的，完成了", nil];
            [actionSheet showInView:self.view];
            break;
        }
        case 1:
        {
            self.button_reset.backgroundColor = [UIColor colorWithRed:0 green:123.0/255.0 blue:199.0/255.0 alpha:1];
            [kApp.voiceHandler voiceOfapp:@"run_continue" :nil];
            [kApp.runManager changeRunStatus:1];
            self.view_bottom_slider.hidden = NO;
            self.timer_dispalyTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
            NSLog(@"恢复");
            break;
        }
        default:
            break;
    }
}
// MBSliderViewDelegate
- (void) sliderDidSlide:(MBSliderView *)slideView {
    [kApp.voiceHandler voiceOfapp:@"run_pause" :nil];
    // Customization example
    NSLog(@"滑动");
    [kApp.runManager changeRunStatus:2];
    self.view_bottom_slider.hidden = YES;
    [self.timer_dispalyTime invalidate];
}
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            kApp.isRunning = 0;
            [kApp.runManager finishOneRun];
            [kApp.timer_playVoice invalidate];
            if(kApp.runManager.distance < 50){
                kApp.gpsLevel = 1;
                //弹出框，距离小于50
                [kApp.window makeToast:@"您运动距离也太短啦！这次就不给您记录了，下次一定要加油"];
                CNMainViewController* mainVC = [[CNMainViewController alloc]init];
                [self.navigationController pushViewController:mainVC animated:YES];
            }else{
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [kApp.voiceHandler voiceOfapp:@"run_complete" :voice_params];
                CNRunMoodViewController* moodVC = [[CNRunMoodViewController alloc]init];
                [self.navigationController pushViewController:moodVC animated:YES];
            }
            break;
        }
        default:
            break;
    }
}
- (void)playVoice{
    if(kApp.runManager.targetType == 1){//自由
        if(self.playkm){//整公里了
            self.playkm = NO;
            NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
            [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
            [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
            [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
            [kApp.voiceHandler voiceOfapp:@"every_km" :voice_params];
            return;
        }
    }else if(kApp.runManager.targetType == 2){//目标是距离
        int targetDetail = kApp.runManager.targetValue;//目标
        if(targetDetail > 4000){//目标大于4000
            if(self.playTarget == NO&&self.reachTarget){//达到目标！
                self.playTarget = YES;
                if(self.playkm){//如果正好是整公里则告诉不需要播报整公里了
                    self.playkm = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"reach_target_distance" :voice_params];
                return;
            }
            if(self.playkm && self.reachTarget){//整公里且大于目标
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km_and_pass_target" :voice_params];
                return;
            }
            if(self.playHalf == NO && self.reachHalf){//达到目标一半
                self.playHalf = YES;
                if(self.playkm){//如果正好是整公里则告诉不需要播报整公里了
                    self.playkm = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [kApp.voiceHandler voiceOfapp:@"half_target_dis" :voice_params];
                return;
            }
            if(self.playkm && self.closeToTarget){//整公里且接近目标
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km_and_close_to_target" :voice_params];
                return;
            }
            if(self.playkm){
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km" :voice_params];
                return;
            }
        }else{//目标小于4000
            if(self.playTarget == NO&&self.reachTarget){//达到目标！
                self.playTarget = YES;
                if(self.playkm){//如果正好是整公里则告诉不需要播报整公里了
                    self.playkm = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"reach_target_distance" :voice_params];
                return;
            }
            if(self.playkm && self.reachTarget){//整公里且大于目标
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km_and_pass_target" :voice_params];
                return;
            }
            if(self.playkm){
                self.playkm = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_km] forKey:@"km"];
                [kApp.voiceHandler voiceOfapp:@"every_km" :voice_params];
                return;
            }
        }
    }else if(kApp.runManager.targetType == 3){
        int targetDetail = kApp.runManager.targetValue/1000;//时间目标
        if(targetDetail > 1200){//目标大于1200
            if(self.playTarget == NO && self.reachTarget){//达到目标！
                self.playTarget = YES;
                if(self.play5munite){//如果正好是5n分钟就不播了
                    self.play5munite = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [kApp.voiceHandler voiceOfapp:@"reach_target_time" :voice_params];
                return;
            }
            if(self.play5munite && self.reachTarget){//5n分钟且大于目标
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite_and_pass_target" :voice_params];
                return;
            }
            if(self.playHalf == NO && self.reachHalf){//达到目标一半
                self.playHalf = YES;
                if(self.play5munite){//如果正好是整公里则告诉不需要播报整公里了
                    self.play5munite = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [kApp.voiceHandler voiceOfapp:@"half_target_time" :voice_params];
                return;
            }
            if(self.play5munite && self.closeToTarget){//5n分钟且接近目标
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite_and_close_to_target" :voice_params];
                return;
            }
            if(self.play5munite){
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite" :voice_params];
                return;
            }
        }else{
            if(self.playTarget == NO && self.reachTarget){//达到目标！
                self.playTarget = YES;
                if(self.play5munite){//如果正好是5n分钟就不播了
                    self.play5munite = NO;
                }
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [kApp.voiceHandler voiceOfapp:@"reach_target_time" :voice_params];
                return;
            }
            if(self.play5munite && self.reachTarget){//5n分钟且大于目标
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",targetDetail] forKey:@"target_second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite_and_pass_target" :voice_params];
                return;
            }
            if(self.play5munite){
                self.play5munite = NO;
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",self.pass_5munite] forKey:@"munite"];
                [kApp.voiceHandler voiceOfapp:@"every_five_munite" :voice_params];
                return;
            }
        }
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"distance"])
    {
        int distance = kApp.runManager.distance;
        NSLog(@"distance is %i",kApp.runManager.distance);
        if(kApp.runManager.targetType == 1 || kApp.runManager.targetType == 2){//目标是距离
            if(kApp.runManager.targetType == 2){
                float width = kApp.runManager.completePercent*300.0;
                CGRect newFrame = self.view_progress.frame;
                newFrame.size = CGSizeMake(width, 3);
                self.view_progress.frame = newFrame;
            }
            self.big_div.distance = distance/1000.0;
            [self.big_div fitToSize];
        }else{
            self.div.distance = distance/1000.0;
            [self.div fitToSize];
        }
    }
    if([keyPath isEqualToString:@"secondPerKm"])
    {
        self.siv.time = kApp.runManager.secondPerKm;
        [self.siv fitToSize];
    }
}
@end

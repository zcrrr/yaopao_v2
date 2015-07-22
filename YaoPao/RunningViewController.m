//
//  RunningViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/14.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "RunningViewController.h"
#import "CNRunManager.h"
#import "CNVoiceHandler.h"
#import "ColorValue.h"
#import "CNUtil.h"
#import "CNRunMapViewController.h"
#import "CNRunMapGoogleViewController.h"
#import "Toast+UIView.h"
#import "FeelingViewController.h"
#import "UIImage+Rescale.h"
#import "CNOverlayViewController.h"
#import "CircleView.h"
#import "CNLocationHandler.h"
#import "CircularLock.h"
#import "CNADBookViewController.h"

@interface RunningViewController ()

@end

@implementation RunningViewController
@synthesize distance_add;
@synthesize second_add;
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
@synthesize cameraPicker;
@synthesize overlayVC;
@synthesize pauseButoon;
@synthesize timer_countdown;
@synthesize count;
extern NSMutableArray* imageArray;

- (void)viewWillAppear:(BOOL)animated{
    [CNUtil appendUserOperation:@"进入跑步页面"];
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    switch (kApp.runManager.runStatus) {
        case 1:
        {
            //todo 根据状态显示暂停or继续
            [self initPauseButton:NO];
            self.button_complete.hidden = YES;
            self.label_longpress.hidden = NO;
            self.label_complete.hidden = YES;
            self.label_continue.hidden = YES;
            self.timer_dispalyTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
            break;
        }
        case 2:
        {
            //todo 根据状态显示暂停or继续
            [self initPauseButton:YES];
            self.button_complete.hidden = NO;
            self.label_longpress.hidden = YES;
            self.label_complete.hidden = NO;
            self.label_continue.hidden = NO;
            break;
        }
        default:
            break;
    }
    [kApp.runManager addObserver:self forKeyPath:@"distance" options:NSKeyValueObservingOptionNew context:nil];
    [kApp.runManager addObserver:self forKeyPath:@"secondPerKm" options:NSKeyValueObservingOptionNew context:nil];
    [kApp.locationHandler addObserver:self forKeyPath:@"accuracy" options:NSKeyValueObservingOptionNew context:nil];
    
    //进来就先显示
    int distance = kApp.runManager.distance;
    //        NSLog(@"distance is %i",kApp.runManager.distance);
    if(kApp.runManager.targetType == 1 || kApp.runManager.targetType == 2){//目标是距离
        if(kApp.runManager.targetType == 2){
            //通过kApp.runManager.completePercent设定进度
            if(kApp.runManager.completePercent >= 0 && kApp.runManager.completePercent<=1){
                self.view_circle.progress = kApp.runManager.completePercent;
                [self.view_circle setNeedsDisplay];
            }
        }
        self.label_dis_big.text = [NSString stringWithFormat:@"%0.2f",distance/1000.0];
    }else{
        self.label_dis_small.text = [NSString stringWithFormat:@"%0.2f",distance/1000.0];
    }
    
}
- (void)countdown{
    count--;
    self.label_num.text = [NSString stringWithFormat:@"%i",count];
    if(count == 0){
        self.view_countdown.hidden = YES;
        [self.timer_countdown invalidate];
        [self startRun];
    }
}
- (void)startRun{
    //启动runmanager跑步
    [kApp.runManager startRun];
    [kApp.voiceHandler voiceOfapp:@"run_start" :nil];
    kApp.timer_playVoice = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkPlayVoice) userInfo:nil repeats:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.count > 0){
        self.timer_countdown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
    }else{
        self.view_countdown.hidden = YES;
        [self startRun];
    }
    
    
    
    imageArray = nil;
    // Do any additional setup after loading the view from its nib.
    
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
//    self.sliderview.delegate = self;
//    [self.sliderview setBackgroundColor:[UIColor clearColor]];
//    [self.sliderview setText:@"滑动暂停"];
    [self initPauseButton:NO];
    
    
    [self setGPSImage];
    
    if(kApp.runManager.targetType == 1 || kApp.runManager.targetType == 2){//目标是距离
        self.label_dis.text = @"距离(公里)";
        self.label_time.text = @"用时";
        self.label_dis_big.hidden = NO;
        self.label_during_big.hidden = YES;
        self.label_dis_small.hidden = YES;
        self.label_during_small.hidden = NO;
    }else if(kApp.runManager.targetType == 3){
        self.label_dis.text = @"用时";
        self.label_time.text = @"距离(公里)";
        self.label_dis_big.hidden = YES;
        self.label_during_big.hidden = NO;
        self.label_dis_small.hidden = NO;
        self.label_during_small.hidden = YES;
    }
    if(!iPhone5){//4、4s
        self.view_middle.frame = CGRectMake(0, 250, 320, 44);
        self.button_takephoto.frame = CGRectMake(28, 295, 65, 65);
        self.button_map.frame = CGRectMake(128, 295, 65, 65);
        self.button_group.frame = CGRectMake(229, 295, 65, 65);
        self.button_complete.frame = CGRectMake(166, 365, 90, 90);
    }
}
- (void)initPauseButton:(BOOL)isPause{
    int certer_x;
    if(isPause){
        certer_x = 109;
    }else{
        certer_x = self.view.center.x;
    }
    [self.pauseButoon removeFromSuperview];
    self.pauseButoon = [[CircularLock alloc] initWithCenter:CGPointMake(certer_x, self.button_complete.frame.origin.y+45)
                                                     radius:45
                                                   duration:1
                                                strokeWidth:4
                                                  ringColor:[UIColor lightGrayColor]
                                                strokeColor:[UIColor greenColor]
                                                lockedImage:[UIImage imageNamed:@"running_start.png"]
                                              unlockedImage:[UIImage imageNamed:@"running_pause.png"]
                                                   isLocked:isPause
                                          didlockedCallback:^{
                                              NSLog(@"暂停");
                                              [self pauseRun];
                                          }
                                        didUnlockedCallback:^{
                                            NSLog(@"继续");
                                            [self continueRun];
                                        }];
    [self.view addSubview:self.pauseButoon];
    [self.view sendSubviewToBack:self.pauseButoon];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)displayTime{
    int duringMiliSecond = [kApp.runManager during];
    if(duringMiliSecond > 24*60*60*1000){//大于24小时，不可能
        duringMiliSecond = 0;
    }
    
    if(kApp.runManager.targetType == 3){
        //通过kApp.runManager.completePercent设置进度;
        if(kApp.runManager.completePercent >= 0 && kApp.runManager.completePercent<=1){
            self.view_circle.progress = kApp.runManager.completePercent;
            [self.view_circle setNeedsDisplay];
        }
        if(duringMiliSecond > 60*60*1000){//超过一个小时
            [self.label_during_big setFont:[UIFont systemFontOfSize:36]];
        }
        self.label_during_big.text = [CNUtil duringTimeStringFromSecond:duringMiliSecond/1000];
    }else{
        self.label_during_small.text = [CNUtil duringTimeStringFromSecond:duringMiliSecond/1000];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewWillDisappear:(BOOL)animated{
    [self.timer_dispalyTime invalidate];
    [kApp.runManager removeObserver:self forKeyPath:@"distance"];
    [kApp.runManager removeObserver:self forKeyPath:@"secondPerKm"];
    [kApp.locationHandler removeObserver:self forKeyPath:@"accuracy"];
}
- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"拍照");
            [CNUtil appendUserOperation:@"点击拍照按钮"];
            [self takePhoto];
            break;
        }
        case 1:
        {
            NSLog(@"地图");
            [CNUtil appendUserOperation:@"点击地图按钮"];
            kApp.isInChina = YES;
            if(kApp.isInChina){
                CNRunMapViewController* mapVC = [[CNRunMapViewController alloc]init];
                [self.navigationController pushViewController:mapVC animated:YES];
            }else{
                CNRunMapGoogleViewController* mapVC = [[CNRunMapGoogleViewController alloc]init];
                [self.navigationController pushViewController:mapVC animated:YES];
            }
            break;
        }
        case 2:
        {
            [CNUtil appendUserOperation:@"点击跑团按钮"];
            NSLog(@"跑团");
            if(kApp.isLogin == 0){
                [kApp.window makeToast:@"请先登录~"];
                return;
            }
            CNADBookViewController* adbookVC = [[CNADBookViewController alloc]init];
            adbookVC.isFromRunning = YES;
            [self.navigationController pushViewController:adbookVC animated:YES];
            break;
        }
        case 3:
        {
            [CNUtil appendUserOperation:@"点击完成按钮"];
            NSLog(@"完成");
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"你已经完成这次的运动了吗?" delegate:self cancelButtonTitle:@"不，还没完成" destructiveButtonTitle:nil otherButtonTitles:@"是的，完成了", nil];
            [actionSheet showInView:self.view];
            break;
        }
        default:
            break;
    }
}
- (void)continueRun{
    [CNUtil appendUserOperation:@"继续运动"];
    [kApp.voiceHandler voiceOfapp:@"run_continue" :nil];
    [kApp.runManager changeRunStatus:1];
    self.button_complete.hidden = YES;
    self.label_complete.hidden = YES;
    self.label_continue.hidden = YES;
    self.label_longpress.hidden = NO;
    self.timer_dispalyTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
    CGRect oldFrame = self.pauseButoon.frame;
    CGRect newFrame = CGRectMake(115, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
    self.pauseButoon.frame = newFrame;
}
- (void)pauseRun{
    [CNUtil appendUserOperation:@"暂停运动"];
    [kApp.voiceHandler voiceOfapp:@"run_pause" :nil];
    // Customization example
    [kApp.runManager changeRunStatus:2];
    self.button_complete.hidden = NO;
    self.label_longpress.hidden = YES;
    self.label_complete.hidden = NO;
    self.label_continue.hidden = NO;
    [self.timer_dispalyTime invalidate];
    CGRect oldFrame = self.pauseButoon.frame;
    CGRect newFrame = CGRectMake(64, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
    self.pauseButoon.frame = newFrame;
    
}
- (void)setGPSImage{
    int i = 0;
    NSArray* imageviewArray = [[NSArray alloc]initWithObjects:self.image_gps1,self.image_gps2,self.image_gps3,self.image_gps4,nil];
    //先全部灰色
    for(i=0;i<4;i++){
        ((UIImageView*)[imageviewArray objectAtIndex:i]).image = [UIImage imageNamed:@"sig_gray.png"];
    }
    for(i=0;i<4;i++){
        if(kApp.locationHandler.rank > i){
            ((UIImageView*)[imageviewArray objectAtIndex:i]).image = [UIImage imageNamed:@"sig_green.png"];
        }
    }
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
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [kApp.voiceHandler voiceOfapp:@"run_complete" :voice_params];
                FeelingViewController* moodVC = [[FeelingViewController alloc]init];
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
//        NSLog(@"distance is %i",kApp.runManager.distance);
        if(kApp.runManager.targetType == 1 || kApp.runManager.targetType == 2){//目标是距离
            if(kApp.runManager.targetType == 2){
                //通过kApp.runManager.completePercent设定进度
                if(kApp.runManager.completePercent >= 0 && kApp.runManager.completePercent<=1){
                    self.view_circle.progress = kApp.runManager.completePercent;
                    [self.view_circle setNeedsDisplay];
                }
            }
            self.label_dis_big.text = [NSString stringWithFormat:@"%0.2f",distance/1000.0];
        }else{
            self.label_dis_small.text = [NSString stringWithFormat:@"%0.2f",distance/1000.0];
        }
    }
    if([keyPath isEqualToString:@"secondPerKm"])
    {
        self.label_secondPerKm.text = [CNUtil pspeedStringFromSecond:kApp.runManager.secondPerKm];
    }
    if([keyPath isEqualToString:@"accuracy"])
    {
        int rank = 0;
        if (kApp.locationHandler.accuracy > 200)
            rank = 1;
        else if (kApp.locationHandler.accuracy > 50)
            rank = 2;
        else if (kApp.locationHandler.accuracy > 20)
            rank = 3;
        else rank = 4;
        self.label_acc.text = [NSString stringWithFormat:@"%f:%i",kApp.locationHandler.accuracy,rank];
    }
}
- (void)takePhoto{
    self.cameraPicker = [[UIImagePickerController alloc]init];
    self.cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraPicker.allowsEditing = NO;
    self.cameraPicker.showsCameraControls=NO;
    self.overlayVC = [[CNOverlayViewController alloc]init];
    self.cameraPicker.cameraOverlayView = self.overlayVC.view;
    [self presentViewController:self.cameraPicker animated:YES completion:^{
        self.overlayVC.cameraPicker = self.cameraPicker;
        self.overlayVC.cameraPicker.delegate = self.overlayVC;
    }];
}
- (IBAction)button_countdonw_clicked:(id)sender {
    self.view_countdown.hidden = YES;
    [self.timer_countdown invalidate];
    [self startRun];
}
@end

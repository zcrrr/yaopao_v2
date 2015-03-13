//
//  CNStartRunViewController.m
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNStartRunViewController.h"
#import "CNRunTargetViewController.h"
#import "CNRunTypeViewController.h"
#import "CNCountDownViewController.h"
#import "CNRunMainViewController.h"
#import "CNLocationHandler.h"
#import "CNUtil.h"
#import "CNRunManager.h"

@interface CNStartRunViewController ()

@end

@implementation CNStartRunViewController
@synthesize howToMove;
@synthesize targetType;
@synthesize targetValue;
@synthesize runSettingDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_start addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    
    [self.button_target addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_type addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
    self.runSettingDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(self.runSettingDic == nil){
        self.runSettingDic = [[NSMutableDictionary alloc]init];
        [self.runSettingDic setObject:@"2" forKey:@"targetType"];
        [self.runSettingDic setObject:@"5" forKey:@"distance"];
        [self.runSettingDic setObject:@"30" forKey:@"time"];
        [self.runSettingDic setObject:@"1" forKey:@"howToMove"];
        [self.runSettingDic setObject:@"1" forKey:@"countdown"];
        [self.runSettingDic setObject:@"1" forKey:@"voice"];
    }
    self.targetType = [[self.runSettingDic objectForKey:@"targetType"]intValue];
    NSString* targetDes = @"";
    switch (self.targetType) {
        case 1:
        {
            self.targetValue = 0;
            targetDes = @"自由";
            self.image_target.image = [UIImage imageNamed:@"target_free.png"];
            break;
        }
        case 2:
        {
            self.targetValue = [[self.runSettingDic objectForKey:@"distance"] intValue]*1000;
            targetDes = [NSString stringWithFormat:@"%@km",[self.runSettingDic objectForKey:@"distance"]];
            self.image_target.image = [UIImage imageNamed:@"target_dis.png"];
            break;
        }
        case 3:
        {
            self.targetValue = [[self.runSettingDic objectForKey:@"time"]intValue]*60*1000;//毫秒
            int second = [[self.runSettingDic objectForKey:@"time"]intValue]*60;
            NSString* timestr = [CNUtil duringTimeStringFromSecond:second];
            targetDes = timestr;
            self.image_target.image = [UIImage imageNamed:@"target_time.png"];
            break;
        }
        default:
            break;
    }
    self.label_target.text = targetDes;
    self.howToMove = [[self.runSettingDic objectForKey:@"howToMove"]intValue];
    NSString* typeDes = @"";
    switch (self.howToMove) {
        case 1:
        {
            typeDes = @"跑步";
            self.image_type.image = [UIImage imageNamed:@"runtype_run_s.png"];
            break;
        }
        case 2:
        {
            typeDes = @"步行";
            self.image_type.image = [UIImage imageNamed:@"runtype_walk_s.png"];
            break;
        }
        case 3:
        {
            typeDes = @"自行车骑行";
            self.image_type.image = [UIImage imageNamed:@"runtype_ride_s.png"];
            break;
        }
        default:
            break;
    }
    self.label_type.text = typeDes;
    int countdown = [[self.runSettingDic objectForKey:@"countdown"]intValue];
    if(countdown == 0){
        self.switch_countdown.on = NO;
    }else{
        self.switch_countdown.on = YES;
    }
    int voice = [[self.runSettingDic objectForKey:@"voice"]intValue];
    if(voice == 0){
        self.switch_voice.on = NO;
        kApp.voiceOn = 0;
    }else{
        self.switch_voice.on = YES;
        kApp.voiceOn = 1;
    }
}
- (void)button_white_down:(id)sender{
    switch ([sender tag]) {
        case 1:
            self.view_target.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        case 2:
            self.view_type.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:{
            self.button_back.backgroundColor = [UIColor clearColor];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:{
            self.view_target.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CNRunTargetViewController* runTargetVC = [[CNRunTargetViewController alloc]init];
            [self.navigationController pushViewController:runTargetVC animated:YES];
            break;
        }
        case 2:{
            self.view_type.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CNRunTypeViewController* runTypeVC = [[CNRunTypeViewController alloc]init];
            [self.navigationController pushViewController:runTypeVC animated:YES];
            break;
        }
        case 3:{
            self.button_start.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            if(self.switch_countdown.on){
                [self.runSettingDic setObject:@"1" forKey:@"countdown"];
            }else{
                [self.runSettingDic setObject:@"0" forKey:@"countdown"];
            }
            if(self.switch_voice.on){
                [self.runSettingDic setObject:@"1" forKey:@"voice"];
                kApp.voiceOn = 1;
            }else{
                [self.runSettingDic setObject:@"0" forKey:@"voice"];
                kApp.voiceOn = 0;
            }
            NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
            [self.runSettingDic writeToFile:filePath atomically:YES];
            NSLog(@"写入plist:%@",self.runSettingDic);
            
            if ([self prepareRun]) {
                kApp.isRunning = 1;
                kApp.gpsLevel = 4;
                //初始化runManager
                kApp.runManager = [[CNRunManager alloc]initWithSecond:2];
                kApp.runManager.howToMove = self.howToMove;
                kApp.runManager.targetType = self.targetType;
                kApp.runManager.targetValue = self.targetValue;
                NSLog(@"howtomove is %d",self.howToMove);
                NSLog(@"targetType is %d",self.targetType);
                NSLog(@"targetValue is %d",self.targetValue);
                if(self.switch_countdown.on){
                    CNCountDownViewController* countdownVC = [[CNCountDownViewController alloc]init];
                    [self.navigationController pushViewController:countdownVC animated:YES];
                }else{
                    CNRunMainViewController* runVC = [[CNRunMainViewController alloc]init];
                    [self.navigationController pushViewController:runVC animated:YES];
                }
            }
            break;
        }
        default:
            break;
    }
}
- (BOOL)prepareRun{
    //测试代码
#ifdef SIMULATORTEST
    return YES;
#else
# endif
    
    if (0.001 > fabs(kApp.locationHandler.userLocation_lon) || 0.001 > fabs(kApp.locationHandler.userLocation_lat))
    {
        NSLog(@"异常提示：gps信号弱");
        [CNAppDelegate popupWarningGPSWeak];
        return NO;
    }else{
        if(kApp.locationHandler.rank >= kApp.gpsLevel){
            return YES;
        }else{
            NSLog(@"异常提示：gps信号弱");
            [CNAppDelegate popupWarningGPSWeak];
            return NO;
        }
    }
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end

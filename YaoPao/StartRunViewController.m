//
//  StartRunViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/13.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "StartRunViewController.h"
#import "CNUtil.h"
#import "CNRunTargetViewController.h"
#import "CNRunTypeViewController.h"
#import "CNRunManager.h"
#import "CountDownViewController.h"
#import "RunningViewController.h"
#import "CNLocationHandler.h"

@interface StartRunViewController ()

@end

@implementation StartRunViewController
@synthesize howToMove;
@synthesize targetType;
@synthesize targetValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_target addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    [self.button_type addTarget:self action:@selector(changeViewColor:) forControlEvents:UIControlEventTouchDown];
    [self changeLineOne:self.view_line1];
    [self changeLineOne:self.view_line2];
    [self changeLineOne:self.view_line3];
    [self changeLineOne:self.view_line4];
    [self changeLineOne:self.view_line5];
    
    
}
- (void)changeLineOne:(UIView*)line{
    CGRect frame_new = line.frame;
    frame_new.size = CGSizeMake(frame_new.size.width, 0.5);
    line.frame = frame_new;
}
- (void)changeViewColor:(id)sender{
    switch ([sender tag]) {
        case 1:
            self.view_target.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:48.0/255.0 blue:62.0/255.0 alpha:1];
            break;
        case 2:
            self.view_type.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:48.0/255.0 blue:62.0/255.0 alpha:1];
            break;
        default:
            break;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableDictionary* settingDic = [CNUtil getRunSettingWhole];
    self.howToMove = [[settingDic objectForKey:@"howToMove"]intValue];
    self.targetType = [[settingDic objectForKey:@"targetType"]intValue];
    self.targetValue = [[settingDic objectForKey:@"targetValue"]intValue];
    self.imageview_target.image = [UIImage imageNamed:[settingDic objectForKey:@"typeImageName"]];
    self.imageview_type.image = [UIImage imageNamed:[settingDic objectForKey:@"htmImageName"]];
    self.label_target.text = [settingDic objectForKey:@"targetDes"];
    self.label_type.text = [settingDic objectForKey:@"typeDes"];
    int countdown = [[settingDic objectForKey:@"countdown"]intValue];
    if(countdown == 0){
        self.switch_countdown.on = NO;
    }else{
        self.switch_countdown.on = YES;
    }
    int voice = [[settingDic objectForKey:@"voice"]intValue];
    if(voice == 0){
        self.switch_voice.on = NO;
        kApp.voiceOn = 0;
    }else{
        self.switch_voice.on = YES;
        kApp.voiceOn = 1;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"返回");
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"目标");
            self.view_target.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1];
            CNRunTargetViewController* runTargetVC = [[CNRunTargetViewController alloc]init];
            [self.navigationController pushViewController:runTargetVC animated:YES];
            break;
        }
        case 2:
        {
            NSLog(@"类型");
            self.view_type.backgroundColor = [UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1];
            CNRunTypeViewController* runTypeVC = [[CNRunTypeViewController alloc]init];
            [self.navigationController pushViewController:runTypeVC animated:YES];
            break;
            break;
        }
        case 3:
        {
            NSLog(@"开始运动");
            NSMutableDictionary* runSettingDic = [CNUtil getRunSetting];
            if(self.switch_countdown.on){
                [runSettingDic setObject:@"1" forKey:@"countdown"];
            }else{
                [runSettingDic setObject:@"0" forKey:@"countdown"];
            }
            if(self.switch_voice.on){
                [runSettingDic setObject:@"1" forKey:@"voice"];
                kApp.voiceOn = 1;
            }else{
                [runSettingDic setObject:@"0" forKey:@"voice"];
                kApp.voiceOn = 0;
            }
            NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
            [runSettingDic writeToFile:filePath atomically:YES];
//            if ([self prepareRun]) {
                kApp.isRunning = 1;
                kApp.gpsLevel = 4;
                NSMutableDictionary* settingDic = [CNUtil getRunSettingWhole];
                //初始化runManager
                kApp.runManager = [[CNRunManager alloc]initWithSecond:2];
                kApp.runManager.howToMove = [[settingDic objectForKey:@"howToMove"]intValue];
                kApp.runManager.targetType = [[settingDic objectForKey:@"targetType"]intValue];
                kApp.runManager.targetValue = [[settingDic objectForKey:@"targetValue"]intValue];
                NSLog(@"howtomove is %d",kApp.runManager.howToMove);
                NSLog(@"targetType is %d",kApp.runManager.targetType);
                NSLog(@"targetValue is %d",kApp.runManager.targetValue);
                int countDonwOn = [[settingDic objectForKey:@"countdown"]intValue];
                if(countDonwOn == 1){
                    CountDownViewController* countdownVC = [[CountDownViewController alloc]init];
                    [self.navigationController pushViewController:countdownVC animated:YES];
                }else{
                    RunningViewController* runningVC = [[RunningViewController alloc]init];
                    [self.navigationController pushViewController:runningVC animated:YES];
                }
//            }
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
@end

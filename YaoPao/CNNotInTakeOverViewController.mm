//
//  CNNotInTakeOverViewController.m
//  YaoPao
//
//  Created by zc on 14-9-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNNotInTakeOverViewController.h"
#import "CNFinishViewController.h"
#import "CNNetworkHandler.h"
#import "CNLocationHandler.h"
#import "CNEncryption.h"
#import "CNTestGEOS.h"
#import "CNGiveRelayViewController.h"
#import "CNGPSPoint4Match.h"
#import "SBJson.h"
#import "CNUtil.h"

@interface CNNotInTakeOverViewController ()

@end

@implementation CNNotInTakeOverViewController
@synthesize checkInTakeOver;

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
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.imageview_avatar.image = [[UIImage alloc] initWithData:imageData];
    }
    self.label_uname.text = [kApp.userInfoDic objectForKey:@"nickname"];
    [self.button_back addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.checkInTakeOver = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(check) userInfo:nil repeats:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.checkInTakeOver invalidate];
}
- (void)check{
    CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(kApp.locationHandler.userLocation_lat, kApp.locationHandler.userLocation_lon);
    CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
    int isInTakeOverZone = [kApp.geosHandler isInTheTakeOverZones:encryptionPoint.longitude :encryptionPoint.latitude];
    if(isInTakeOverZone != -1){
        [self.navigationController popViewControllerAnimated:NO];
        CNGiveRelayViewController* relayVC = [[CNGiveRelayViewController alloc]init];
        [[kApp.navVCList objectAtIndex:kApp.currentSelect] pushViewController:relayVC animated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)button_finish_clicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"结束跑队赛程意味着跑队比赛结束,成绩截止,其他队友也将无法继续参赛。您是否确认提前结束跑队的比赛?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确认", nil];
    [actionSheet showInView:self.view];
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            UIAlertView* alert =[[UIAlertView alloc] initWithTitle:nil message:@"请再次确认提前结束跑队的比赛?" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
            alert.tag = 2;
            [alert show];
            break;
        }
        default:
            break;
    }
}
#pragma -mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 2){
        switch (buttonIndex) {
            case 0:
            {
                [self finishMatch];
                break;
            }
            case 1:
            {
                [alertView dismissWithClickedButtonIndex:1 animated:YES];
            }
            default:
                break;
        }
    }
}

- (void)finishMatch{
    [CNAppDelegate saveMatchToRecord];
    [kApp.timer_one_point invalidate];
    [kApp.timer_secondplusplus invalidate];
    [kApp.match_timer_report invalidate];
    NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
    //调用服务器接口
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    CNGPSPoint4Match* gpsPoint = [kApp.match_pointList lastObject];
    NSMutableArray* pointList = [[NSMutableArray alloc]init];
    NSMutableDictionary* onepoint = [[NSMutableDictionary alloc]init];
    [onepoint setObject:[NSString stringWithFormat:@"%llu",gpsPoint.time*1000] forKey:@"uptime"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",kApp.match_totaldis] forKey:@"distanceur"];
    [onepoint setObject:[NSString stringWithFormat:@"%i",gpsPoint.isInTrack] forKey:@"inrunway"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",gpsPoint.lat] forKey:@"slat"];
    [onepoint setObject:[NSString stringWithFormat:@"%f",gpsPoint.lon] forKey:@"slon"];
    [onepoint setObject:@"3" forKey:@"mstate"];
    [pointList addObject:onepoint];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString* pointJson = [jsonWriter stringWithObject:pointList];
    [params setObject:pointJson forKey:@"longitude"];
    kApp.networkHandler.delegate_endMatch = self;
    [kApp.networkHandler doRequest_endMatch:params];
}
- (void)endMatchInfoDidSuccess:(NSDictionary *)resultDic{
    [CNAppDelegate ForceGoMatchPage:@"finish"];
}
- (void)endMatchInfoDidFailed:(NSString *)mes{
    
}
@end

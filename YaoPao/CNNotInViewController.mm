//
//  CNNotInViewController.m
//  YaoPao
//
//  Created by zc on 14-9-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNNotInViewController.h"
#import "CNLocationHandler.h"
#import "CNEncryption.h"
#import "CNTestGEOS.h"
#import "CNNotRunTransmitRelayViewController.h"

@interface CNNotInViewController ()

@end

@implementation CNNotInViewController
@synthesize checkInTakeOver;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.imageview_avatar.image = [[UIImage alloc] initWithData:imageData];
    }
    self.label_uname.text = [kApp.userInfoDic objectForKey:@"nickname"];
}
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.checkInTakeOver = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(check) userInfo:nil repeats:YES];
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
        CNNotRunTransmitRelayViewController* relayVC = [[CNNotRunTransmitRelayViewController alloc]init];
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
@end

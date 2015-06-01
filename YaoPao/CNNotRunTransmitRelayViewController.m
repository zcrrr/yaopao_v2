//
//  CNNotRunTransmitRelayViewController.m
//  YaoPao
//
//  Created by zc on 14-9-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNNotRunTransmitRelayViewController.h"
#import "CNMatchMainViewController.h"
#import "ASIHTTPRequest.h"
#import "CNVoiceHandler.h"
#define interval 10

@interface CNNotRunTransmitRelayViewController ()

@end

@implementation CNNotRunTransmitRelayViewController
@synthesize timer_transmit;
@synthesize imagePath_runner;

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self requestTransmit];
    self.timer_transmit = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(requestTransmit) userInfo:nil repeats:YES];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer_transmit invalidate];
}
- (void)requestTransmit{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    kApp.networkHandler.delegate_transmitRelay = self;
    [kApp.networkHandler doRequest_transmitRelay:params];
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.button_back addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    self.label_name.text = [kApp.userInfoDic objectForKey:@"nickname"];
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.image_myavatar.image = [[UIImage alloc] initWithData:imageData];
    }
}
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)startAnimation{
    //接到棒，播放语音
    [kApp.voiceHandler voiceOfapp:@"match_wait_get_relay" :nil];
    [self displayCartoon1];
    [self performSelector:@selector(displayCartoon2) withObject:nil afterDelay:0.5];
    [self performSelector:@selector(displayCartoon1) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(displayCartoon2) withObject:nil afterDelay:1.5];
    [self performSelector:@selector(displayCartoon1) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(displayCartoon2) withObject:nil afterDelay:2.5];
    [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:3];
}
- (void)displayCartoon1{
    self.view_cartoon1.hidden = NO;
    self.view_cartoon2.hidden = YES;
}
- (void)displayCartoon2{
    self.view_cartoon2.hidden = NO;
    self.view_cartoon1.hidden = YES;
}
- (void)stopAnimation{
    [self startmatch];
}
- (void)transmitRelayDidFailed:(NSString *)mes{
    
}
- (void)transmitRelayDidSuccess:(NSDictionary *)resultDic{
    NSArray* array = [resultDic objectForKey:@"list"];
    if([array count]<1){
        self.view_back.hidden = NO;
        self.view_run_user.hidden = YES;
        NSDictionary* longitude = [resultDic objectForKey:@"longitude"];
        int keycount = (int)[[longitude allKeys] count];
        if(longitude&&keycount>0){//被确认接棒
            kApp.match_totalDisTeam = [[longitude objectForKey:@"distancegr"]doubleValue];
            [self startAnimation];
        }else{//没有搜索到人
            self.view_back.hidden = NO;
            self.view_run_user.hidden = YES;
        }
    }else{
        self.view_back.hidden = YES;
        self.view_run_user.hidden = NO;
        NSDictionary* run_user_dic = [array objectAtIndex:0];
        self.lable_run_user.text = [run_user_dic objectForKey:@"nickname"];
        self.imagePath_runner = [run_user_dic objectForKey:@"imgpath"];
        if(self.imagePath_runner == nil){
            self.image_run_user.image = [UIImage imageNamed:@"avatar_default.png"];
        }else{
            UIImage* image = [kApp.avatarDic objectForKey:self.imagePath_runner];
            if(image != nil){//缓存中有
                self.image_run_user.image = image;
            }else{//下载
                NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,self.imagePath_runner];
                NSLog(@"avatar is %@",imageURL);
                NSURL *url = [NSURL URLWithString:imageURL];
                ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
                Imagerequest.timeOutSeconds = 15;
                [Imagerequest setDelegate:self];
                [Imagerequest startAsynchronous];
            }
        }
    }
}
#pragma -mark ASIHttpRequest delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    UIImage *image = [[UIImage alloc] initWithData:[request responseData]];
    if(image){
        self.image_run_user.image = image;
        [kApp.avatarDic setObject:image forKey:self.imagePath_runner];
    }
}

- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)startmatch{
    kApp.isbaton = 1;
    CNMatchMainViewController* matchVC = [[CNMatchMainViewController alloc]init];
    [self.navigationController pushViewController:matchVC animated:YES];
}
@end

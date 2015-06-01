//
//  CNGiveRelayViewController.m
//  YaoPao
//
//  Created by zc on 14-8-26.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNGiveRelayViewController.h"
#import "CNFinishViewController.h"
#import "CNGPSPoint4Match.h"
#import "CNTestGEOS.h"
#import "CNLocationHandler.h"
#import "CNEncryption.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "CNVoiceHandler.h"
#import "CNUtil.h"


#define kInterval 10

@interface CNGiveRelayViewController ()

@end

@implementation CNGiveRelayViewController
@synthesize timer_look_submit;
@synthesize joinid1;
@synthesize joinid2;
@synthesize joinid3;
@synthesize joinid;
@synthesize avatarurl1;
@synthesize avatarurl2;
@synthesize avatarurl3;

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
    self.timer_look_submit = [NSTimer scheduledTimerWithTimeInterval:kInterval target:self selector:@selector(requestTransmit) userInfo:nil repeats:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer_look_submit invalidate];
}
- (void)requestTransmit{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    kApp.networkHandler.delegate_transmitRelay = self;
    [kApp.networkHandler doRequest_transmitRelay:params];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.image_me.image = [[UIImage alloc] initWithData:imageData];
    }
    self.label_myname.text = [kApp.userInfoDic objectForKey:@"nickname"];
    [self requestTransmit];
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


- (IBAction)button_back_clicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    kApp.networkHandler.delegate_cancelTransmit = self;
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    [kApp.networkHandler doRequest_cancelTransmit:params];
}

- (IBAction)button_finish_clicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"结束跑队赛程意味着跑队比赛结束,成绩截止,其他队友也将无法继续参赛。您是否确认提前结束跑队的比赛?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
    [actionSheet showInView:self.view];
}
- (IBAction)button_user_clicked:(id)sender {
    NSString* username = @"";
    switch ([sender tag]) {
        case 1:
        {
            self.view_user2.hidden = YES;
            self.view_user3.hidden = YES;
            username = self.label_user1.text;
            self.joinid = self.joinid1;
            break;
        }
        case 2:
        {
            self.view_user2.frame = CGRectMake(110, 30, 100, 100);
            self.view_user1.hidden = YES;
            self.view_user3.hidden = YES;
            username = self.label_user2.text;
            self.joinid = self.joinid2;
            break;
        }
        case 3:
        {
            self.view_user3.frame = CGRectMake(110, 30, 100, 100);
            self.view_user1.hidden = YES;
            self.view_user2.hidden = YES;
            username = self.label_user3.text;
            self.joinid = self.joinid3;
            break;
        }
        default:
            break;
    }
    self.view_back.hidden = YES;
    self.view_finish.hidden = YES;
    UIAlertView* alert =[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定把接力棒交给%@?",username] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    alert.tag = 1;
    [alert show];
}
- (void)resetUserView{
    self.view_user1.frame = CGRectMake(110, 30+IOS7OFFSIZE, 100, 100);
    self.view_user2.frame = CGRectMake(10, 47+IOS7OFFSIZE, 100, 100);
    self.view_user3.frame = CGRectMake(210, 47+IOS7OFFSIZE, 100, 100);
//    self.view_user1.hidden = NO;
//    self.view_user2.hidden = NO;
//    self.view_user3.hidden = NO;
    self.view_back.hidden = NO;
    self.view_finish.hidden = NO;
}

#pragma -mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        switch (buttonIndex) {
            case 0:
            {
                CNGPSPoint4Match* gpsPoint = [kApp.match_pointList lastObject];
                //确定交棒的接口
                NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                [params setObject:kApp.uid forKey:@"uid"];
                [params setObject:kApp.mid forKey:@"mid"];
                [params setObject:kApp.gid forKey:@"gid"];
                [params setObject:self.joinid forKey:@"joinid"];
                NSMutableArray* pointList = [[NSMutableArray alloc]init];
                NSMutableDictionary* onepoint = [[NSMutableDictionary alloc]init];
                [onepoint setObject:[NSString stringWithFormat:@"%llu",gpsPoint.time*1000] forKey:@"uptime"];
                [onepoint setObject:[NSString stringWithFormat:@"%f",kApp.match_totaldis] forKey:@"distanceur"];
                [onepoint setObject:[NSString stringWithFormat:@"%i",gpsPoint.isInTrack] forKey:@"inrunway"];
                [onepoint setObject:[NSString stringWithFormat:@"%f",gpsPoint.lat] forKey:@"slat"];
                [onepoint setObject:[NSString stringWithFormat:@"%f",gpsPoint.lon] forKey:@"slon"];
                [pointList addObject:onepoint];
                SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
                NSString* pointJson = [jsonWriter stringWithObject:pointList];
                [params setObject:pointJson forKey:@"longitude"];
                kApp.networkHandler.delegate_confirmTransmit = self;
                [kApp.networkHandler doRequest_confirmTransmit:params];
                [self.timer_look_submit invalidate];
                [kApp.timer_one_point invalidate];
                [kApp.timer_secondplusplus invalidate];
                [kApp.match_timer_report invalidate];
                break;
            }
            case 1:
            {
                [alertView dismissWithClickedButtonIndex:1 animated:YES];
                [self resetUserView];
            }
            default:
                break;
        }
    }else{
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
- (void)transmitRelayDidFailed:(NSString *)mes{
    
}
- (void)transmitRelayDidSuccess:(NSDictionary *)resultDic{
    NSArray* array = [resultDic objectForKey:@"list"];
    if([array count]<1){
        self.view_user1.hidden = YES;
        self.view_user2.hidden = YES;
        self.view_user3.hidden = YES;
        self.label_test.text = @"正在搜索接棒队员，请稍候...";
    }else{
        self.label_test.text = [NSString stringWithFormat:@"搜索到%i个人",(int)[array count]];
        self.view_user1.hidden = YES;
        self.view_user2.hidden = YES;
        self.view_user3.hidden = YES;
        //必有用户1
        self.view_user1.hidden = NO;
        NSDictionary* run_user_dic = [array objectAtIndex:0];
        self.label_user1.text = [run_user_dic objectForKey:@"nickname"];
        self.joinid1 = [run_user_dic objectForKey:@"uid"];
        self.avatarurl1 = [run_user_dic objectForKey:@"imgpath"];
        if(self.avatarurl1 == nil){
            [self.button_user1 setBackgroundImage:[UIImage imageNamed:@"avatar_default.png"] forState:UIControlStateNormal];
        }else{
            UIImage* image = [kApp.avatarDic objectForKey:self.avatarurl1];
            if(image != nil){//缓存中有
                [self.button_user1 setBackgroundImage:image forState:UIControlStateNormal];
            }else{//下载
                [self downloadImage:1];
            }
        }
        if([array count]>1){
            self.view_user2.hidden = NO;
            run_user_dic = [array objectAtIndex:1];
            self.label_user2.text = [run_user_dic objectForKey:@"nickname"];
            self.joinid2 = [run_user_dic objectForKey:@"uid"];
            self.avatarurl2 = [run_user_dic objectForKey:@"imgpath"];
            if(self.avatarurl2 == nil){
                [self.button_user2 setBackgroundImage:[UIImage imageNamed:@"avatar_default.png"] forState:UIControlStateNormal];
            }else{
                UIImage* image = [kApp.avatarDic objectForKey:self.avatarurl2];
                if(image != nil){//缓存中有
                    [self.button_user2 setBackgroundImage:image forState:UIControlStateNormal];
                }else{//下载
                    [self downloadImage:2];
                }
            }
        }
        if([array count]>2){
            self.view_user3.hidden = NO;
            run_user_dic = [array objectAtIndex:2];
            self.label_user3.text = [run_user_dic objectForKey:@"nickname"];
            self.joinid3 = [run_user_dic objectForKey:@"uid"];
            self.avatarurl3 = [run_user_dic objectForKey:@"imgpath"];
            if(self.avatarurl3 == nil){
                [self.button_user3 setBackgroundImage:[UIImage imageNamed:@"avatar_default.png"] forState:UIControlStateNormal];
            }else{
                UIImage* image = [kApp.avatarDic objectForKey:self.avatarurl3];
                if(image != nil){//缓存中有
                    [self.button_user3 setBackgroundImage:image forState:UIControlStateNormal];
                }else{//下载
                    [self downloadImage:3];
                }
            }
        }
    }
}
- (void)confirmTransmitDidFailed:(NSString *)mes{
    
}
- (void)confirmTransmitDidSuccess:(NSDictionary *)resultDic{
    //先交接棒，然后结束本次跑步
//    [self transmitRelayAnimation];
    kApp.isbaton = 0;
    [self startAnimation];
}
- (void)startAnimation{
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
    [CNAppDelegate finishThisRun];
    //播放语音
    NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
    [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.match_totaldis] forKey:@"distance"];
    [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.match_historySecond] forKey:@"second"];
    [kApp.voiceHandler voiceOfapp:@"match_running_transmit_relay" :voice_params];
    CNFinishViewController* finishVC = [[CNFinishViewController alloc]init];
    [self.navigationController pushViewController:finishVC animated:YES];
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
- (void)downloadImage:(int)index{
    NSLog(@"downloadImage");
    NSString* imagePath;
    if(index == 1){
        imagePath = self.avatarurl1;
    }else if(index == 2){
        imagePath = self.avatarurl2;
    }else if(index == 3){
        imagePath = self.avatarurl3;
    }
    NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,imagePath];
    NSLog(@"avatar is %@",imageURL);
    NSURL *url = [NSURL URLWithString:imageURL];
    ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
    Imagerequest.tag = index;
    Imagerequest.timeOutSeconds = 15;
    [Imagerequest setDelegate:self];
    [Imagerequest startAsynchronous];
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    int index = (int)request.tag;
    UIImage *image = [[UIImage alloc] initWithData:[request responseData]];
    if(image){
        if(index == 1){
            [self.button_user1 setBackgroundImage:image forState:UIControlStateNormal];
            [kApp.avatarDic setObject:image forKey:self.avatarurl1];
        }else if(index == 2){
            [self.button_user2 setBackgroundImage:image forState:UIControlStateNormal];
            [kApp.avatarDic setObject:image forKey:self.avatarurl2];
        }else if(index == 3){
            [self.button_user3 setBackgroundImage:image forState:UIControlStateNormal];
            [kApp.avatarDic setObject:image forKey:self.avatarurl3];
        }
    }
}
- (void)transmitRelayAnimation{
    self.imageview_relay.hidden = NO;
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:2.0];
    int length = 568;
    if(iPhone5){
        length = 568;
    }else{
        length = 480;
    }
    self.imageview_relay.frame = CGRectMake(130, 100, 60, 60);
    [UIView commitAnimations];
}
-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSLog(@"动画结束！！！！！！");
    self.imageview_relay.hidden = YES;
    [CNAppDelegate finishThisRun];
    
    //播放语音
    NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
    [voice_params setObject:[NSString stringWithFormat:@"%f",kApp.match_totaldis] forKey:@"distance"];
    [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.match_historySecond] forKey:@"second"];
    [kApp.voiceHandler voiceOfapp:@"match_running_transmit_relay" :voice_params];
    
    CNFinishViewController* finishVC = [[CNFinishViewController alloc]init];
    [self.navigationController pushViewController:finishVC animated:YES];
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
- (void)cancelTransmitDidFailed:(NSString *)mes{
    
}
- (void)cancelTransmitDidSuccess:(NSDictionary *)resultDic{
    
}
@end

//
//  CNGroupListViewController.m
//  YaoPao
//
//  Created by zc on 14-9-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNGroupListViewController.h"
#import "CNNetworkHandler.h"
#import "ASIHTTPRequest.h"
#import "CNUtil.h"
#import "CNDistanceImageView.h"
#import "CNSpeedImageView.h"

@interface CNGroupListViewController ()

@end

@implementation CNGroupListViewController
@synthesize tabIndex;
@synthesize imageviewList;
@synthesize urlList;
@synthesize timer_km;
@synthesize timer_personal;
@synthesize big_div;
@synthesize image_km;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    self.label_tname.text = [kApp.matchDic objectForKey:@"groupname"];
    self.imageviewList = [[NSMutableArray alloc]init];
    self.urlList = [[NSMutableArray alloc]init];
    [self requestPersonal];
    self.timer_personal = [NSTimer scheduledTimerWithTimeInterval:kMatchReportInterval target:self selector:@selector(requestPersonal) userInfo:nil repeats:YES];
    self.big_div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(4, 60+IOS7OFFSIZE, 260, 64)];
    self.big_div.distance = 0;
    self.big_div.color = @"red";
    [self.big_div fitToSize];
    [self.view addSubview:self.big_div];
    self.image_km = [[UIImageView alloc]initWithFrame:CGRectMake(self.big_div.frame.origin.x+self.big_div.frame.size.width, 60+IOS7OFFSIZE,52, 64)];
    self.image_km.image = [UIImage imageNamed:@"redkm.png"];
    [self.view addSubview:self.image_km];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.timer_personal invalidate];
    [self.timer_km invalidate];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestPersonal{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    kApp.networkHandler.delegate_listPersonal = self;
    [kApp.networkHandler doRequest_listPersonal:params];
    [self displayLoading];
}
- (void)requestKm{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    kApp.networkHandler.delegate_matchListInfo = self;
    [kApp.networkHandler doRequest_listKM:params];
    [self displayLoading];
}

- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)button_tab_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            if(self.tabIndex == 0)return;
            self.tabIndex = 0;
            [self.button_personal setBackgroundColor:[UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1]];
            [self.button_km setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1]];
            [self.timer_km invalidate];
            [self requestPersonal];
            self.timer_personal = [NSTimer scheduledTimerWithTimeInterval:kMatchReportInterval target:self selector:@selector(requestPersonal) userInfo:nil repeats:YES];
            break;
        }
        case 1:
        {
            if(self.tabIndex == 1)return;
            self.tabIndex = 1;
            [self.button_personal setBackgroundColor:[UIColor colorWithRed:89.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1]];
            [self.button_km setBackgroundColor:[UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1]];
            [self.timer_personal invalidate];
            [self requestKm];
            self.timer_km = [NSTimer scheduledTimerWithTimeInterval:kMatchReportInterval target:self selector:@selector(requestKm) userInfo:nil repeats:YES];
            break;
        }
            
            
        default:
            break;
    }
}
- (void)clearScrollview{
    for (UIView *view in self.scrollview.subviews) {
        [view removeFromSuperview];
    }
    [self.imageviewList removeAllObjects];
    [self.urlList removeAllObjects];
    
}
#pragma mark- delegate
- (void)listPersonalDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)listPersonalDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    [self clearScrollview];
    double distance = ([[resultDic objectForKey:@"distancegr"]doubleValue]+5)/1000.0;
    self.big_div.distance = distance;
    self.big_div.color = @"red";
    [self.big_div fitToSize];
    self.image_km.frame = CGRectMake(self.big_div.frame.origin.x+self.big_div.frame.size.width, 60+IOS7OFFSIZE,52, 64);
    
    NSArray* dataList = [resultDic objectForKey:@"list"];
    if([dataList count]>0){
        int y_used = 0;
        for(int i=0;i<[dataList count];i++){
            NSDictionary* oneRecordDic = [dataList objectAtIndex:i];
            UIView *view_one_record = [[UIView alloc]initWithFrame:CGRectMake(0, y_used, 320, 60)];
            //头像
            UIImageView* userAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
            userAvatar.image = [UIImage imageNamed:@"avatar_default.png"];
            NSString* avatarUrl = [oneRecordDic objectForKey:@"imgpath"];
            if(avatarUrl == nil){
                avatarUrl = @"";
            }else{
                UIImage* image = [kApp.avatarDic objectForKey:avatarUrl];
                if(image != nil){//缓存中有
                    NSLog(@"缓存里有");
                    userAvatar.image = image;
                }else{//下载
                    NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,avatarUrl];
                    NSLog(@"avatar is %@",imageURL);
                    NSURL *url = [NSURL URLWithString:imageURL];
                    ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
                    Imagerequest.tag = i;
                    Imagerequest.timeOutSeconds = 15;
                    [Imagerequest setDelegate:self];
                    [Imagerequest startAsynchronous];
                }
            }
            [view_one_record addSubview:userAvatar];
            [self.urlList addObject:avatarUrl];
            [self.imageviewList addObject:userAvatar];
            //username
            
            UILabel* label_name = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 100, 60)];
            label_name.textAlignment = NSTextAlignmentLeft;
            label_name.font = [UIFont systemFontOfSize:15];
            label_name.text = [oneRecordDic objectForKey:@"nickname"];
            [view_one_record addSubview:label_name];
            
            double distance = [[oneRecordDic objectForKey:@"km"]doubleValue];
            CNDistanceImageView* div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(160, 14, 130, 32)];
            div.distance = (distance+5)/1000.0;
            div.color = @"red";
            [div fitToSize];
            UIImageView* image_km_one = [[UIImageView alloc]initWithFrame:CGRectMake(div.frame.origin.x+div.frame.size.width, 14,26, 32)];
            image_km_one.image = [UIImage imageNamed:@"redkm.png"];
            [view_one_record addSubview:div];
            [view_one_record addSubview:image_km_one];
            
            UIView *view_line = [[UIView alloc]initWithFrame:CGRectMake(0, 59, 320, 1)];
            [view_line setBackgroundColor:[UIColor lightGrayColor]];
            [view_one_record addSubview:view_line];
            
            [self.scrollview addSubview:view_one_record];
            y_used += 60;
        }
        [self.scrollview setContentSize:CGSizeMake(320, y_used)];
        
    }
}
#pragma -mark ASIHttpRequest delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    int tag = request.tag;
    UIImage *image = [[UIImage alloc] initWithData:[request responseData]];
    if(image){
        ((UIImageView*)[self.imageviewList objectAtIndex:tag]).image = image;
        [kApp.avatarDic setObject:image forKey:[self.urlList objectAtIndex:tag]];
    }
}
- (void)matchListInfoDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)matchListInfoDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    [self clearScrollview];
    double distance = ([[resultDic objectForKey:@"distancegr"]doubleValue]+5)/1000.0;
    self.big_div.color = @"red";
    self.big_div.distance = distance;
    [self.big_div fitToSize];
    self.image_km.frame = CGRectMake(self.big_div.frame.origin.x+self.big_div.frame.size.width, 60+IOS7OFFSIZE,52, 64);
    NSArray* dataList = [resultDic objectForKey:@"list"];
    if([dataList count]>0){
        int y_used = 0;
        for(int i = 0;i<[dataList count];i++){
            NSDictionary* oneRecordDic = [dataList objectAtIndex:i];
            int kmIndex = [[oneRecordDic objectForKey:@"km"]intValue];
            int usetime = [[oneRecordDic objectForKey:@"usetime"]intValue];
            
            UIView *view_one_record = [[UIView alloc]initWithFrame:CGRectMake(0, y_used, 320, 60)];
            //公里
            UILabel* label_km = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 60)];
            label_km.textAlignment = NSTextAlignmentLeft;
            label_km.font = [UIFont systemFontOfSize:15];
            label_km.text = [NSString stringWithFormat:@"第%i公里",kmIndex];
            [view_one_record addSubview:label_km];
            //配速
//            UILabel* label_speed = [[UILabel alloc]initWithFrame:CGRectMake(220, 0, 100, 60)];
//            label_speed.textAlignment = NSTextAlignmentRight;
//            label_speed.font = [UIFont systemFontOfSize:15];
//            label_speed.text = [CNUtil pspeedStringFromSecond:usetime];
//            [view_one_record addSubview:label_speed];
            
            CNSpeedImageView* siv = [[CNSpeedImageView alloc]initWithFrame:CGRectMake(220, 14, 100, 32)];
            siv.time = usetime;
            siv.color = @"red";
            [siv fitToSize];
            [view_one_record addSubview:siv];
            
            
            int image_x = 170;
            NSArray* array = [oneRecordDic objectForKey:@"datas"];
            for(int j = 0;j<[array count];j++){
                NSDictionary* dic = [array objectAtIndex:j];
                UIImageView* userAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(image_x, 10, 40, 40)];
                userAvatar.image = [UIImage imageNamed:@"avatar_default.png"];
                NSString* avatarUrl = [dic objectForKey:@"imgpath"];
                if(avatarUrl == nil){
                    avatarUrl = @"";
                }else{
                    NSLog(@"image dic is %@",kApp.avatarDic);
                    NSLog(@"avatarUrl is %@",avatarUrl);
                    UIImage* image = [kApp.avatarDic objectForKey:avatarUrl];
                    if(image != nil){//缓存中有
                        NSLog(@"缓存里有");
                        userAvatar.image = image;
                    }else{//下载
                        NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,avatarUrl];
                        NSLog(@"avatar is %@",imageURL);
                        NSURL *url = [NSURL URLWithString:imageURL];
                        ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
                        Imagerequest.tag = [self.imageviewList count];
                        Imagerequest.timeOutSeconds = 15;
                        [Imagerequest setDelegate:self];
                        [Imagerequest startAsynchronous];
                    }
                }
                [view_one_record addSubview:userAvatar];
                [self.urlList addObject:avatarUrl];
                [self.imageviewList addObject:userAvatar];
                image_x = image_x-50;
            }
            
            UIView *view_line = [[UIView alloc]initWithFrame:CGRectMake(0, 59, 320, 1)];
            [view_line setBackgroundColor:[UIColor lightGrayColor]];
            [view_one_record addSubview:view_line];
            
            [self.scrollview addSubview:view_one_record];
            y_used += 60;
        }
        
        [self.scrollview setContentSize:CGSizeMake(320, y_used)];
    }
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
    [self disableAllButton];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
    [self enableAllButton];
}
- (void)disableAllButton{
    self.button_back.enabled = NO;
    self.button_km.enabled = NO;
    self.button_personal.enabled = NO;
}
- (void)enableAllButton{
    self.button_back.enabled = YES;
    self.button_km.enabled = YES;
    self.button_personal.enabled = YES;
}
@end

//
//  CNGroupInfoViewController.m
//  YaoPao
//
//  Created by zc on 14-8-17.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNGroupInfoViewController.h"
#import "CNNoRunMapViewController.h"
#import "CNGroupListViewController.h"
#import "CNUtil.h"
#import "ASIHTTPRequest.h"
#import "CNMatchAvatarAnnotationView.h"
#import "CNLocationHandler.h"
#import "CNEncryption.h"
#import "CNTestGEOS.h"
#import "CNNotRunTransmitRelayViewController.h"
#import "CNNotInViewController.h"
#import "CNMessageViewController.h"
#import "CNDistanceImageView.h"


@interface CNGroupInfoViewController ()

@end

@implementation CNGroupInfoViewController
@synthesize mapView;
@synthesize timer_refresh_data;
@synthesize imagePath;
@synthesize avatarImage;
@synthesize lon;
@synthesize lat;
@synthesize annotation;
@synthesize div;
@synthesize image_km;
@synthesize from;

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
- (void)button_white_down:(id)sender{
    switch ([sender tag]) {
        case 1:
            self.view_me.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        case 2:
            self.view_list.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
        case 3:
            self.view_message.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
            break;
            
        default:
            break;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    
    [self.button_me addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_list addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_message addTarget:self action:@selector(button_white_down:) forControlEvents:UIControlEventTouchDown];
    
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    [self.view_mapContainer addSubview:self.mapView];
    [self.view_mapContainer sendSubviewToBack:self.mapView];
    
    if(kApp.hasFinishTeamMatch){
        self.view_message.hidden = YES;
        self.view_transmit.hidden = YES;
    }else{
        self.view_message.hidden = NO;
        self.view_transmit.hidden = NO;
    }
    if([self.from isEqualToString:@"main"]){
        self.button_back.hidden = NO;
    }else{
        self.button_back.hidden = YES;
    }
    self.label_uname.text = [kApp.userInfoDic objectForKey:@"nickname"];
    self.label_tName.text = [kApp.matchDic objectForKey:@"groupname"];
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.image_avatar.image = [[UIImage alloc] initWithData:imageData];
    }
    self.div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(5, 200+IOS7OFFSIZE, 130, 32)];
    self.div.distance = 0;
    self.div.color = @"red";
    [self.div fitToSizeLeft];
    [self.view addSubview:self.div];
    self.image_km = [[UIImageView alloc]initWithFrame:CGRectMake(self.div.frame.origin.x+self.div.frame.size.width, 200+IOS7OFFSIZE,26, 32)];
    self.image_km.image = [UIImage imageNamed:@"redkm.png"];
    [self.view addSubview:self.image_km];
    [self drawTrack];//画赛道
    [self drawTakeOverZone];//画接力区
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(kApp.hasMessage){
        self.imageview_dot.hidden = NO;
    }else{
        self.imageview_dot.hidden = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self requestData];
    self.timer_refresh_data = [NSTimer scheduledTimerWithTimeInterval:kMatchReportInterval target:self selector:@selector(requestData) userInfo:nil repeats:YES];
}
- (void)drawTakeOverZone{
    NSArray* tracklist = [kApp.match_takeover_zone componentsSeparatedByString:@", "];
    CLLocationCoordinate2D coordinates[[tracklist count]];
    for(int i = 0;i<[tracklist count];i++){
        NSArray* onepoint = [[tracklist objectAtIndex:i] componentsSeparatedByString:@" "];
        coordinates[i].longitude = [[onepoint objectAtIndex:0]doubleValue];
        coordinates[i].latitude = [[onepoint objectAtIndex:1]doubleValue];
    }
    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:[tracklist count]];
    polygon.title = @"tackover";
    [self.mapView addOverlay:polygon];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.timer_refresh_data invalidate];
//    self.mapView.centerCoordinate.latitude
//    self.mapView.centerCoordinate.longitude
    NSLog(@"lon is %f,lat is %f",self.mapView.centerCoordinate.longitude,self.mapView.centerCoordinate.latitude);
}
- (void)requestData{
    kApp.networkHandler.delegate_teamSimpleInfo = self;
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    [kApp.networkHandler doRequest_smallMapPage:params];
    [self displayLoading];
}
- (void)drawTrack{
    double min_lon = 0;
    double min_lat = 0;
    double max_lon = 0;
    double max_lat = 0;
    NSArray* tracklist = [kApp.match_stringTrackZone componentsSeparatedByString:@":"];
    for(int i=0;i<[tracklist count];i++){
        NSArray* oneTrackStrlist = [[tracklist objectAtIndex:i] componentsSeparatedByString:@", "];
        int count = [oneTrackStrlist count];
        CLLocationCoordinate2D polylineCoords[count];
        for(int j=0;j<[oneTrackStrlist count];j++){
            NSArray* lonlat = [[oneTrackStrlist objectAtIndex:j] componentsSeparatedByString:@" "];
            polylineCoords[j].longitude = [[lonlat objectAtIndex:0]doubleValue];
            polylineCoords[j].latitude = [[lonlat objectAtIndex:1]doubleValue];
            if(j == 0){
                max_lon = min_lon = polylineCoords[j].longitude;
                max_lat = min_lat = polylineCoords[j].latitude;
            }
            if(polylineCoords[j].longitude < min_lon){
                min_lon = polylineCoords[j].longitude;
            }
            if(polylineCoords[j].latitude < min_lat){
                min_lat = polylineCoords[j].latitude;
            }
            if(polylineCoords[j].longitude > max_lon){
                max_lon = polylineCoords[j].longitude;
            }
            if(polylineCoords[j].latitude > max_lat){
                max_lat = polylineCoords[j].latitude;
            }
        }
        MAPolygon *polygon = [MAPolygon polygonWithCoordinates:polylineCoords count:count];
        polygon.title = @"track";
        [self.mapView addOverlay:polygon];
    }
//    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
//    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.002, max_lon-min_lon+0.002);
//    MACoordinateRegion region = MACoordinateRegionMake(center, span);
//    [self.mapView setRegion:region animated:NO];
}
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygon* polygon = (MAPolygon*)overlay;
        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
        if([polygon.title isEqualToString:@"track"]){
            polygonView.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.2];
        }else if([polygon.title isEqualToString:@"tackover"]){
            polygonView.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        }
        
        return polygonView;
    }
    return nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            CNNoRunMapViewController* norunmapVC = [[CNNoRunMapViewController alloc]init];
            [self.navigationController pushViewController:norunmapVC animated:YES];
            break;
        }
        case 1:{
            NSLog(@"用户运动记录");
            self.view_me.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
//            CNRunRecordViewController* recordVC = [[CNRunRecordViewController alloc]init];
//            recordVC.from = @"match";
//            [self.navigationController pushViewController:recordVC animated:YES];

            break;
        }
        case 2:
        {
            self.view_list.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CNGroupListViewController* listVC = [[CNGroupListViewController alloc]init];
            [self.navigationController pushViewController:listVC animated:YES];
            break;
        }
        case 3:
        {
            NSLog(@"系统消息");
            self.view_message.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
            CNMessageViewController* messageVC = [[CNMessageViewController alloc]init];
            [self.navigationController pushViewController:messageVC animated:YES];
            break;
        }
        case 4:
        {
            //偏移
            CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(kApp.locationHandler.userLocation_lat, kApp.locationHandler.userLocation_lon);
            CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
#ifdef SIMULATORTEST
            int isInTakeOverZone = 0;
#else
            int isInTakeOverZone = [kApp.geosHandler isInTheTakeOverZones:encryptionPoint.longitude :encryptionPoint.latitude];
# endif
            NSLog(@"是否在交接区:%i",isInTakeOverZone);
            if(isInTakeOverZone != -1){
                CNNotRunTransmitRelayViewController* notRunVC = [[CNNotRunTransmitRelayViewController alloc]init];
                [self.navigationController pushViewController:notRunVC animated:YES];
            }else{
                CNNotInViewController* notinVC = [[CNNotInViewController alloc]init];
                [self.navigationController pushViewController:notinVC animated:YES];
            }
            break;
        }
        default:
            break;
    }
}
#pragma mark -team info delegate
- (void)teamSimpleInfoDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)teamSimpleInfoDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    double distance = [[resultDic objectForKey:@"distancegr"]doubleValue];
    
    self.div.distance = (distance+5)/1000.0;
    [self.div fitToSizeLeft];
    self.image_km.frame = CGRectMake(self.div.frame.origin.x+self.div.frame.size.width, 200+IOS7OFFSIZE,26, 32);
    NSDictionary* infoDic = [resultDic objectForKey:@"longitude"];
    if([[infoDic allKeys] count]>0){
        long long time = [[infoDic objectForKey:@"uptime"]longLongValue]/1000;
        self.label_date.text = [CNUtil dateStringFromTimeStamp:time];
        int duringTime = (int)(time-kApp.match_start_timestamp);
        self.label_time.text = [CNUtil duringTimeStringFromSecond:duringTime];
        if(distance>1){
            int speed_second = 1000*(duringTime/distance);
            self.label_pspeed.text = [CNUtil pspeedStringFromSecond:speed_second];
            float perspeed = [CNUtil speedFromPspeed:speed_second];
            self.label_avr_speed.text = [NSString stringWithFormat:@"%0.2f",perspeed];
        }
        self.lon = [[infoDic objectForKey:@"slon"]doubleValue];
        self.lat = [[infoDic objectForKey:@"slat"]doubleValue];
        NSLog(@"self.lon is %f,self.lat is %f",self.lon,self.lat);
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.lat, self.lon)];
        [self.mapView setZoomLevel:16];
        NSDictionary* runnerDic = [resultDic objectForKey:@"runner"];
        NSString* thisPath = [runnerDic objectForKey:@"imgpath"];
        if(thisPath == nil){//无头像
            self.avatarImage = [UIImage imageNamed:@"avatar_default.png"];
            [self.mapView removeAnnotation:self.annotation];
            self.annotation = [[MAPointAnnotation alloc] init];
            self.annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
            [self.mapView addAnnotation:self.annotation];
        }else{
            UIImage* image = [kApp.avatarDic objectForKey:thisPath];
            if(image != nil){//缓存中有
                self.avatarImage = image;
                [self.mapView removeAnnotation:self.annotation];
                self.annotation = [[MAPointAnnotation alloc] init];
                self.annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
                [self.mapView addAnnotation:self.annotation];
            }else{//缓存中也没有
                self.imagePath = thisPath;
                [self downloadImage];
            }
        }
    }
}
- (void)downloadImage{
    NSLog(@"downloadImage");
    NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,self.imagePath];
    NSLog(@"avatar is %@",imageURL);
    NSURL *url = [NSURL URLWithString:imageURL];
    ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
    Imagerequest.tag = 1;
    Imagerequest.timeOutSeconds = 15;
    [Imagerequest setDelegate:self];
    [Imagerequest startAsynchronous];
    [self displayLoading];
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    [self hideLoading];
    UIImage *image = [[UIImage alloc] initWithData:[request responseData]];
    if(image){
        [kApp.avatarDic setObject:image forKey:self.imagePath];
        self.avatarImage = image;
        [self.mapView removeAnnotation:self.annotation];
        self.annotation = [[MAPointAnnotation alloc] init];
        self.annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
        [self.mapView addAnnotation:self.annotation];
    }else{
        self.avatarImage = [UIImage imageNamed:@"avatar_default.png"];
        [self.mapView removeAnnotation:self.annotation];
        self.annotation = [[MAPointAnnotation alloc] init];
        self.annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
        [self.mapView addAnnotation:self.annotation];
    }
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([self.annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        CNMatchAvatarAnnotationView *annotationView = (CNMatchAvatarAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[CNMatchAvatarAnnotationView alloc] initWithAnnotation:self.annotation reuseIdentifier:customReuseIndetifier];
            // must set to NO, so we can show the custom callout view.
            annotationView.centerOffset = CGPointMake(0, -15);
        }
        annotationView.imageview.image = self.avatarImage;
        return annotationView;
    }
    return nil;
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
    self.button_map.enabled = NO;
    self.button_me.enabled = NO;
    self.button_list.enabled = NO;
    self.button_message.enabled = NO;
    self.button_relay.enabled = NO;
}
- (void)enableAllButton{
    self.button_map.enabled = YES;
    self.button_me.enabled = YES;
    self.button_list.enabled = YES;
    self.button_message.enabled = YES;
    self.button_relay.enabled = YES;
}
@end

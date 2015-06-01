//
//  CNNoRunMapViewController.m
//  YaoPao
//
//  Created by zc on 14-9-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNNoRunMapViewController.h"
#import "CNNetworkHandler.h"
#import "ASIHTTPRequest.h"
#import "CNMatchAvatarAnnotationView.h"

#define kTeamInfoInterval 10

@interface CNNoRunMapViewController ()

@end

@implementation CNNoRunMapViewController
@synthesize timer_refresh_data;
@synthesize imagePath;
@synthesize avatarImage;
@synthesize lat;
@synthesize lon;
@synthesize annotation;
@synthesize mapView;

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
//    int map_height;
//    if(iPhone5){
//        map_height = 548;
//    }else{
//        map_height = 460;
//    }
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, IOS7OFFSIZE, 320, 548)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    [self drawTrack];//画赛道
    [self drawTakeOverZone];//画接力区
    [self requestData];
    self.timer_refresh_data = [NSTimer scheduledTimerWithTimeInterval:kTeamInfoInterval target:self selector:@selector(requestData) userInfo:nil repeats:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.timer_refresh_data invalidate];
    self.mapView.delegate = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)drawTrack{
    double min_lon = 0;
    double min_lat = 0;
    double max_lon = 0;
    double max_lat = 0;
    NSArray* tracklist = [kApp.match_stringTrackZone componentsSeparatedByString:@":"];
    for(int i=0;i<[tracklist count];i++){
        NSArray* oneTrackStrlist = [[tracklist objectAtIndex:i] componentsSeparatedByString:@", "];
        int count = (int)[oneTrackStrlist count];
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
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.002, max_lon-min_lon+0.002);
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:NO];
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
- (void)requestData{
    kApp.networkHandler.delegate_teamSimpleInfo = self;
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    [kApp.networkHandler doRequest_smallMapPage:params];
    [self displayLoading];
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
- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            self.mapView.userTrackingMode = MAUserTrackingModeFollow;
            break;
        }
        case 1:
        {
            [self.navigationController popViewControllerAnimated:YES];
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
    NSDictionary* infoDic = [resultDic objectForKey:@"longitude"];
    self.lon = [[infoDic objectForKey:@"slon"]doubleValue];
    self.lat = [[infoDic objectForKey:@"slat"]doubleValue];
    NSDictionary* runnerDic = [resultDic objectForKey:@"runner"];
    self.imagePath = [runnerDic objectForKey:@"imgpath"];
    self.avatarImage = [UIImage imageNamed:@"avatar_default.png"];
    if(self.imagePath == nil){
        [self addAnnotation];
    }else{
        UIImage* image = [kApp.avatarDic objectForKey:self.imagePath];
        if(image != nil){//缓存中有
            self.avatarImage = image;
            [self addAnnotation];
        }else{//下载
            [self downloadImage];
        }
    }
}
- (void)addAnnotation{
    [self.mapView removeAnnotation:self.annotation];
    self.annotation = [[MAPointAnnotation alloc] init];
    self.annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lon);
    [self.mapView addAnnotation:self.annotation];
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
    }
    [self addAnnotation];
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
    self.button_back.enabled = NO;
}
- (void)enableAllButton{
    self.button_back.enabled = YES;
}
@end

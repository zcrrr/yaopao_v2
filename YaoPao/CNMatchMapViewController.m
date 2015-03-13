//
//  CNMatchMapViewController.m
//  YaoPao
//
//  Created by zc on 14-9-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNMatchMapViewController.h"
#import "CNGiveRelayViewController.h"
#import "CNGPSPoint4Match.h"
#import "CNEncryption.h"
#define kIntervalMap 3
@interface CNMatchMapViewController ()

@end

@implementation CNMatchMapViewController
@synthesize mapView;
@synthesize timer_match_map;
@synthesize lastDrawPoint;

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
    int map_height;
    NSData* imageData = kApp.imageData;
    if(imageData){
        self.imageview_avatar.image = [[UIImage alloc] initWithData:imageData];
    }
    self.label_uname.text = [kApp.userInfoDic objectForKey:@"nickname"];
    self.label_tname.text = [kApp.matchDic objectForKey:@"groupname"];
    if(iPhone5){
        map_height = 548;
    }else{
        map_height = 460;
    }
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, IOS7OFFSIZE, 320, 548)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomLevel = 17;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    [self displayLoading];
    [self drawTrack];//画赛道
    [self drawStratZone];//画出发区
    [self drawTakeOverZone];//画接力区
    [self drawRunTrack];//画已经跑得轨迹
    [self hideLoading];
    self.lastDrawPoint = [kApp.match_pointList lastObject];
    self.timer_match_map = [NSTimer scheduledTimerWithTimeInterval:kIntervalMap target:self selector:@selector(drawIncrementLine) userInfo:nil repeats:YES];
}
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.timer_match_map invalidate];
    self.mapView.delegate = nil;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mapView.delegate = self;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)drawIncrementLine{
    //取数组最新值
    CNGPSPoint4Match* newPoint = [kApp.match_pointList lastObject];
    if(newPoint.lon != lastDrawPoint.lon || newPoint.lat != lastDrawPoint.lat){//5秒后点的位置有移动
        int count = 2;
        CLLocationCoordinate2D polylineCoords[count];
        polylineCoords[0].latitude = lastDrawPoint.lat;
        polylineCoords[0].longitude = lastDrawPoint.lon;
        polylineCoords[1].latitude = newPoint.lat;
        polylineCoords[1].longitude = newPoint.lon;
        MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:count];
        polyline.title = @"run";
        [self.mapView addOverlay:polyline];
        lastDrawPoint = newPoint;
    }
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
            CNGiveRelayViewController* relayVC = [[CNGiveRelayViewController alloc]init];
            [self.navigationController pushViewController:relayVC animated:YES];
            break;
        }
        case 2:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
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
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.005, max_lon-min_lon+0.005);
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
- (void)drawStratZone{
    NSArray* tracklist = [kApp.match_stringStartZone componentsSeparatedByString:@", "];
    CLLocationCoordinate2D coordinates[[tracklist count]];
    for(int i = 0;i<[tracklist count];i++){
        NSArray* onepoint = [[tracklist objectAtIndex:i] componentsSeparatedByString:@" "];
        coordinates[i].longitude = [[onepoint objectAtIndex:0]doubleValue];
        coordinates[i].latitude = [[onepoint objectAtIndex:1]doubleValue];
    }
    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:[tracklist count]];
    polygon.title = @"startzone";
    [self.mapView addOverlay:polygon];
}
- (void)drawRunTrack{
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.match_pointList count];
    
    for(i=0;i<pointCount;i++){
        CNGPSPoint4Match* gpsPoint = [kApp.match_pointList objectAtIndex:i];
        if (gpsPoint.lon < 0.01 || i == pointCount-1) {
            CLLocationCoordinate2D polylineCoord[i-n];
            for(j=0;j<i-n;j++){
                CNGPSPoint4Match* gpsPoint = [kApp.match_pointList objectAtIndex:n+j];
                polylineCoord[j].latitude = gpsPoint.lat;
                polylineCoord[j].longitude = gpsPoint.lon;
            }
            MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoord count:i-n];
            polyline.title = @"run";
            [self.mapView addOverlay:polyline];
            n = i+1;//n为下一个起点
        }
    }
}
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc]initWithOverlay:overlay];
        polylineView.lineWidth   = 13.5;  //线宽，必须设置
        polylineView.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
        
        polylineView.lineJoin = kCGLineJoinRound;
        polylineView.lineCap = kCGLineCapRound;
        return polylineView;
    }
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygon* polygon = (MAPolygon*)overlay;
        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
        if([polygon.title isEqualToString:@"track"]){
            polygonView.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.2];
        }else if([polygon.title isEqualToString:@"tackover"]){
            polygonView.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
        }else if([polygon.title isEqualToString:@"startzone"]){
            polygonView.strokeColor = [UIColor orangeColor];
            polygonView.lineWidth = 4;
            polygonView.fillColor = [UIColor clearColor];
        }
        return polygonView;
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
    self.button_relay.enabled = NO;
}
- (void)enableAllButton{
    self.button_back.enabled = YES;
    self.button_relay.enabled = YES;
}
@end

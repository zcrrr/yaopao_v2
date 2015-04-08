//
//  CNRunMapViewController.m
//  YaoPao
//
//  Created by zc on 14-7-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMapViewController.h"
#import "CNGPSPoint.h"
#import "FeelingViewController.h"
#import "CNEncryption.h"
#import "Toast+UIView.h"
#import "CNUtil.h"
#import "CNVoiceHandler.h"
#import "CNRunManager.h"
#import "ColorValue.h"
#define kIntervalMap 2

@interface CNRunMapViewController ()

@end

@implementation CNRunMapViewController
@synthesize mapView;
@synthesize timer_map;
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
    [self.button_reset fillColor:kClear :[UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1] :kWhite :kWhite];
    [self.button_complete fillColor:kClear :[UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1] :kWhite :kWhite];
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    int map_height;
    if(iPhone5){
        map_height = 568-IOS7OFFSIZE-50;
    }else{
        map_height = 568-IOS7OFFSIZE-50;
    }
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, IOS7OFFSIZE, 320, map_height)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    self.sliderview.delegate = self;
    [self.sliderview setBackgroundColor:[UIColor clearColor]];
    [self.sliderview setText:@"滑动暂停"];
    //将当前数组中的数据画到地图上
    self.lastDrawPoint = [kApp.runManager.GPSList lastObject];
    [self drawRunTrack];
    [self setGPSImage];
    self.timer_map = [NSTimer scheduledTimerWithTimeInterval:kIntervalMap target:self selector:@selector(drawIncrementLine) userInfo:nil repeats:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.timer_map invalidate];
    self.mapView.delegate = nil;
}
- (void)setFollow{
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}
- (void)drawIncrementLine{
    //取数组最新值
    CNGPSPoint* newPoint = [kApp.runManager.GPSList lastObject];
    if(newPoint.lon != lastDrawPoint.lon || newPoint.lat != lastDrawPoint.lat){//5秒后点的位置有移动
        int count = 2;
        CLLocationCoordinate2D polylineCoords[count];
        CLLocationCoordinate2D wgs84Point1 = CLLocationCoordinate2DMake(lastDrawPoint.lat, lastDrawPoint.lon);
        CLLocationCoordinate2D encryptionPoint1 = [CNEncryption encrypt:wgs84Point1];
        CLLocationCoordinate2D wgs84Point2 = CLLocationCoordinate2DMake(newPoint.lat, newPoint.lon);
        CLLocationCoordinate2D encryptionPoint2 = [CNEncryption encrypt:wgs84Point2];
        polylineCoords[0].latitude = encryptionPoint1.latitude;
        polylineCoords[0].longitude = encryptionPoint1.longitude;
        polylineCoords[1].latitude = encryptionPoint2.latitude;
        polylineCoords[1].longitude = encryptionPoint2.longitude;
        MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:count];
        polyline.title = newPoint.status == 1?@"1":@"2";
        [self.mapView addOverlay:polyline];
        lastDrawPoint = newPoint;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    switch (kApp.runManager.runStatus) {
        case 1:
        {
            self.view_bottom_slider.hidden = NO;
            self.view_bottom_bar.hidden = YES;
            break;
        }
        case 2:
        {
            self.view_bottom_slider.hidden = YES;
            self.view_bottom_bar.hidden = NO;
            break;
        }
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)drawRunTrack{
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.runManager.GPSList count];
    
    
    CLLocationCoordinate2D polylineCoords_backgound[pointCount];
    for(i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.runManager.GPSList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        polylineCoords_backgound[i].latitude = encryptionPoint.latitude;
        polylineCoords_backgound[i].longitude = encryptionPoint.longitude;
    }
    //先画灰色：
    MAPolyline* polyline_pause = [MAPolyline polylineWithCoordinates:polylineCoords_backgound count:pointCount];
    polyline_pause.title = @"2";
    [self.mapView addOverlay:polyline_pause];
    
    CNGPSPoint* firstPoint = [kApp.runManager.GPSList objectAtIndex:0];
    CLLocationCoordinate2D wgs84Point_first = CLLocationCoordinate2DMake(firstPoint.lat, firstPoint.lon);
    CLLocationCoordinate2D encryptionPoint_first = [CNEncryption encrypt:wgs84Point_first];
    double min_lon = encryptionPoint_first.longitude;
    double min_lat = encryptionPoint_first.latitude;
    double max_lon = encryptionPoint_first.longitude;
    double max_lat = encryptionPoint_first.latitude;
    
    int startIndex = 0;
    int endIndex = 0;
    for(i = 0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.runManager.GPSList objectAtIndex:i];
        
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        if(encryptionPoint.longitude < min_lon){
            min_lon = encryptionPoint.longitude;
        }
        if(encryptionPoint.latitude < min_lat){
            min_lat = encryptionPoint.latitude;
        }
        if(encryptionPoint.longitude > max_lon){
            max_lon = encryptionPoint.longitude;
        }
        if(encryptionPoint.latitude > max_lat){
            max_lat = encryptionPoint.latitude;
        }
        
        if(i==0){
            startIndex = 0;
        }else{
            CNGPSPoint* lastPoint = [kApp.runManager.GPSList objectAtIndex:(i-1)];
            if(gpsPoint.status != lastPoint.status){
                if(gpsPoint.status == 1){//运动开始的序列
                    startIndex = i;
                }else if(gpsPoint.status == 2){//暂停开始的序列
                    endIndex = i-1;
                    if(endIndex-startIndex+1<2)continue;
                    CLLocationCoordinate2D polylineCoords[endIndex-startIndex+1];
                    for(j=startIndex,n=0;j<=endIndex;j++,n++){
                        CNGPSPoint* point = [kApp.runManager.GPSList objectAtIndex:j];
                        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(point.lat, point.lon);
                        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
                        polylineCoords[n].latitude = encryptionPoint.latitude;
                        polylineCoords[n].longitude = encryptionPoint.longitude;
                    }
                    MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:endIndex-startIndex+1];
                    polyline.title = @"1";
                    [self.mapView addOverlay:polyline];
                }
            }else if(i == pointCount-1 && gpsPoint.status == 1){//结束的一段
                endIndex = i;
                if(endIndex-startIndex+1<2)continue;
                CLLocationCoordinate2D polylineCoords[endIndex-startIndex+1];
                for(j=startIndex,n=0;j<=endIndex;j++,n++){
                    CNGPSPoint* point = [kApp.runManager.GPSList objectAtIndex:j];
                    CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(point.lat, point.lon);
                    CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
                    polylineCoords[n].latitude = encryptionPoint.latitude;
                    polylineCoords[n].longitude = encryptionPoint.longitude;
                }
                MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:endIndex-startIndex+1];
                polyline.title = @"1";
                [self.mapView addOverlay:polyline];
            }
        }
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.005, max_lon-min_lon+0.005);
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:NO];
}
- (void)testDraw{
    CLLocationCoordinate2D polylineCoords[4];
    polylineCoords[0].latitude = 39.743951;
    polylineCoords[0].longitude = 116.309555;
    polylineCoords[1].latitude = 39.743948;
    polylineCoords[1].longitude = 116.309467;
    polylineCoords[2].latitude = 39.743938;
    polylineCoords[2].longitude = 116.309398;
    polylineCoords[3].latitude = 39.743962;
    polylineCoords[3].longitude = 116.309316;
    MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:4];
    [self.mapView addOverlay:polyline];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(39.743951, 116.309555)];
    [self.mapView setZoomLevel:17];
}
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolyline* polyline = (MAPolyline*)overlay;
        MAPolylineView *polylineView = [[MAPolylineView alloc]initWithOverlay:overlay];
        if([polyline.title isEqualToString:@"1"]){//前景运动状态
            polylineView.lineWidth   = 11.5;  //线宽，必须设置
            polylineView.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
        }else if([polyline.title isEqualToString:@"2"]){//前景暂停状态
            polylineView.lineWidth   = 11.5;  //线宽，必须设置
            polylineView.strokeColor = [UIColor lightGrayColor];
        }else if([polyline.title isEqualToString:@"3"]){//背景
            polylineView.lineWidth   = 15.5;  //线宽，必须设置
            polylineView.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        }
        polylineView.lineJoin = kCGLineJoinRound;
        polylineView.lineCap = kCGLineCapRound;
        return polylineView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"regionDidChangeAnimated");
//    self.mapView.userTrackingMode = MAUserTrackingModeNone;
}
-(void)mapView:(MAMapView*)mapView didUpdateUserLocation:(MAUserLocation*)userLocation
updatingLocation:(BOOL)updatingLocation
{
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
// MBSliderViewDelegate
- (void) sliderDidSlide:(MBSliderView *)slideView {
    [kApp.voiceHandler voiceOfapp:@"run_pause" :nil];
    // Customization example
    NSLog(@"滑动");
    [kApp.runManager changeRunStatus:2];
    self.view_bottom_slider.hidden = YES;
    self.view_bottom_bar.hidden = NO;
}

- (void)setGPSImage{
    
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"是的，完成了");
            kApp.isRunning = 0;
            [kApp.runManager finishOneRun];
            [kApp.timer_playVoice invalidate];
            if(kApp.runManager.distance < 50){
                kApp.gpsLevel = 1;
                //弹出框，距离小于50
                [kApp.window makeToast:@"您运动距离也太短啦！这次就不给您记录了，下次一定要加油！"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [kApp.voiceHandler voiceOfapp:@"run_complete" :voice_params];
                FeelingViewController* moodVC = [[FeelingViewController alloc]init];
                [self.navigationController pushViewController:moodVC animated:YES];
            }
            break;
        }
        default:
            break;
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
            self.mapView.showsUserLocation = NO;
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 2:
        {
            NSLog(@"完成");
            self.button_complete.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"你已经完成这次的运动了吗?" delegate:self cancelButtonTitle:@"不，还没完成" destructiveButtonTitle:nil otherButtonTitles:@"是的，完成了", nil];
            [actionSheet showInView:self.view];
            break;
        }
        case 3:
        {
            self.button_reset.backgroundColor = [UIColor colorWithRed:0 green:123.0/255.0 blue:199.0/255.0 alpha:1];
            [kApp.voiceHandler voiceOfapp:@"run_continue" :nil];
            [kApp.runManager changeRunStatus:1];
            self.view_bottom_slider.hidden = NO;
            self.view_bottom_bar.hidden = YES;
            NSLog(@"恢复");
            break;
        }
        default:
            break;
    }
    
}
@end

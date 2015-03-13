//
//  CNRunMapGoogleViewController.m
//  YaoPao
//
//  Created by zc on 14-12-16.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMapGoogleViewController.h"
#import "CNGPSPoint.h"
#import "CNRunManager.h"
#import "CNVoiceHandler.h"
#import "CNMainViewController.h"
#import "Toast+UIView.h"
#import "CNRunMoodViewController.h"
#define kIntervalMap 2

@interface CNRunMapGoogleViewController ()

@end

@implementation CNRunMapGoogleViewController
@synthesize mapView;
@synthesize lastDrawPoint;
@synthesize timer_map;

- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.button_reset addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_complete addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_GPS = @"gps";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setGPSImage) name:NOTIFICATION_GPS object:nil];
    self.lastDrawPoint = [kApp.oneRunPointList lastObject];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.lastDrawPoint.lat
                                                            longitude:self.lastDrawPoint.lon
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.myLocationEnabled = YES;
//    self.mapView.settings.myLocationButton = YES;
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
//    [self testDraw];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    switch (kApp.runManager.runStatus) {
        case 1:
        {
            self.view_bottom_slider.hidden = NO;
            break;
        }
        case 2:
        {
            self.view_bottom_slider.hidden = YES;
            break;
        }
        default:
            break;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer_map invalidate];
    self.mapView.myLocationEnabled = NO;
}
- (void)drawIncrementLine{
    //取数组最新值
    CNGPSPoint* newPoint = [kApp.runManager.GPSList lastObject];
    if(newPoint.lon != lastDrawPoint.lon || newPoint.lat != lastDrawPoint.lat){//5秒后点的位置有移动
        CLLocationCoordinate2D wgs84Point1 = CLLocationCoordinate2DMake(lastDrawPoint.lat, lastDrawPoint.lon);
        CLLocationCoordinate2D wgs84Point2 = CLLocationCoordinate2DMake(newPoint.lat, newPoint.lon);
        GMSMutablePath* path = [GMSMutablePath path];
        [path addCoordinate:wgs84Point1];
        [path addCoordinate:wgs84Point2];
        GMSPolyline* polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeWidth = 11.5;
        if(kApp.runManager.runStatus == 1){
            polyline.strokeColor = [UIColor greenColor];
        }else{
            polyline.strokeColor = [UIColor lightGrayColor];
        }
        polyline.map = self.mapView;
        lastDrawPoint = newPoint;
    }
}

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
            break;
        case 1:
        {
            self.mapView.myLocationEnabled = NO;
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}
- (IBAction)button_control_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"完成");
            self.button_complete.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"你已经完成这次的运动了吗?" delegate:self cancelButtonTitle:@"不，还没完成" destructiveButtonTitle:nil otherButtonTitles:@"是的，完成了", nil];
            [actionSheet showInView:self.view];
            break;
        }
        case 1:
        {
            self.button_reset.backgroundColor = [UIColor colorWithRed:0 green:123.0/255.0 blue:199.0/255.0 alpha:1];
            [kApp.voiceHandler voiceOfapp:@"run_continue" :nil];
            [kApp.runManager changeRunStatus:1];
            self.view_bottom_slider.hidden = NO;
            NSLog(@"恢复");
            break;
        }
        default:
            break;
    }
}
- (void)drawRunTrack{
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.runManager.GPSList count];
    
    
    GMSMutablePath* path_gray = [GMSMutablePath path];
    for(i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.runManager.GPSList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        [path_gray addCoordinate:wgs84Point];
    }
    //先画灰色：
    GMSPolyline* polyline_gray = [GMSPolyline polylineWithPath:path_gray];
    polyline_gray.strokeWidth = 11.5;
    polyline_gray.strokeColor = [UIColor lightGrayColor];
    polyline_gray.map = self.mapView;
    
    
    CNGPSPoint* firstPoint = [kApp.runManager.GPSList objectAtIndex:0];
    CLLocationCoordinate2D wgs84Point_first = CLLocationCoordinate2DMake(firstPoint.lat, firstPoint.lon);
    double min_lon = wgs84Point_first.longitude;
    double min_lat = wgs84Point_first.latitude;
    double max_lon = wgs84Point_first.longitude;
    double max_lat = wgs84Point_first.latitude;
    
    int startIndex = 0;
    int endIndex = 0;
    for(i = 0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.runManager.GPSList objectAtIndex:i];
        
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        if(wgs84Point.longitude < min_lon){
            min_lon = wgs84Point.longitude;
        }
        if(wgs84Point.latitude < min_lat){
            min_lat = wgs84Point.latitude;
        }
        if(wgs84Point.longitude > max_lon){
            max_lon = wgs84Point.longitude;
        }
        if(wgs84Point.latitude > max_lat){
            max_lat = wgs84Point.latitude;
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
                    GMSMutablePath* path_green = [GMSMutablePath path];
                    for(j=startIndex,n=0;j<=endIndex;j++,n++){
                        CNGPSPoint* point = [kApp.runManager.GPSList objectAtIndex:j];
                        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(point.lat, point.lon);
                        [path_green addCoordinate:wgs84Point];
                    }
                    GMSPolyline* polyline_green = [GMSPolyline polylineWithPath:path_green];
                    polyline_green.strokeWidth = 11.5;
                    polyline_green.strokeColor = [UIColor greenColor];
                    polyline_green.map = self.mapView;
                }
            }else if(i == pointCount-1 && gpsPoint.status == 1){//结束的一段
                endIndex = i;
                if(endIndex-startIndex+1<2)continue;
                GMSMutablePath* path_green = [GMSMutablePath path];
                for(j=startIndex,n=0;j<=endIndex;j++,n++){
                    CNGPSPoint* point = [kApp.runManager.GPSList objectAtIndex:j];
                    CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(point.lat, point.lon);
                    [path_green addCoordinate:wgs84Point];
                }
                GMSPolyline* polyline_green = [GMSPolyline polylineWithPath:path_green];
                polyline_green.strokeWidth = 11.5;
                polyline_green.strokeColor = [UIColor greenColor];
                polyline_green.map = self.mapView;
            }
        }
    }
    CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake(min_lat, min_lon);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(max_lat, max_lon);
    GMSCoordinateBounds* bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:northEast coordinate:southwest];
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
}
//- (void)testDraw{
//    self.path = [GMSMutablePath path];
//    [self.path addCoordinate:CLLocationCoordinate2DMake(39.974041, 116.395322)];
//    [self.path addCoordinate:CLLocationCoordinate2DMake(39.974041+0.005, 116.395322)];
//    [self.path addCoordinate:CLLocationCoordinate2DMake(39.974041+0.01, 116.395322)];
//    [self.path addCoordinate:CLLocationCoordinate2DMake(39.974041+0.015, 116.395322)];
//    self.polyline = [GMSPolyline polylineWithPath:self.path];
//    self.polyline.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
//    self.polyline.strokeWidth = 11.5;
//    self.polyline.map = self.mapView;
//    
//    [path addCoordinate:CLLocationCoordinate2DMake(39.974041+0.015, 116.395322+0.05)];
//    polyline.path = path;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// MBSliderViewDelegate
- (void) sliderDidSlide:(MBSliderView *)slideView {
    [kApp.voiceHandler voiceOfapp:@"run_pause" :nil];
    // Customization example
    NSLog(@"滑动");
    [kApp.runManager changeRunStatus:2];
    self.view_bottom_slider.hidden = YES;
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
                CNMainViewController* mainVC = [[CNMainViewController alloc]init];
                [self.navigationController pushViewController:mainVC animated:YES];
            }else{
                NSMutableDictionary* voice_params = [[NSMutableDictionary alloc]init];
                [voice_params setObject:[NSString stringWithFormat:@"%i",kApp.runManager.distance] forKey:@"distance"];
                [voice_params setObject:[NSString stringWithFormat:@"%i",[kApp.runManager during]/1000] forKey:@"second"];
                [kApp.voiceHandler voiceOfapp:@"run_complete" :voice_params];
                CNRunMoodViewController* moodVC = [[CNRunMoodViewController alloc]init];
                [self.navigationController pushViewController:moodVC animated:YES];
            }
            break;
        }
        default:
            break;
    }
}
- (void)setGPSImage{
    NSString* imageName = [NSString stringWithFormat:@"gps%i.png",kApp.gpsSignal];
    self.image_gps.image = [UIImage imageNamed:imageName];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

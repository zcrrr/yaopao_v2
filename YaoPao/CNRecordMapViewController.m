//
//  CNRecordMapViewController.m
//  YaoPao
//
//  Created by zc on 14-8-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRecordMapViewController.h"
#import "CNUtil.h"
#import "SBJson.h"
#import "CNGPSPoint.h"
#import "CNEncryption.h"
#import "CustomAnnotationView.h"
#import "CNMapImageAnnotationView.h"
#import "CNGPSPoint4Match.h"
#import "CNRunManager.h"
#import "OneKMInfo.h"
#import "CNCustomButton.h"
#import "ColorValue.h"
#define kPopInterval 1000

@interface CNRecordMapViewController ()

@end

@implementation CNRecordMapViewController
@synthesize oneRun;
@synthesize mapView;
@synthesize polyline_back;
@synthesize polyline_forward;

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
    [self.button_back fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 468)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    [self.view_map_container addSubview:self.mapView];
    [self.view_map_container sendSubviewToBack:self.mapView];
    [self.view sendSubviewToBack:self.view_map_container];
    [self initUI];
    
//    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(39.975594, 116.396301);
//    MACoordinateSpan span = MACoordinateSpanMake(0.015, 0.005);
//    MACoordinateRegion region = MACoordinateRegionMake(center, span);
//    [self.mapView setRegion:region animated:NO];

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //区分是否是比赛
    int ismatch = [self.oneRun.isMatch intValue];
    if(ismatch == 0){
        [self drawRunTrack];
    }else if(ismatch == 1){
        [self drawMatchTrack];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)button_back_clicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)initUI{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.oneRun.startTime longLongValue]/1000];
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = [componets weekday];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy年M月d日 周%@ HH:mm",[CNUtil weekday2chinese:weekday]]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    self.label_date.text = strDate;
    self.label_date1.text = strDate;
    self.label_date2.text = strDate;
    self.label_date3.text = strDate;
    self.label_date4.text = strDate;
    [dateFormatter setDateFormat:@"M月d日"];
    NSString* strDate2 = [dateFormatter stringFromDate:date];
    int type = [oneRun.howToMove intValue];
    NSString* typeDes = @"";
    switch (type) {
        case 1:
        {
            typeDes = @"跑步";
            self.image_type.image = [UIImage imageNamed:@"howToMove1.png"];
            break;
        }
        case 2:
        {
            typeDes = @"步行";
            self.image_type.image = [UIImage imageNamed:@"howToMove2.png"];
            break;
        }
        case 3:
        {
            typeDes = @"自行车骑行";
            self.image_type.image = [UIImage imageNamed:@"howToMove3.png"];
            break;
        }
        default:
            break;
    }
    self.label_title.text = [NSString stringWithFormat:@"%@的%@",strDate2,typeDes];
    self.label_dis.text = [NSString stringWithFormat:@"%0.2fkm",[oneRun.distance floatValue]/1000];
    self.label_during.text = [CNUtil duringTimeStringFromSecond:[oneRun.duration intValue]/1000];
    self.label_pspeed.text = [CNUtil pspeedStringFromSecond:[oneRun.secondPerKm intValue]];
    self.label_aver_speed.text = [NSString stringWithFormat:@"+%i",[oneRun.score intValue]];
    int mood = [self.oneRun.feeling intValue];
    NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_hd.png",mood];
    self.imageview_mood.image = [UIImage imageNamed:img_name_mood];
    
    int way = [self.oneRun.runway intValue];
    NSString* img_name_way = [NSString stringWithFormat:@"way%i_hd.png",way];
    self.imageview_way.image = [UIImage imageNamed:img_name_way];
    
    if(kApp.runManager.runway == 0){//没选道路
        self.imageview_mood.frame = self.imageview_way.frame;
    }
    
//    [self testDrawOneByOne];
}
- (void)drawRunTrack{
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = [kApp.runManager.GPSList count];
    
    //画起点和终点
    CNGPSPoint* startPoint = [kApp.runManager.GPSList firstObject];
    CNGPSPoint* endPoint = [kApp.runManager.GPSList lastObject];
    CLLocationCoordinate2D wgs84Point_start = CLLocationCoordinate2DMake(startPoint.lat, startPoint.lon);
    CLLocationCoordinate2D encryptionPoint_start = [CNEncryption encrypt:wgs84Point_start];
    CLLocationCoordinate2D wgs84Point_end = CLLocationCoordinate2DMake(endPoint.lat, endPoint.lon);
    CLLocationCoordinate2D encryptionPoint_end = [CNEncryption encrypt:wgs84Point_end];
    MAPointAnnotation *annotation_start = [[MAPointAnnotation alloc] init];
    annotation_start.coordinate = CLLocationCoordinate2DMake(encryptionPoint_start.latitude, encryptionPoint_start.longitude);
    annotation_start.title = @"start";
    [self.mapView addAnnotation:annotation_start];
    
    MAPointAnnotation *annotation_end = [[MAPointAnnotation alloc] init];
    annotation_end.coordinate = CLLocationCoordinate2DMake(encryptionPoint_end.latitude, encryptionPoint_end.longitude);
    annotation_end.title = @"end";
    [self.mapView addAnnotation:annotation_end];
    
    //先画底色：
    CLLocationCoordinate2D polylineCoords_backgound[pointCount];
    CLLocationCoordinate2D polylineCoords_encryption[pointCount];
    for(i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.runManager.GPSList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        polylineCoords_backgound[i].latitude = encryptionPoint.latitude;
        polylineCoords_backgound[i].longitude = encryptionPoint.longitude;
        polylineCoords_encryption[i] = encryptionPoint;
    }
    MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords_backgound count:pointCount];
    polyline.title = @"3";
    [self.mapView addOverlay:polyline];
    
    //再画灰色：
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
    [self.mapView setRegion:region animated:YES];
    
    
    
    //画气泡
    for(i = 0;i<[kApp.runManager.dataKm count];i++){
        OneKMInfo* oneKm = [kApp.runManager.dataKm objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(oneKm.lat, oneKm.lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(encryptionPoint.latitude, encryptionPoint.longitude);
        annotation.title = [NSString stringWithFormat:@"%i_%i",oneKm.number,oneKm.during/1000];
        [self.mapView addAnnotation:annotation];
    }
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
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        static NSString *mapImageIndetifier = @"mapImageIndetifier";
        
        NSString* title = ((MAPointAnnotation*)annotation).title;
        if([title hasPrefix:@"start"]||[title hasPrefix:@"end"]){
            CNMapImageAnnotationView *annotationView = (CNMapImageAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:mapImageIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[CNMapImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:mapImageIndetifier];
                // must set to NO, so we can show the custom callout view.
//                annotationView.draggable = YES;
//                annotationView.centerOffset = CGPointMake(0,-15);
            }
            NSLog(@"title is %@",title);
            annotationView.type = title;
            return annotationView;
        }else{
            CustomAnnotationView *annotationView = (CustomAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
                // must set to NO, so we can show the custom callout view.
                annotationView.draggable = YES;
                annotationView.centerOffset = CGPointMake(0, -15);
            }
            NSLog(@"title is %@",title);
            annotationView.paraminfo = title;
            return annotationView;
        }
        
    }
    return nil;
}
- (void)testDrawOneByOne{
//    [CNAppDelegate makeTest];
    int pointCount = [kApp.oneRunPointList count];
    for(int i=0;i<pointCount-1;i++){
        CNGPSPoint* point1 = [kApp.oneRunPointList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point1 = CLLocationCoordinate2DMake(point1.lat, point1.lon);
        CLLocationCoordinate2D encryptionPoint1 = [CNEncryption encrypt:wgs84Point1];
        CNGPSPoint* point2 = [kApp.oneRunPointList objectAtIndex:i+1];
        CLLocationCoordinate2D wgs84Point2 = CLLocationCoordinate2DMake(point2.lat, point2.lon);
        CLLocationCoordinate2D encryptionPoint2 = [CNEncryption encrypt:wgs84Point2];
        CLLocationCoordinate2D polylineCoords[2];
        polylineCoords[0] = encryptionPoint1;
        polylineCoords[1] = encryptionPoint2;
        MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoords count:2];
        polyline.title = @"3";
        [self.mapView addOverlay:polyline];
//        if(i>0){
//            CNGPSPoint* point0 = [kApp.oneRunPointList objectAtIndex:i-1];
//            CLLocationCoordinate2D wgs84Point0 = CLLocationCoordinate2DMake(point0.lat, point0.lon);
//            CLLocationCoordinate2D encryptionPoint0 = [CNEncryption encrypt:wgs84Point0];
//            CLLocationCoordinate2D polylineCoords[3];
//            polylineCoords[0] = encryptionPoint0;
//            polylineCoords[1] = encryptionPoint1;
//            polylineCoords[2] = encryptionPoint2;
//            MAPolyline* polyline2 = [MAPolyline polylineWithCoordinates:polylineCoords count:3];
//            polyline2.title = @"1";
//            [self.mapView addOverlay:polyline2];
//        }
        
        MAPolyline* polyline2 = [MAPolyline polylineWithCoordinates:polylineCoords count:2];
        polyline2.title = @"1";
        [self.mapView addOverlay:polyline2];
    }
}
- (void)redrawPolyline{
    [self.mapView removeOverlay:polyline_forward];
    [self.mapView removeOverlay:polyline_back];
    [self drawRunTrack];
}
//比赛：
- (void)drawMatchTrack{
    CNGPSPoint4Match* startPoint = [kApp.match_pointList firstObject];
    CNGPSPoint4Match* endPoint = [kApp.match_pointList lastObject];
    MAPointAnnotation *annotation_start = [[MAPointAnnotation alloc] init];
    annotation_start.coordinate = CLLocationCoordinate2DMake(startPoint.lat, startPoint.lon);
    annotation_start.title = @"start";
    [self.mapView addAnnotation:annotation_start];
    
    MAPointAnnotation *annotation_end = [[MAPointAnnotation alloc] init];
    annotation_end.coordinate = CLLocationCoordinate2DMake(endPoint.lat, endPoint.lon);
    annotation_end.title = @"end";
    [self.mapView addAnnotation:annotation_end];
    
    
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
            polyline.title = @"3";
            [self.mapView addOverlay:polyline];
            n = i+1;//n为下一个起点
        }
    }
    
    
    
    n = 0;
    CNGPSPoint4Match* gpsPoint_first = [kApp.match_pointList objectAtIndex:0];
    double min_lon = gpsPoint_first.lon;
    double min_lat = gpsPoint_first.lat;
    double max_lon = gpsPoint_first.lon;
    double max_lat = gpsPoint_first.lat;
    for(i=0;i<pointCount;i++){
        CNGPSPoint4Match* gpsPoint = [kApp.match_pointList objectAtIndex:i];
        if (gpsPoint.lon < 0.01 || i == pointCount-1) {
            CLLocationCoordinate2D polylineCoord[i-n];
            for(j=0;j<i-n;j++){
                CNGPSPoint4Match* gpsPoint = [kApp.match_pointList objectAtIndex:n+j];
                polylineCoord[j].latitude = gpsPoint.lat;
                polylineCoord[j].longitude = gpsPoint.lon;
                
                if(gpsPoint.lon < min_lon){
                    min_lon = gpsPoint.lon;
                }
                if(gpsPoint.lat < min_lat){
                    min_lat = gpsPoint.lat;
                }
                if(gpsPoint.lon > max_lon){
                    max_lon = gpsPoint.lon;
                }
                if(gpsPoint.lat > max_lat){
                    max_lat = gpsPoint.lat;
                }
            }
            MAPolyline* polyline = [MAPolyline polylineWithCoordinates:polylineCoord count:i-n];
            polyline.title = @"1";
            [self.mapView addOverlay:polyline];
            n = i+1;//n为下一个起点
        }
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.005, max_lon-min_lon+0.005);
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:NO];
}
@end

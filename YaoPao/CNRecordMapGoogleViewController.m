//
//  CNRecordMapGoogleViewController.m
//  YaoPao
//
//  Created by zc on 15-1-3.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNRecordMapGoogleViewController.h"
#import "CNGPSPoint.h"
#import "CNUtil.h"
#import "CNRunManager.h"
#import "OneKMInfo.h"

@interface CNRecordMapGoogleViewController ()

@end

@implementation CNRecordMapGoogleViewController
@synthesize oneRun;
@synthesize mapView;
@synthesize polyline_back;
@synthesize polyline_forward;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    self.mapView = [GMSMapView mapWithFrame:self.view_map_container.bounds camera:nil];
    self.mapView.myLocationEnabled = YES;
    [self.view_map_container addSubview:self.mapView];
    [self.view_map_container sendSubviewToBack:self.mapView];
    [self initUI];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self drawRunTrack];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)initUI{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.oneRun.startTime longLongValue]/1000];
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = (int)[componets weekday];
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
            self.image_type.image = [UIImage imageNamed:@"runtype_run.png"];
            break;
        }
        case 2:
        {
            typeDes = @"步行";
            self.image_type.image = [UIImage imageNamed:@"runtype_walk.png"];
            break;
        }
        case 3:
        {
            typeDes = @"自行车骑行";
            self.image_type.image = [UIImage imageNamed:@"runtype_ride.png"];
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
}
- (void)drawRunTrack{
    int j = 0;
    int i = 0;
    int n = 0;
    int pointCount = (int)[kApp.runManager.GPSList count];
    
    //画起点和终点
    CNGPSPoint* startPoint = [kApp.runManager.GPSList firstObject];
    CNGPSPoint* endPoint = [kApp.runManager.GPSList lastObject];
    CLLocationCoordinate2D wgs84Point_start = CLLocationCoordinate2DMake(startPoint.lat, startPoint.lon);
    CLLocationCoordinate2D wgs84Point_end = CLLocationCoordinate2DMake(endPoint.lat, endPoint.lon);
    GMSMarker *marker_start = [GMSMarker markerWithPosition:wgs84Point_start];
    marker_start.groundAnchor = CGPointMake(0.5, 0.8);
    marker_start.icon = [UIImage imageNamed:@"map_start4google.png"];
    marker_start.map = self.mapView;
    
    GMSMarker *marker_end = [GMSMarker markerWithPosition:wgs84Point_end];
    marker_end.groundAnchor = CGPointMake(0.5, 0.8);
    marker_end.icon = [UIImage imageNamed:@"map_end4google.png"];
    marker_end.map = self.mapView;
    
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
    
    
    
    //画气泡
    for(i = 0;i<[kApp.runManager.dataKm count];i++){
        OneKMInfo* oneKm = [kApp.runManager.dataKm objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(oneKm.lat, oneKm.lon);
        GMSMarker *marker_pop = [GMSMarker markerWithPosition:wgs84Point];
        marker_pop.groundAnchor = CGPointMake(0.5, 0.8);
        marker_pop.icon = [self imageFromView:oneKm.number :oneKm.during/1000];
        marker_pop.map = self.mapView;
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIImage*)imageFromView:(int)km :(int)time{
    UIView* popview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 45)];
    UIImageView* image_back = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 45)];
    image_back.image = [UIImage imageNamed:@"map_pop.png"];
    [popview addSubview:image_back];
    UILabel* label_km = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 60, 15)];
    label_km.textAlignment = NSTextAlignmentCenter;
    label_km.font = [UIFont systemFontOfSize:12];
    label_km.text = [NSString stringWithFormat:@"第%i公里",km];
    [popview addSubview:label_km];
    
    UILabel* label_time = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 60, 15)];
    label_time.textAlignment = NSTextAlignmentCenter;
    label_time.font = [UIFont systemFontOfSize:12];
    label_time.text = [CNUtil pspeedStringFromSecond:time];
    [popview addSubview:label_time];
    return [self imageWithUIView:popview];
}
-(UIImage *)getImageFromView:(UIView *)theView
{
    //UIGraphicsBeginImageContext(theView.bounds.size);
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, YES, theView.layer.contentsScale);
    [theView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (UIImage*) imageWithUIView:(UIView*) view{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:currnetContext];
    // 从当前context中创建一个改变大小后的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return image;
}

@end

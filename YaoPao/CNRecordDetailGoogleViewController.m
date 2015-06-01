//
//  CNRecordDetailGoogleViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/3/10.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNRecordDetailGoogleViewController.h"
#import "BinaryIOManager.h"
#import "CNRunManager.h"
#import "CNCloudRecord.h"
#import "CNUtil.h"
#import "CNShareViewController.h"
#import "CNDistanceImageView.h"
#import "CNGPSPoint.h"
#import "CNRecordMapGoogleViewController.h"
#import "CNRecordMapViewController.h"

@interface CNRecordDetailGoogleViewController ()

@end

@implementation CNRecordDetailGoogleViewController
@synthesize oneRun;
@synthesize mapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_share addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    self.mapView = [GMSMapView mapWithFrame:self.view_map_container.bounds camera:nil];
    [self.view_map_container addSubview:self.mapView];
    [self.view_map_container sendSubviewToBack:self.mapView];
    self.textfield_remark.delegate = self;
    [self initUI];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //画轨迹
    BinaryIOManager* ioManager = [[BinaryIOManager alloc]init];
    [ioManager readBinary:self.oneRun.clientBinaryFilePath :[self.oneRun.gpsCount intValue] :[self.oneRun.kmCount intValue] :[self.oneRun.mileCount intValue] :[self.oneRun.minCount intValue]];
    [self drawRunTrack];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated{
    if(![self.textfield_remark.text isEqualToString:self.oneRun.remark]){
        self.oneRun.remark = self.textfield_remark.text;
        if(kApp.cloudManager.isSynServerTime){
            self.oneRun.updateTime = [NSNumber numberWithLongLong:([CNUtil getNowTime1000]+kApp.cloudManager.deltaMiliSecond)];
        }else{
            self.oneRun.updateTime = [NSNumber numberWithLongLong:0];
        }
        NSError *error = nil;
        [kApp.managedObjectContext save:&error];
    }
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}


- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)button_share_clicked:(id)sender {
    if(![self.textfield_remark.text isEqualToString:self.oneRun.remark]){
        self.oneRun.remark = self.textfield_remark.text;
    }
    self.button_share.backgroundColor = [UIColor clearColor];
    CNShareViewController* shareVC = [[CNShareViewController alloc]init];
    shareVC.dataSource = @"list";
    shareVC.oneRun = self.oneRun;
    [self.navigationController pushViewController:shareVC animated:YES];
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
    int type = [self.oneRun.howToMove intValue];
    NSString* typeDes = @"";
    switch (type) {
        case 1:
        {
            typeDes = @"跑步";
            self.imageview_type.image = [UIImage imageNamed:@"runtype_run.png"];
            break;
        }
        case 2:
        {
            typeDes = @"步行";
            self.imageview_type.image = [UIImage imageNamed:@"runtype_walk.png"];
            break;
        }
        case 3:
        {
            typeDes = @"自行车骑行";
            self.imageview_type.image = [UIImage imageNamed:@"runtype_ride.png"];
            break;
        }
        default:
            break;
    }
    self.label_title.text = [NSString stringWithFormat:@"%@的%@",strDate2,typeDes];
    //    self.label_dis.text = [NSString stringWithFormat:@"%0.2fkm",[self.oneRun.distance floatValue]/1000];
    CNDistanceImageView* div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(5, 255+IOS7OFFSIZE, 130, 32)];
    div.distance = [self.oneRun.distance floatValue]/1000;
    div.color = @"red";
    [div fitToSizeLeft];
    [self.view addSubview:div];
    UIImageView* image_km = [[UIImageView alloc]initWithFrame:CGRectMake(div.frame.origin.x+div.frame.size.width, 255+IOS7OFFSIZE,26, 32)];
    image_km.image = [UIImage imageNamed:@"redkm.png"];
    [self.view addSubview:image_km];
    
    self.label_during.text = [CNUtil duringTimeStringFromSecond:[self.oneRun.duration intValue]/1000];
    self.label_pspeed.text = [CNUtil pspeedStringFromSecond:[self.oneRun.secondPerKm intValue]];
    self.label_aver_speed.text = [NSString stringWithFormat:@"+%i",[self.oneRun.score intValue]];
    self.label_feel.text = self.oneRun.remark;
    self.textfield_remark.text = self.oneRun.remark;
    int mood = [self.oneRun.feeling intValue];
    NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_h.png",mood];
    self.image_mood.image = [UIImage imageNamed:img_name_mood];
    
    int way = [self.oneRun.runway intValue];
    NSString* img_name_way = [NSString stringWithFormat:@"way%i_h.png",way];
    self.image_way.image = [UIImage imageNamed:img_name_way];
    //判断是否有图片
    if(![oneRun.clientImagePaths isEqualToString:@""]){
        //去沙盒读取图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:oneRun.clientImagePaths];
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (blHave) {//图片存在
            [self.scrollview setContentSize:CGSizeMake(640, 150)];
            self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
            self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
            self.scrollview.pagingEnabled=YES;
            UIImageView* photo = [[UIImageView alloc]initWithFrame:CGRectMake(320, 0, 320, 250)];
            [self.scrollview addSubview:photo];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            photo.image = [[UIImage alloc] initWithData:data];
        }
    }
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
    //    for(i = 0;i<[kApp.runManager.dataKm count];i++){
    //        OneKMInfo* oneKm = [kApp.runManager.dataKm objectAtIndex:i];
    //        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(oneKm.lat, oneKm.lon);
    //        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
    //        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    //        annotation.coordinate = CLLocationCoordinate2DMake(encryptionPoint.latitude, encryptionPoint.longitude);
    //        annotation.title = [NSString stringWithFormat:@"%i_%i",oneKm.number,oneKm.during/1000];
    //        [self.mapView addAnnotation:annotation];
    //    }
}
- (IBAction)button_gotoMap_clicked:(id)sender {
    CNRecordMapGoogleViewController* recordMapVC = [[CNRecordMapGoogleViewController alloc]init];
    recordMapVC.oneRun = self.oneRun;
    [self.navigationController pushViewController:recordMapVC animated:YES];
    
}
#pragma mark- textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self resetViewFrame];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"编辑结束");
    [textField resignFirstResponder];
    [self resetViewFrame];
}
- (void)keyboardWillShow:(NSNotification *)noti
{
    //键盘输入的界面调整
    //键盘的高度
    float height = 216.0;
    CGRect frame = self.view.frame;
    frame.size = CGSizeMake(frame.size.width, frame.size.height - height);
    [UIView beginAnimations:@"Curl" context:nil];//动画开始
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:frame];
    [UIView commitAnimations];
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint point = [textField.superview convertPoint:textField.frame.origin toView:nil];
    int offset = point.y + 80 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}
- (void)resetViewFrame{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
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

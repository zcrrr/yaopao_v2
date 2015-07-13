//
//  CNRecordDetailViewController.m
//  YaoPao
//
//  Created by zc on 14-8-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRecordDetailViewController.h"
#import "CNUtil.h"
#import "SBJson.h"
#import "CNGPSPoint.h"
#import "CNShareViewController.h"
#import "CNRecordMapViewController.h"
#import "CNEncryption.h"
#import "CNDistanceImageView.h"
#import "CNMapImageAnnotationView.h"
#import "CNGPSPoint4Match.h"
#import "CNRecordMapGoogleViewController.h"
#import "BinaryIOManager.h"
#import "CNRunManager.h"
#import "CNCloudRecord.h"
#import "CNCustomButton.h"
#import "ColorValue.h"
#import "CNImageEditerViewController.h"

@interface CNRecordDetailViewController ()

@end

@implementation CNRecordDetailViewController
@synthesize oneRun;
@synthesize mapView;
@synthesize currentpage;
extern NSMutableArray* imageArray;

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
    [CNUtil appendUserOperation:@"进入运动记录二级页面"];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_back fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    [self.button_share fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    [self.view_map_container addSubview:self.mapView];
    [self.view_map_container sendSubviewToBack:self.mapView];
    self.textfield_remark.delegate = self;
    [self initUI];
    if(!iPhone5){//4、4s
        self.button_water.frame  = CGRectMake(14, 431, 293, 42);
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView==self.scrollview){
        CGPoint offset = scrollView.contentOffset;
        self.currentpage = offset.x/320; //计算当前的页码
        [self howControllerDisplay];
    }
}
- (void)howControllerDisplay{
    if([imageArray count] == 0){
        self.button_left.hidden = YES;
        self.button_right.hidden = YES;
        return;
    }
    if(self.currentpage == 0){//第一页
        self.button_left.hidden = YES;
        self.button_right.hidden = NO;
    }else if(self.currentpage == [imageArray count]){//最后一页
        self.button_left.hidden = NO;
        self.button_right.hidden = YES;
    }else{//中间页
        self.button_left.hidden = NO;
        self.button_right.hidden = NO;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //画轨迹
    //区分是否是比赛
    int ismatch = [self.oneRun.isMatch intValue];
    if(ismatch == 0){
        //加载轨迹
        BinaryIOManager* ioManager = [[BinaryIOManager alloc]init];
        [ioManager readBinary:oneRun.clientBinaryFilePath :[oneRun.gpsCount intValue] :[oneRun.kmCount intValue] :[oneRun.mileCount intValue] :[oneRun.minCount intValue]];
        [self drawRunTrack];
    }else if(ismatch == 1){
        kApp.match_pointList = [[NSMutableArray alloc]init];
        NSArray* pointDicList = [self.oneRun.gpsString componentsSeparatedByString:@","];
        for(int i=0;i<[pointDicList count];i++){
            CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
            NSArray* lonlat = [[pointDicList objectAtIndex:i]componentsSeparatedByString:@" "];
            point.lon = [[lonlat objectAtIndex:0]doubleValue];
            point.lat = [[lonlat objectAtIndex:1]doubleValue];
            [kApp.match_pointList addObject:point];
        }
        [self drawMatchTrack];
    }
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_back_clicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)button_share_clicked:(id)sender {
    [CNUtil appendUserOperation:@"点击分享按钮，去分享界面"];
    if(![self.textfield_remark.text isEqualToString:self.oneRun.remark]){
        self.oneRun.remark = self.textfield_remark.text;
    }
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
            self.imageview_type.image = [UIImage imageNamed:@"howToMove1.png"];
            break;
        }
        case 2:
        {
            typeDes = @"步行";
            self.imageview_type.image = [UIImage imageNamed:@"howToMove2.png"];
            break;
        }
        case 3:
        {
            typeDes = @"自行车骑行";
            self.imageview_type.image = [UIImage imageNamed:@"howToMove3.png"];
            break;
        }
        default:
            break;
    }
    self.label_title.text = [NSString stringWithFormat:@"%@的%@",strDate2,typeDes];
    self.label_during.text = [CNUtil duringTimeStringFromSecond:[self.oneRun.duration intValue]/1000];
    self.label_pspeed.text = [CNUtil pspeedStringFromSecond:[self.oneRun.secondPerKm intValue]];
    self.label_aver_speed.text = [NSString stringWithFormat:@"+%i",[self.oneRun.score intValue]];
    self.textfield_remark.text = self.oneRun.remark;
    int mood = [self.oneRun.feeling intValue];
    NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_hd.png",mood];
    self.image_mood.image = [UIImage imageNamed:img_name_mood];
    
    int way = [self.oneRun.runway intValue];
    NSString* img_name_way = [NSString stringWithFormat:@"way%i_hd.png",way];
    self.image_way.image = [UIImage imageNamed:img_name_way];
    
    if(way == 0){//没选道路
        self.image_mood.frame = self.image_way.frame;
    }
    //判断是否有图片
    imageArray = [[NSMutableArray alloc]init];
    if(![oneRun.clientImagePaths isEqualToString:@""]){
        NSArray* imagePaths = [oneRun.clientImagePaths componentsSeparatedByString:@"|"];
        //去沙盒读取图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        for (int i=0;i<[imagePaths count];i++){
            NSString* onePath = [imagePaths objectAtIndex:i];
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:onePath];
            BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (blHave) {//图片存在
                [self.scrollview setContentSize:CGSizeMake(320+(i+1)*320, 320)];
                self.button_details.frame = CGRectMake(0, 0, 320+(i+1)*320, 320);
                self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
                self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
                self.scrollview.pagingEnabled=YES;
                self.scrollview.delegate = self;
                UIImageView* photo = [[UIImageView alloc]initWithFrame:CGRectMake(320+i*320, 0, 320, 320)];
                photo.contentMode = UIViewContentModeScaleAspectFill;
                [self.scrollview addSubview:photo];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                photo.image = [[UIImage alloc] initWithData:data];
                if(photo.image != nil){
                    [imageArray addObject:photo.image];
                }
            }
        }
    }
    [self howControllerDisplay];
    self.label_dis_map1.text = [NSString stringWithFormat:@"%0.2f",[oneRun.distance doubleValue]/1000.0];
    self.label_date_map1.text = [CNUtil getTimeFromTimestamp_ymd:[oneRun.rid longLongValue]/1000];
    self.label_time_map1.text = [CNUtil getTimeFromTimestamp_ms:[oneRun.rid longLongValue]/1000];
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
        }
    }
    return nil;
}
- (IBAction)button_gotoMap_clicked:(id)sender {
    if(self.currentpage == 0){
        CNRecordMapViewController* recordMapVC = [[CNRecordMapViewController alloc]init];
        recordMapVC.oneRun = self.oneRun;
        [self.navigationController pushViewController:recordMapVC animated:YES];
    }else{
        CNImageEditerViewController* ieVC = [[CNImageEditerViewController alloc]init];
        ieVC.oneRun = self.oneRun;
        [self.navigationController pushViewController:ieVC animated:YES];
    }
}
- (void)editImageDidSuccess{
    //删除所有图片
    for (UIView *subview in [self.scrollview subviews]) {
        if([subview isKindOfClass:[UIImageView class]]){
            [subview removeFromSuperview];
        }
    }
    NSLog(@"client imagepath = %@",self.oneRun.clientImagePaths);
    //判断是否有图片
    imageArray = [[NSMutableArray alloc]init];
    if(![oneRun.clientImagePaths isEqualToString:@""]){
        NSArray* imagePaths = [oneRun.clientImagePaths componentsSeparatedByString:@"|"];
        //去沙盒读取图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        for (int i=0;i<[imagePaths count];i++){
            NSString* onePath = [imagePaths objectAtIndex:i];
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:onePath];
            BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (blHave) {//图片存在
                [self.scrollview setContentSize:CGSizeMake(320+(i+1)*320, 320)];
                self.button_details.frame = CGRectMake(0, 0, 320+(i+1)*320, 320);
                self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
                self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
                self.scrollview.pagingEnabled=YES;
                self.scrollview.delegate = self;
                UIImageView* photo = [[UIImageView alloc]initWithFrame:CGRectMake(320+i*320, 0, 320, 320)];
                photo.contentMode = UIViewContentModeScaleAspectFill;
                [self.scrollview addSubview:photo];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                photo.image = [[UIImage alloc] initWithData:data];
                if(photo.image != nil){
                    [imageArray addObject:photo.image];
                }
            }
        }
    }else{
        [self.scrollview setContentSize:CGSizeMake(320, 320)];
    }
    self.currentpage = 0;
    [self.scrollview setContentOffset:CGPointMake(0,0) animated:YES];
    [self howControllerDisplay];
    
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
    int pointCount = (int)[kApp.match_pointList count];
    
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
#pragma mark- textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self resetViewFrame];
    return YES;
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
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"编辑结束");
    [textField resignFirstResponder];
    [self resetViewFrame];
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
- (IBAction)button_left_clicked:(id)sender {
    [self.scrollview setContentOffset:CGPointMake(self.currentpage*320-320, 0) animated:YES];
    self.currentpage -- ;
    [self howControllerDisplay];
}

- (IBAction)button_right_clicked:(id)sender {
    [self.scrollview setContentOffset:CGPointMake(self.currentpage*320+320, 0) animated:YES];
    self.currentpage ++ ;
    [self howControllerDisplay];
}

- (IBAction)button_imageEdit_clicked:(id)sender {
    [CNUtil appendUserOperation:@"点击要跑水印相机"];
    CNImageEditerViewController* ieVC = [[CNImageEditerViewController alloc]init];
    ieVC.oneRun = self.oneRun;
    ieVC.delegate_editImage = self;
    [self.navigationController pushViewController:ieVC animated:YES];
}
@end

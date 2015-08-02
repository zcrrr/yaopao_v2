//
//  CNShareNewViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/7/31.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNShareNewViewController.h"
#import "CNCustomButton.h"
#import "ColorValue.h"
#import "RunClass.h"
#import "CNUtil.h"
#import "CNRunManager.h"
#import "CNGPSPoint.h"
#import "CNEncryption.h"
#import "OnlyTrackView4share.h"
#import "CNMapImageAnnotationView.h"
#import "BinaryIOManager.h"
#import "CNRecordMapViewController.h"
#import "CNImageEditerViewController.h"
#import "Toast+UIView.h"
#import <ShareSDK/ShareSDK.h>
#import "CNCloudRecord.h"

@interface CNShareNewViewController ()

@end

@implementation CNShareNewViewController
@synthesize mapView;
@synthesize oneRun;
@synthesize currentpage;
@synthesize shareText;
@synthesize from;
extern NSMutableArray* imageArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    if([self.from isEqualToString:@"record"]){
        [self.button_jump_or_back setTitle:@"返回" forState:UIControlStateNormal];
    }else{
        [self.button_jump_or_back setTitle:@"跳过" forState:UIControlStateNormal];
    }
    // Do any additional setup after loading the view from its nib.
    [self.button_jump_or_back fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view_mapContainer.bounds.size.width, self.view_mapContainer.bounds.size.height)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    [self.view_mapContainer addSubview:self.mapView];
    [self.view_mapContainer sendSubviewToBack:self.mapView];
    //照片
    self.scrollview.delegate = self;
    self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
    self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
    self.scrollview.pagingEnabled=YES;
    self.scrollview.contentSize = CGSizeMake(640, self.scrollview.bounds.size.height);
    //判断是否有图片
    imageArray = [[NSMutableArray alloc]init];
    if(![oneRun.clientImagePaths isEqualToString:@""]){
        NSArray* imagePaths = [oneRun.clientImagePaths componentsSeparatedByString:@"|"];
        [self.scrollview setContentSize:CGSizeMake(([imagePaths count]+2)*320, 320)];
        self.button_scrollview.frame = CGRectMake(0, 0, ([imagePaths count]+2)*320, 320);
        //去沙盒读取图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        for (int i=0;i<[imagePaths count];i++){
            NSString* onePath = [imagePaths objectAtIndex:i];
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:onePath];
            BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (blHave) {//图片存在
                UIImageView* photo = [[UIImageView alloc]initWithFrame:CGRectMake(320+(i+1)*320, 0, 320, 320)];
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
    self.label_page.text = [NSString stringWithFormat:@"%i/%i",1,(int)[imageArray count]+2];
    [self howControllerDisplay];
    
    int type = [self.oneRun.howToMove intValue];
    NSString* typeDes = @"";
    switch (type) {
        case 1:
        {
            typeDes = @"跑";
            break;
        }
        case 2:
        {
            typeDes = @"步行";
            break;
        }
        default:
            break;
    }
    self.shareText = [NSString stringWithFormat:@"我刚刚%@了%0.2f公里",typeDes, [oneRun.distance doubleValue]/1000.0];
    self.textfield_remark.text = [oneRun.remark isEqualToString:@""]?self.shareText:oneRun.remark;
    self.label_during.text = [CNUtil duringTimeStringFromSecond:[oneRun.duration intValue]/1000];
    self.label_pace.text = [CNUtil pspeedStringFromSecond:[oneRun.secondPerKm intValue]];
    self.label_score.text = [NSString stringWithFormat:@"+%i",[oneRun.score intValue]];
    int mood = [oneRun.feeling intValue];
    NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_hd.png",mood];
    self.imageview_feel.image = [UIImage imageNamed:img_name_mood];
    
    int way = [oneRun.runway intValue];
    NSString* img_name_way = [NSString stringWithFormat:@"way%i_hd.png",way];
    self.imageview_way.image = [UIImage imageNamed:img_name_way];
    if(way == 0){//没选道路
        self.imageview_feel.frame = self.imageview_feel.frame;
    }
    
    self.label_dis1.text = [NSString stringWithFormat:@"%0.2f",[oneRun.distance doubleValue]/1000.0];
    self.label_date1.text = [CNUtil getTimeFromTimestamp_ymd:[oneRun.rid longLongValue]/1000];
    self.label_time1.text = [CNUtil getTimeFromTimestamp_ms:[oneRun.rid longLongValue]/1000];
    self.label_dis2.text = [NSString stringWithFormat:@"%0.2f",[oneRun.distance doubleValue]/1000.0];
    self.label_date2.text = [CNUtil getTimeFromTimestamp_ymd:[oneRun.rid longLongValue]/1000];
    self.label_time2.text = [CNUtil getTimeFromTimestamp_ms:[oneRun.rid longLongValue]/1000];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView==self.scrollview){
        CGPoint offset = scrollView.contentOffset;
        self.currentpage = offset.x/320; //计算当前的页码
        self.label_page.text = [NSString stringWithFormat:@"%i/%i",self.currentpage+1,(int)[imageArray count]+2];
        [self howControllerDisplay];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //加载轨迹
    BinaryIOManager* ioManager = [[BinaryIOManager alloc]init];
    [ioManager readBinary:self.oneRun.clientBinaryFilePath :[self.oneRun.gpsCount intValue] :[self.oneRun.kmCount intValue] :[self.oneRun.mileCount intValue] :[self.oneRun.minCount intValue]];
    [self drawRunTrack];
    //画轨迹
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
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.001, max_lon-min_lon+0.001);
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:NO];
    
    //水印
    NSMutableArray* trackpoints = [[NSMutableArray alloc]init];
    float start_x = 0;
    float start_y = 0;
    float end_x = 0;
    float end_y = 0;
    for(i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.runManager.GPSList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        //计算经纬度转屏幕坐标后的坐标
        CGPoint point = [self.mapView convertCoordinate:encryptionPoint toPointToView:self.view_mapContainer];
        NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",point.x],@"x",[NSString stringWithFormat:@"%f",point.y],@"y",[NSString stringWithFormat:@"%i",gpsPoint.status],@"status",nil];
        [trackpoints addObject:dic];
        if(i == 0){//起点
            start_x = point.x;
            start_y = point.y;
        }else if(i == pointCount-1){
            end_x = point.x;
            end_y = point.y;
        }
    }
    
    self.view_onlytrack.pointArray = trackpoints;
    [self.view_onlytrack setNeedsDisplay];
    UIImageView* imageview_start = [[UIImageView alloc]initWithFrame:CGRectMake(start_x-10, start_y-10, 20, 20)];
    imageview_start.image = [UIImage imageNamed:@"map_start.png"];
    [self.view_onlytrack addSubview:imageview_start];
    UIImageView* imageview_end = [[UIImageView alloc]initWithFrame:CGRectMake(end_x-10, end_y-10, 20, 20)];
    imageview_end.image = [UIImage imageNamed:@"map_end.png"];
    [self.view_onlytrack addSubview:imageview_end];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            if([self.from isEqualToString:@"record"]){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
                [self performSelector:@selector(gotoRecordPage) withObject:nil afterDelay:0.5];
            }
            break;
        }
        case 1:
        {
            [self.scrollview setContentOffset:CGPointMake(self.currentpage*320-320, 0) animated:YES];
            self.currentpage -- ;
            [self howControllerDisplay];
            break;
        }
        case 2:
        {
            [self.scrollview setContentOffset:CGPointMake(self.currentpage*320+320, 0) animated:YES];
            self.currentpage ++ ;
            [self howControllerDisplay];
            break;
        }
        case 3:
        {
            NSLog(@"分享");
            [kApp.window makeToast:@"请稍后"];
            [self sharetest];
            break;
        }
        case 4:
        {
            NSLog(@"水印相机");
            CNImageEditerViewController* ieVC = [[CNImageEditerViewController alloc]init];
            ieVC.oneRun = self.oneRun;
            ieVC.delegate_editImage = self;
            [self.navigationController pushViewController:ieVC animated:YES];
            break;
        }
        case 5:
        {
            if(self.currentpage <= 1){
                CNRecordMapViewController* recordMapVC = [[CNRecordMapViewController alloc]init];
                recordMapVC.oneRun = self.oneRun;
                [self.navigationController pushViewController:recordMapVC animated:YES];
            }else{
                CNImageEditerViewController* ieVC = [[CNImageEditerViewController alloc]init];
                ieVC.oneRun = self.oneRun;
                ieVC.delegate_editImage = self;
                [self.navigationController pushViewController:ieVC animated:YES];
            }
            break;

        }
        default:
            break;
    }
}
- (void)sharetest{
    id<ISSContent> publishContent = [ShareSDK content:shareText
                                       defaultContent:shareText
                                                image:[ShareSDK pngImageWithImage:[self getWeiboImage]]
                                                title:@"要跑"
                                                  url:@"http://image.yaopao.net/html/redirect.html"
                                          description:shareText
                                            mediaType:SSPublishContentMediaTypeImage];
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                    [kApp.window makeToast:@"分享成功"];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}
- (UIImage *)getWeiboImage{
    UIImage* image_background = [self screenshot:self.view_share];
    
    if(self.currentpage != 0){//不是第一页
        return image_background;
    }
    UIImage *image_map = [self.mapView takeSnapshotInRect:self.view_mapContainer.frame];
    UIImage* image_logo = [UIImage imageNamed:@"yaopao_cn_logo_black.png"];
    UIImage* image_water = [self screenshot:self.view_water];
    UIGraphicsBeginImageContextWithOptions(image_background.size,NO,0.0);
    
    //背景
    [image_background drawInRect:CGRectMake(0, 0, image_background.size.width, image_background.size.height)];
    
    //地图
    [image_map drawInRect:CGRectMake(0, self.scrollview.frame.origin.y, image_map.size.width, image_map.size.height)];
    [image_logo drawInRect:CGRectMake(141, 50+5, 38, 17)];
    [image_water drawInRect:CGRectMake(15, 50+235, image_water.size.width, image_water.size.height)];
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //保存到本地看看图片分辨率
    //    [CNUtil saveImageToIphone4Test:@"resultImage" :resultImage];
    return resultImage;
}
- (UIImage*)screenshot:(UIView*)view{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)howControllerDisplay{
    if(self.currentpage == 0){//第一页
        self.button_left.hidden = YES;
        self.button_right.hidden = NO;
    }else if(self.currentpage == [imageArray count]+1){//最后一页
        self.button_left.hidden = NO;
        self.button_right.hidden = YES;
    }else{//中间页
        self.button_left.hidden = NO;
        self.button_right.hidden = NO;
    }
    self.label_page.text = [NSString stringWithFormat:@"%i/%i",self.currentpage+1,(int)[imageArray count]+2];
}
- (void)gotoRecordPage{
    [kApp showTab:1];
    NSString* NOTIFICATION_REFRESH = @"REFRESH";
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH object:nil];
}
- (void)editImageDidSuccess{
    //删除所有图片
    for (UIView *subview in [self.scrollview subviews]) {
        if([subview isKindOfClass:[UIImageView class]]&&subview.frame.origin.x > 500){
            [subview removeFromSuperview];
        }
    }
    NSLog(@"client imagepath = %@",self.oneRun.clientImagePaths);
    //判断是否有图片
    imageArray = [[NSMutableArray alloc]init];
    if(![oneRun.clientImagePaths isEqualToString:@""]){
        NSArray* imagePaths = [oneRun.clientImagePaths componentsSeparatedByString:@"|"];
        [self.scrollview setContentSize:CGSizeMake(([imagePaths count]+2)*320, 320)];
        self.button_scrollview.frame = CGRectMake(0, 0, ([imagePaths count]+2)*320, 320);
        //去沙盒读取图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
       
        for (int i=0;i<[imagePaths count];i++){
            NSString* onePath = [imagePaths objectAtIndex:i];
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:onePath];
            BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (blHave) {//图片存在
                UIImageView* photo = [[UIImageView alloc]initWithFrame:CGRectMake(640+i*320, 0, 320, 320)];
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
        [self.scrollview setContentSize:CGSizeMake(640, 320)];
    }
    self.currentpage = 0;
    [self.scrollview setContentOffset:CGPointMake(0,0) animated:YES];
    [self howControllerDisplay];
}
@end

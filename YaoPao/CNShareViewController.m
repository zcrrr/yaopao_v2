//
//  CNShareViewController.m
//  YaoPao
//
//  Created by zc on 14-8-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNShareViewController.h"
#import "CNGPSPoint.h"
#import "CNUtil.h"
#import "CNEncryption.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImage+Rescale.h"
#import "CNRunManager.h"
#import "CNMapImageAnnotationView.h"
#import "CNCustomButton.h"
#import "ColorValue.h"
#import "OnlyTrackView4share.h"

@interface CNShareViewController ()

@end

@implementation CNShareViewController
@synthesize mapView;
@synthesize oneRun;
@synthesize currentpage;
@synthesize shareText;
extern NSMutableArray* imageArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)changeLineOne:(UIView*)line{
    CGRect frame_new = line.frame;
    frame_new.size = CGSizeMake(frame_new.size.width, 0.5);
    line.frame = frame_new;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(!iPhone5){//4、4s
        self.view_map_container.frame = CGRectMake(0, 0, 320, 260);
        self.view_onlytrack.frame = CGRectMake(320, 0, 320, 260);
        self.scrollview.frame = CGRectMake(0, 0, 320, 260);
        self.view_sharePart2.frame = CGRectMake(0, 38, 320, 302);
        
        self.view_shareview.frame = CGRectMake(0, 55, 320, 340);
//        self.imageview_page.frame = CGRectMake(134, 306, 51, 17);
//        self.label_whichpage.frame  = CGRectMake(134, 306, 51, 17);
    }
    [self.button_jump fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view_map_container.bounds.size.width, self.view_map_container.bounds.size.height)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    [self.view_map_container addSubview:self.mapView];
    [self.view_map_container sendSubviewToBack:self.mapView];
    //照片
    self.scrollview.delegate = self;
    self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
    self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
    self.scrollview.pagingEnabled=YES;
    self.scrollview.contentSize = CGSizeMake((320*([imageArray count]+2)), self.scrollview.bounds.size.height);
    for (int i = 0; i < [imageArray count] ; i++){
        UIImageView* imageview = [[UIImageView alloc]initWithFrame:CGRectMake((i+2)*320, 0, 320, self.scrollview.bounds.size.height)];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.image = (UIImage*)[imageArray objectAtIndex:i];
        [self.scrollview addSubview:imageview];
    }
    self.label_whichpage.text = [NSString stringWithFormat:@"%i/%i",1,(int)[imageArray count]+2];
    if([self.dataSource isEqualToString:@"this"]){
        [self.button_jump setTitle:@"跳过" forState:UIControlStateNormal];
        int type = kApp.runManager.howToMove;
        NSString* typeDes = @"";
        switch (type) {
            case 1:
            {
                typeDes = @"跑";
                self.imageview_type.image = [UIImage imageNamed:@"howToMove1.png"];
                self.imageview_type2.image = [UIImage imageNamed:@"howToMove1.png"];
                break;
            }
            case 2:
            {
                typeDes = @"步行";
                self.imageview_type.image = [UIImage imageNamed:@"howToMove2.png"];
                self.imageview_type2.image = [UIImage imageNamed:@"howToMove2.png"];
                break;
            }
            default:
                break;
        }
        self.shareText = [NSString stringWithFormat:@"我刚刚%@了%0.2f公里",typeDes,kApp.runManager.distance/1000.0];
        self.label_feel.text = [kApp.runManager.remark isEqualToString:@""]?self.shareText:kApp.runManager.remark;
        self.label_time.text = [CNUtil duringTimeStringFromSecond:[kApp.runManager during]/1000];
        self.label_pspeed.text = [CNUtil pspeedStringFromSecond:kApp.runManager.secondPerKm];
        self.label_score.text = [NSString stringWithFormat:@"+%i",kApp.runManager.score];
        int mood = kApp.runManager.feeling;
        NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_hd.png",mood];
        self.image_mood.image = [UIImage imageNamed:img_name_mood];
        self.imageview_mood2.image = [UIImage imageNamed:img_name_mood];
        
        int way = kApp.runManager.runway;
        NSString* img_name_way = [NSString stringWithFormat:@"way%i_hd.png",way];
        self.image_way.image = [UIImage imageNamed:img_name_way];
        self.imageview_way2.image = [UIImage imageNamed:img_name_way];
        if(kApp.runManager.runway == 0){//没选道路
            self.image_mood.frame = self.image_way.frame;
            self.imageview_mood2.frame = self.imageview_way2.frame;
        }
        
        [self.button_jump setTitle:@"跳过" forState:UIControlStateNormal];
        self.label_dis_map1.text = [NSString stringWithFormat:@"%0.1f",kApp.runManager.distance/1000.0];
        self.label_date_map1.text = [CNUtil getTimeFromTimestamp_ymd:[CNUtil getNowTime]];
        self.label_time_map1.text = [CNUtil getTimeFromTimestamp_ms:[CNUtil getNowTime]];
        self.label_dis_map2.text = [NSString stringWithFormat:@"%0.1f",kApp.runManager.distance/1000.0];
        self.label_date_map2.text = [CNUtil getTimeFromTimestamp_ymd:[CNUtil getNowTime]];
        self.label_time_map2.text = [CNUtil getTimeFromTimestamp_ms:[CNUtil getNowTime]];
    }else{
        [self.button_jump setTitle:@"返回" forState:UIControlStateNormal];
        int type = [self.oneRun.howToMove intValue];
        NSString* typeDes = @"";
        switch (type) {
            case 1:
            {
                typeDes = @"跑";
                self.imageview_type.image = [UIImage imageNamed:@"howToMove1.png"];
                self.imageview_type2.image = [UIImage imageNamed:@"howToMove1.png"];
                break;
            }
            case 2:
            {
                typeDes = @"步行";
                self.imageview_type.image = [UIImage imageNamed:@"howToMove2.png"];
                self.imageview_type2.image = [UIImage imageNamed:@"howToMove2.png"];
                break;
            }
            case 3:
            {
                typeDes = @"自行车骑行";
                self.imageview_type.image = [UIImage imageNamed:@"runtype_ride.png"];
                self.imageview_type2.image = [UIImage imageNamed:@"runtype_ride.png"];
                break;
            }
            default:
                break;
        }
        self.shareText = [NSString stringWithFormat:@"我刚刚%@了%0.2f公里",typeDes, [oneRun.distance doubleValue]/1000.0];
        self.label_feel.text = [oneRun.remark isEqualToString:@""]?self.shareText:oneRun.remark;
        self.label_time.text = [CNUtil duringTimeStringFromSecond:[oneRun.duration intValue]/1000];
        self.label_pspeed.text = [CNUtil pspeedStringFromSecond:[oneRun.secondPerKm intValue]];
        self.label_score.text = [NSString stringWithFormat:@"+%i",[oneRun.score intValue]];
        int mood = [oneRun.feeling intValue];
        NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_hd.png",mood];
        self.image_mood.image = [UIImage imageNamed:img_name_mood];
        self.imageview_mood2.image = [UIImage imageNamed:img_name_mood];
        
        int way = [oneRun.runway intValue];
        NSString* img_name_way = [NSString stringWithFormat:@"way%i_hd.png",way];
        self.image_way.image = [UIImage imageNamed:img_name_way];
        self.imageview_way2.image = [UIImage imageNamed:img_name_way];
        
        if(way == 0){//没选道路
            self.image_mood.frame = self.image_way.frame;
            self.imageview_mood2.frame = self.imageview_way2.frame;
        }
        
        
        self.label_dis_map1.text = [NSString stringWithFormat:@"%0.1f",[oneRun.distance doubleValue]/1000.0];
        self.label_date_map1.text = [CNUtil getTimeFromTimestamp_ymd:[oneRun.rid longLongValue]/1000];
        self.label_time_map1.text = [CNUtil getTimeFromTimestamp_ms:[oneRun.rid longLongValue]/1000];
        
        self.label_dis_map2.text = [NSString stringWithFormat:@"%0.1f",[oneRun.distance doubleValue]/1000.0];
        self.label_date_map2.text = [CNUtil getTimeFromTimestamp_ymd:[oneRun.rid longLongValue]/1000];
        self.label_time_map2.text = [CNUtil getTimeFromTimestamp_ms:[oneRun.rid longLongValue]/1000];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView==self.scrollview){
        CGPoint offset = scrollView.contentOffset;
        self.currentpage = offset.x/320; //计算当前的页码
        self.label_whichpage.text = [NSString stringWithFormat:@"%i/%i",self.currentpage+1,(int)[imageArray count]+2];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //画轨迹
    [self drawRunTrack];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)button_jump_clicked:(id)sender {
    if([self.dataSource isEqualToString:@"this"]){
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self performSelector:@selector(gotoRecordPage) withObject:nil afterDelay:0.5];
        
        NSString* NOTIFICATION_REFRESH = @"REFRESH";
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH object:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)gotoRecordPage{
    [kApp showTab:1];
}
- (IBAction)button_share_clicked:(id)sender {
    NSLog(@"share");
    [self sharetest];
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
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.005, max_lon-min_lon+0.01);
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
        CGPoint point = [self.mapView convertCoordinate:encryptionPoint toPointToView:self.view_map_container];
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
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}
- (UIImage *)getWeiboImage{
    UIImage* image_background = [self snapshot2:self.view_shareview];
    if(self.currentpage != 0){//不是第一页
        return image_background;
    }
    UIImage *image_map = [self.mapView takeSnapshotInRect:self.view_map_container.frame];
    UIImage* image_type = self.imageview_type.image;
    UIImage* image_logo = [UIImage imageNamed:@"yaopao_cn_logo_black.png"];
    UIImage* image_mood2share = self.image_mood.image;
    UIImage* image_way2share = self.image_way.image;
    UIImage* image_water = [self snapshot2:self.view_water];
    UIGraphicsBeginImageContext(image_background.size);
    
    //背景
    [image_background drawInRect:CGRectMake(0, 0, image_background.size.width, image_background.size.height)];
    //地图
    [image_map drawInRect:CGRectMake(0, self.view_sharePart2.frame.origin.y, image_map.size.width, image_map.size.height)];
    [image_type drawInRect:CGRectMake(0, self.view_sharePart2.frame.origin.y+5, self.imageview_type.frame.size.width, self.imageview_type.frame.size.height)];
    [image_mood2share drawInRect:CGRectMake(self.image_mood.frame.origin.x, self.view_sharePart2.frame.origin.y+5, self.image_mood.frame.size.width, self.image_mood.frame.size.height)];
    [image_way2share drawInRect:CGRectMake(self.image_way.frame.origin.x, self.view_sharePart2.frame.origin.y+5, self.image_way.frame.size.width, self.image_way.frame.size.height)];
    [image_logo drawInRect:CGRectMake(141, self.view_sharePart2.frame.origin.y+5, 38, 17)];
    [image_water drawInRect:CGRectMake(15, self.view_sharePart2.frame.origin.y+235, 105, 57)];
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
- (UIImage*)snapshot2:(UIView*)view{
    UIGraphicsBeginImageContext(view.bounds.size); //currentView 当前的view
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}
@end

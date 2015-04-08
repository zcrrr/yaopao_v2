//
//  WaterMarkViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/3/26.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "WaterMarkViewController.h"
#import "Toast+UIView.h"
#import "CNRunManager.h"
#import "CNGPSPoint.h"
#import "CNEncryption.h"
#import "OnlyTrackView.h"
#import "CNUtil.h"

@interface WaterMarkViewController ()

@end

@implementation WaterMarkViewController
@synthesize whiteOrBlack;
@synthesize currentPage;
@synthesize mapView;
@synthesize image_datasource;
@synthesize delegate_addWater;
extern NSString* weatherCode;
extern NSString* dayOrNight;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageview.image = self.image_datasource;
    // Do any additional setup after loading the view from its nib.
    self.scrollview.delegate = self;
    self.scrollview.contentSize = CGSizeMake(320*4, 320);
    self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
    self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
    self.scrollview.pagingEnabled=YES;
    
    self.pageControl.numberOfPages=4; //设置页数为3
    self.pageControl.currentPage=0; //初始页码为 0
    self.pageControl.userInteractionEnabled = NO;//pagecontroller不响应点击操作
    self.pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    
    [self initData];
    [self trackWater];
    if(!iPhone5){//4、4s
        self.view_savaImage.frame = CGRectMake(0, 55, 320, 320);
        self.view_bottom.frame = CGRectMake(0, 390, 320, 15);
    }
    
}
- (void)initData{
    self.label_water1_km.text = [NSString stringWithFormat:@"%0.2fKM",kApp.runManager.distance/1000.0];
    self.label_water2_km.text = [NSString stringWithFormat:@"%0.2fKM",kApp.runManager.distance/1000.0];
    self.label_water2_time.text = [CNUtil duringTimeStringFromSecond:[kApp.runManager during]/1000];
    self.label_water2_speed.text = [CNUtil pspeedStringFromSecond:kApp.runManager.secondPerKm];
    self.label_water3_km.text = [NSString stringWithFormat:@"%0.2fKM",kApp.runManager.distance/1000.0];
    self.label_water3_date.text = [CNUtil getTimeFromTimestamp_ymd:[CNUtil getNowTime]];
    self.label_water3_time.text = [CNUtil getTimeFromTimestamp_ms:[CNUtil getNowTime]];
    self.label_water4_km.text = [NSString stringWithFormat:@"%0.2fKM",kApp.runManager.distance/1000.0];
    NSString* wob = self.whiteOrBlack == 0?@"w":@"b";
    NSString* imageName = [NSString stringWithFormat:@"weather_marker_%@_%@_%@.png",wob,dayOrNight,weatherCode];
    self.imageview_water3_weather.image = [UIImage imageNamed:imageName];
}
- (void)trackWater{
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view_hidemap.bounds.size.width, self.view_hidemap.bounds.size.height)];
    [self.view_hidemap addSubview:self.mapView];
    int pointCount = [kApp.runManager.GPSList count];
    CNGPSPoint* firstPoint = [kApp.runManager.GPSList objectAtIndex:0];
    CLLocationCoordinate2D wgs84Point_first = CLLocationCoordinate2DMake(firstPoint.lat, firstPoint.lon);
    CLLocationCoordinate2D encryptionPoint_first = [CNEncryption encrypt:wgs84Point_first];
    double min_lon = encryptionPoint_first.longitude;
    double min_lat = encryptionPoint_first.latitude;
    double max_lon = encryptionPoint_first.longitude;
    double max_lat = encryptionPoint_first.latitude;
    int i;
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
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.001, max_lon-min_lon+0.001);
    MACoordinateRegion region = MACoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:NO];
    //水印
    NSMutableArray* trackpoints = [[NSMutableArray alloc]init];
    for(i=0;i<pointCount;i++){
        CNGPSPoint* gpsPoint = [kApp.runManager.GPSList objectAtIndex:i];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(gpsPoint.lat, gpsPoint.lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        //计算经纬度转屏幕坐标后的坐标
        [trackpoints addObject:[NSValue valueWithCGPoint:[self.mapView convertCoordinate:encryptionPoint toPointToView:self.view_hidemap]]];
    }
    self.view_onlyTrack.pointArray = trackpoints;
    self.view_onlyTrack.color = @"white";
    [self.view_onlyTrack setNeedsDisplay];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView==self.scrollview){
        CGPoint offset = scrollView.contentOffset;
        self.pageControl.currentPage = offset.x/320; //计算当前的页码
        self.currentPage = self.pageControl.currentPage;
        NSLog(@"current page is %i",self.pageControl.currentPage);
    }
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
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            [self whiteBlackConvert];
            break;
        }
        case 2:
        {
            float image_width = self.image_datasource.size.width;
            float image_height = self.image_datasource.size.height;
            NSLog(@"image_width is %f",image_width);
            NSLog(@"image_height is %f",image_height);
            UIImage* image_water = [self imageWithUIView:self.view_water1];
            NSLog(@"image_water width is %f",image_water.size.width);
//            UIImage* saveImage = [self addImage:image_water toImage:self.image_datasource];
            
            
            UIImage* saveImage = [self snapshot:self.view_savaImage];
            UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate_addWater addWaterDidSuccess:saveImage];
            break;
        }
        default:
            break;
    }
    
    
}
- (UIImage *)snapshot:(UIView *)view

{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
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
-(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    float scale = 1024.0/320.0;
    
    UIGraphicsBeginImageContext(image2.size);
    
    //Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    //Draw image1
    [image1 drawInRect:CGRectMake(50,50, image1.size.width*scale, image1.size.height*scale)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    [kApp.window makeToast:msg duration:1 position:nil];
}
- (void)whiteBlackConvert{
    if(self.whiteOrBlack == 0){//当前白色主题，则转为黑色
        self.whiteOrBlack = 1;
        self.imageview_logo_cn.image = [UIImage imageNamed:@"yaopao_cn_logo_black"];
        self.imageview_yaopaoyiqipao.image = [UIImage imageNamed:@"yaopaoyiqipao_black"];
        [self.button_whiteBlackConvert setBackgroundImage:[UIImage imageNamed:@"white_black.png"] forState:UIControlStateNormal];
        self.label_water1_km.textColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.label_water2_km.textColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.label_water2_time.textColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.label_water2_speed.textColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.label_water3_km.textColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.label_water3_date.textColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.label_water3_time.textColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.label_water4_km.textColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.view_water3_line.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:1];
        self.view_onlyTrack.color = @"black";
        [self.view_onlyTrack setNeedsDisplay];
    }else{
        self.whiteOrBlack = 0;
        self.imageview_logo_cn.image = [UIImage imageNamed:@"yaopao_cn_logo_white"];
        self.imageview_yaopaoyiqipao.image = [UIImage imageNamed:@"yaopaoyiqipao_white"];
        [self.button_whiteBlackConvert setBackgroundImage:[UIImage imageNamed:@"black_white.png"] forState:UIControlStateNormal];
        self.label_water1_km.textColor = [UIColor whiteColor];
        self.label_water2_km.textColor = [UIColor whiteColor];
        self.label_water2_time.textColor = [UIColor whiteColor];
        self.label_water2_speed.textColor = [UIColor whiteColor];
        self.label_water3_km.textColor = [UIColor whiteColor];
        self.label_water3_date.textColor = [UIColor whiteColor];
        self.label_water3_time.textColor = [UIColor whiteColor];
        self.label_water4_km.textColor = [UIColor whiteColor];
        self.view_water3_line.backgroundColor = [UIColor whiteColor];
        self.view_onlyTrack.color = @"white";
        [self.view_onlyTrack setNeedsDisplay];
    }
    NSString* wob = self.whiteOrBlack == 0?@"w":@"b";
    NSString* imageName = [NSString stringWithFormat:@"weather_icon_%@_%@_%@.png",wob,dayOrNight,weatherCode];
    NSLog(@"weather name is %@",imageName);
    self.imageview_water3_weather.image = [UIImage imageNamed:imageName];
}

@end

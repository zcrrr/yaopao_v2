//
//  AddWaterMarkToImageViewController.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/28.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "AddWaterMarkToImageViewController.h"
#import "WaterMarkDownloadViewController.h"
#import "ToolClass.h"
#import "SBJson.h"
#import "CNRunManager.h"
#import "CNGPSPoint.h"
#import "CNEncryption.h"
#import "RunClass.h"
#import "CNUtil.h"

//#define FONTNAME @"Verdana-Bold"
#define FONTHEIGHT 30
@interface AddWaterMarkToImageViewController ()

@end

@implementation AddWaterMarkToImageViewController
@synthesize oneRun;
@synthesize imageArray;
@synthesize ImageView;
@synthesize scrollView;
@synthesize mapView;
extern NSString* weatherCode;
extern NSString* dayOrNight;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.wmGroupArray = [[NSMutableArray alloc]init];
    self.imageArray = [[NSMutableArray alloc]init];
    self.ImageView.image = self.workImage;
    self.currentGroup = 0;
    self.white = YES;
    self.weatherImage_w = [UIImage imageNamed:[NSString stringWithFormat:@"weather_marker_%@_%@_%@.png",@"w",dayOrNight,weatherCode]];
    self.weatherImage_b = [UIImage imageNamed:[NSString stringWithFormat:@"weather_marker_%@_%@_%@.png",@"b",dayOrNight,weatherCode]];
    
    //TODO:测试值,正式使用时请在其他类中进行赋值。
    if(self.oneRun != nil){
        self.distanceText = [NSString stringWithFormat:@"%0.2fKM",[self.oneRun.distance doubleValue]/1000.0];
        self.duringText = [CNUtil duringTimeStringFromSecond:[self.oneRun.duration intValue]/1000];
        self.secondPerKMText = [CNUtil pspeedStringFromSecond:[self.oneRun.secondPerKm intValue]];
    }
    
    
    self.date = [NSDate date];
    [self trackWater];
//    self.pointArray = [[NSMutableArray alloc]init];
//    for (NSInteger i = 0; i< 20; i++) {
//        [self.pointArray addObject:[NSValue valueWithCGPoint:CGPointMake(i+i*6, i*5)]];
//    }
    self.saveBtn.layer.cornerRadius = 3.f;
    
}
- (void)trackWater{
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.view_hidemap.bounds.size.width, self.view_hidemap.bounds.size.height)];
    NSLog(@"map width is %f,map height is %f",self.view_hidemap.bounds.size.width,self.view_hidemap.bounds.size.height);
    [self.view_hidemap addSubview:self.mapView];
    int pointCount = (int)[kApp.runManager.GPSList count];
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
    MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat, max_lon-min_lon);
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
        NSLog(@"x:%f,y:%f",[self.mapView convertCoordinate:encryptionPoint toPointToView:self.view_hidemap].x,[self.mapView convertCoordinate:encryptionPoint toPointToView:self.view_hidemap].y);
    }
    self.pointArray = trackpoints;
}
- (void)viewWillAppear:(BOOL)animated{
  
    
    //读取水印
    [self InitWmArray];
    
    if (self.wmGroupArray.count != 0) {
        WMGroupInfo *firstGroup = [self.wmGroupArray objectAtIndex:0];
        self.pageControl.numberOfPages = firstGroup.watermarkArray.count;
    }
    else{
        self.pageControl.numberOfPages = 0;
    }
    
}


- (void)viewDidAppear:(BOOL)animated{
    
    
    self.currentGroup = 0;
    //初始化水印组的scrollView
    self.groupScrollView.WMGroupDataSource = self;
    self.groupScrollView.WMGroupDelegate = self;
    [self.groupScrollView InitSubViews];
    //根据水印信息初始化scrollView
    self.scrollView.WMDataSource = self;
    self.scrollView.WMDelegate = self;    
    [self.scrollView reloadScrollView:YES];

}


- (NSString *)getWMBaseFilePath:(NSString *)wmName{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *filepath = [NSString stringWithFormat:@"%@/waterMarks/%@",documentPath,wmName];
    
    return filepath;
}

//初始化水印信息
- (void)InitWmArray{
    
    [self.wmGroupArray removeAllObjects];
    
    //添加默认水印组
    WMGroupInfo *DefaultGroup = [[WMGroupInfo alloc]init];
    DefaultGroup.isDefaults = YES;
    NSString *DeFilepath = [NSBundle mainBundle].bundlePath;
    NSString *DeImageName = [NSString stringWithFormat:@"%@/group_icon.png",DeFilepath];
    DefaultGroup.image = [UIImage imageWithContentsOfFile:DeImageName];
    NSString *DeDesc = [NSString stringWithFormat:@"%@/desc.txt",DeFilepath];
    
    NSError *error;
    DefaultGroup.json = [NSString stringWithContentsOfFile:DeDesc encoding:NSUTF8StringEncoding error:&error];
    [DefaultGroup InitWaterMarkInGroup:DefaultGroup.json
                   withDistance:self.distanceText
                withSecondPerKM:self.secondPerKMText
                     withDuring:self.duringText
                       withDate:self.date];
    [self.wmGroupArray addObject:DefaultGroup];
    
    
    /**
     *  添加下载水印组
     */
    NSString *path = [ToolClass getDocument:@"wmFolders.plist"];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
    
    for (NSDictionary *dic in array) {
        
        WMGroupInfo *group = [[WMGroupInfo alloc]init];
        group.isDefaults = NO;
        group.name = [dic objectForKey:@"name"];
        NSString *filepath = [self getWMBaseFilePath:group.name];
        NSString *imageName = [NSString stringWithFormat:@"%@/group_icon.png",filepath];
        
        group.image = [UIImage imageWithContentsOfFile:imageName];
        //TODO:测试用图片，正式使用时请删除下面一行代码，使用上一行代码.
//        group.image = [UIImage imageNamed:@"bg.jpg"];
        
        
        NSString *desc = [NSString stringWithFormat:@"%@/desc.txt",filepath];
        NSError *error;
        group.json = [NSString stringWithContentsOfFile:desc encoding:NSUTF8StringEncoding error:&error];
       
    
        [group InitWaterMarkInGroup:group.json
                       withDistance:self.distanceText
                    withSecondPerKM:self.secondPerKMText
                         withDuring:self.duringText
                           withDate:self.date];
        
        [self.wmGroupArray addObject:group];
    }
}
- (UIImage *)addImageWaterMark:(UIImage *)bgImage addMaskImage:(UIImage *)maskImage
{
    
    CGSize BGsize = self.workImage.size;
    //支持retina高分的关键
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(BGsize, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(BGsize);
    }
    [bgImage drawInRect:CGRectMake(0, 0, BGsize.width, BGsize.height)];
    
    //四个参数为水印图片的位置
    [maskImage drawInRect:CGRectMake(0, 0, BGsize.width, BGsize.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}
- (IBAction)saveBtnClick:(id)sender {
    
    UIImageView *curImageView = [self.scrollView.imageViews objectAtIndex:self.pageControl.currentPage];
    
    if (curImageView.image) {
        [self.AddWMDelegate addWaterDidSuccess:[self addImageWaterMark:self.workImage addMaskImage:curImageView.image]];
    }
    else{
        [self.AddWMDelegate addWaterDidFailed:@"图片为nil"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)backBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark WMDataSource And Delegate
- (NSUInteger)numberOfImageViews{
    
    if (self.wmGroupArray.count != 0) {
        WMGroupInfo *groupInfo = [self.wmGroupArray objectAtIndex:self.currentGroup];
        return groupInfo.watermarkArray.count;
    }
    else{
        return 0;
    }
    
    
}

- (UIImage *)imageOfIndex:(NSInteger)index{

    WMGroupInfo *groupInfo = [self.wmGroupArray objectAtIndex:self.currentGroup];
    WMItems *item = [groupInfo.watermarkArray objectAtIndex:index];
    
    return [self CreatWaterMark:item isDefaultsItem:groupInfo.isDefaults];
}

- (void)DidImageViewIndexChanged:(NSInteger)index{
    
    self.pageControl.currentPage = index;
}


#pragma -mark WMGroup DataSource And Delegate
- (NSUInteger)numberOfWMGroupImageViews{
    
    return self.wmGroupArray.count;
}

- (UIImage *)GroupImageOfIndex:(NSInteger)index{
    
    WMGroupInfo *groupInfo = [self.wmGroupArray objectAtIndex:index];
    return groupInfo.image;
}

- (void)DidClickWMGroupImageAtIndex:(NSInteger)index withImage:(UIImage *)image{
    
    self.currentGroup = index;
    
    //重载scroll元素。
    [self.scrollView reloadScrollView:YES];
    
    WMGroupInfo *firstGroup = [self.wmGroupArray objectAtIndex:index];
    self.pageControl.numberOfPages = firstGroup.watermarkArray.count;
    self.pageControl.currentPage = 0;
}

- (void)ChangeWhiteAndBlack{
    if (self.white) {
        self.white = NO;
        [self.groupScrollView.whiteOrBlack setImage:[UIImage imageNamed:@"watermark_w.png"] forState:UIControlStateNormal];
    }
    else{
        self.white = YES;
        [self.groupScrollView.whiteOrBlack setImage:[UIImage imageNamed:@"watermark_b.png"] forState:UIControlStateNormal];
    }
    //重载scroll元素。
    [self.scrollView reloadScrollView:NO];
}

- (void)AddNewWaterMarkBtnClick{
    
    WaterMarkDownloadViewController *WaterMarkDownloadVC = [[WaterMarkDownloadViewController alloc]init];
//    [self presentViewController:WaterMarkDownloadVC animated:YES completion:nil];
    [self.navigationController pushViewController:WaterMarkDownloadVC animated:YES];
}
/*
- (void)testCode{
    
    static CGFloat BGImageWidth = 1080;
    CGFloat scale = BGImageWidth/self.scrollView.frame.size.width;
     UIImage *WMImage = [UIImage imageNamed:@"clearBG.png"];
    WMItems *item = [self.waterMarkArray objectAtIndex:0];
    
    
    NSString *filepath = [self getWMBaseFilePath:item.groupName];
    NSString *imagePath = [NSString stringWithFormat:@"%@/marker_standard_1_1_w",filepath];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
   
   // self.testImageView.image = [self addImageWaterMark:WMImage addMaskImage:image maskRect:CGRectMake(100, 100, 100, 50)];
    
    //添加图片
    if (item.images.count != 0) {
        
        for (ImageInfo *imageInfo in item.images) {
            CGRect rect = CGRectMake(imageInfo.x/scale, imageInfo.y/scale, imageInfo.width/scale, imageInfo.height/scale);
            UIImage *image;
            NSString *filepath = [self getWMBaseFilePath:item.groupName];
            NSString *imagePath;
            if (self.white) {
                imagePath = [NSString stringWithFormat:@"%@/%@",filepath,imageInfo.whiteImage];
            }
            else{
                imagePath = [NSString stringWithFormat:@"%@/%@",filepath,imageInfo.blackImage];
            }
            
            image = [UIImage imageWithContentsOfFile:imagePath];
            
        }
    }
}
*/

#pragma mark DrawSomethingsOnImageView

- (UIImage *)CreatWaterMark:(WMItems *)item isDefaultsItem:(BOOL)defaults{
    
    static CGFloat BGImageWidth = 1080;
    CGFloat scale_W = BGImageWidth/self.scrollView.frame.size.width;
    CGFloat scale_H = BGImageWidth/self.scrollView.frame.size.height;
    UIImage *WMImage = [UIImage imageNamed:@"clearBG.png"];
    
    //添加要跑LOGO
    UIImage *logo;
    if (self.white) {
         logo = [UIImage imageNamed:@"watermark_yaopao_w"];
    }
    else{
        logo = [UIImage imageNamed:@"watermark_yaopao_b"];

    }
    
    //TODO:添加要跑LOGO，设定LOGO位置
    CGRect LogoRect = CGRectMake(927.f/scale_W, 85.f/scale_H, 135.f/scale_W, 61.f/scale_H);
    WMImage = [self addImageWaterMark:WMImage addMaskImage:logo maskRect:LogoRect];

    
    //添加图片
    if (item.images.count != 0){
        
        for (ImageInfo *imageInfo in item.images) {
            CGRect rect = CGRectMake(imageInfo.x/scale_W, imageInfo.y/scale_H, imageInfo.width/scale_W, imageInfo.height/scale_H);
            UIImage *image;
            NSString *filepath;
            
            if (imageInfo.imageType == 0) {
                if (defaults) {
                    filepath = [NSBundle mainBundle].bundlePath;
                }
                else{
                    filepath = [self getWMBaseFilePath:item.groupName];
                }
                NSString *imagePath;
                if (self.white) {
                    imagePath = [NSString stringWithFormat:@"%@/%@",filepath,imageInfo.whiteImage];
                }
                else{
                    imagePath = [NSString stringWithFormat:@"%@/%@",filepath,imageInfo.blackImage];
                }
                 image = [UIImage imageWithContentsOfFile:imagePath];
            }
            else{
                if (self.white) {
                    image = self.weatherImage_w;
                }
                else{
                    image = self.weatherImage_b;
                }
            }
        
           
            WMImage = [self addImageWaterMark:WMImage addMaskImage:image maskRect:rect];
        }
    }
    
    //添加Line
    if (item.line){
        
        CGRect rect = CGRectMake(item.line.x/scale_W, item.line.y/scale_H, item.line.width/scale_W, item.line.height/scale_H);
        
       WMImage =  [self addLineWaterMark:WMImage withRect:rect];
    }
    
    //添加Track
    if (item.track){
        
        CGRect rect = CGRectMake(item.track.x/scale_W, item.track.y/scale_H, item.track.width/scale_W, item.track.height/scale_H);
        NSLog(@"width is %f,height is %f",rect.size.width,rect.size.height);
        NSLog(@"x is %f,y is %f",rect.origin.x,rect.origin.y);
        
        UIImage *wmImage = [self addTrackWaterMark:nil withTrackArray:self.pointArray maskRect:rect];
        
        WMImage = [self addImageWaterMark:WMImage addMaskImage:wmImage maskRect:rect];
    }
    
    //添加Distance
    if (item.distance){
         NSInteger fontSize = item.distance.fontsize/scale_H;
        CGRect rect = [self makeCGRectByAnchor:item.distance.anchor withX:item.distance.x/scale_W withY:item.distance.y/scale_H withText:item.distance.text withFontSiz:fontSize];
       
       WMImage =  [self addTextWaterMark:WMImage withText:item.distance.text maskRect:rect withFontSize:fontSize withAnchor:item.distance.anchor];
    }
    
    //添加SeconPerKM
    if (item.secondPerKM){
        NSInteger fontSize = item.secondPerKM.fontsize/scale_H;
        CGRect rect = [self makeCGRectByAnchor:item.secondPerKM.anchor withX:item.secondPerKM.x/scale_W withY:item.secondPerKM.y/scale_H withText:item.secondPerKM.text withFontSiz:fontSize];
        
        WMImage =  [self addTextWaterMark:WMImage withText:item.secondPerKM.text maskRect:rect withFontSize:fontSize withAnchor:item.secondPerKM.anchor];
    }
    
    //添加During
    if (item.during){
        NSInteger fontSize = item.during.fontsize/scale_H;
        CGRect rect = [self makeCGRectByAnchor:item.during.anchor withX:item.during.x/scale_W withY:item.during.y/scale_H withText:item.during.text withFontSiz:fontSize];
        
        WMImage =  [self addTextWaterMark:WMImage withText:item.during.text maskRect:rect withFontSize:fontSize withAnchor:item.during.anchor];
    }
    
    //添加Date
    if (item.multiDate.count != 0){
        
        for (Date *date in item.multiDate) {
            
            NSInteger fontSize = date.fontsize/scale_H;
            CGRect rect = [self makeCGRectByAnchor:date.anchor withX:date.x/scale_W withY:date.y/scale_H withText:date.text withFontSiz:fontSize];
            
            WMImage =  [self addTextWaterMark:WMImage withText:date.text maskRect:rect withFontSize:fontSize withAnchor:date.anchor];
        }
       
    }
    return WMImage;
}



- (CGRect)makeCGRectByAnchor:(NSInteger)anchor withX:(CGFloat)anchor_x withY:(CGFloat)anchor_y withText:(NSString *)text withFontSiz:(NSInteger)fontSize{
    
    
    //通过字体大小获取文本宽高。
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;

    NSInteger Finalfontsize = fontSize/96.f * 72.f;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, text.length*fontSize, fontSize)];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:Finalfontsize];
//    label.font = [UIFont fontWithName:FONTNAME size:Finalfontsize];
    label.numberOfLines = 1;
    label.adjustsFontSizeToFitWidth = YES;

    CGRect rect = label.frame;
    //rect.size.height = fontSize;
    /*
    NSDictionary *dic = @{
                             NSFontAttributeName:[UIFont fontWithName:FONTNAME size:Finalfontsize],
                             NSParagraphStyleAttributeName:style,
                         };
    CGSize size = [text sizeWithAttributes:dic];
    CGRect rect;
    rect.size.width = size.width;
    rect.size.height = fontSize;
    */
    
    //设定锚点
    switch (anchor) {
        case 1:    //左上角
            rect.origin.x = anchor_x;
            rect.origin.y = anchor_y;
            break;
        case 2:   //上边中点
            rect.origin.x = anchor_x - rect.size.width/2;
            rect.origin.y = anchor_y;
            break;
        case 3:   //右上角
            rect.origin.x = anchor_x - rect.size.width;
            rect.origin.y = anchor_y;
            break;
        case 4:  //左边中点
            rect.origin.x = anchor_x;
            rect.origin.y = anchor_y - rect.size.height/2;
            break;
        case 5:  //中心点
            rect.origin.x = anchor_x - rect.size.width/2;
            rect.origin.y = anchor_y - rect.size.height/2;
            break;
        case 6:  //右边中点
            rect.origin.x = anchor_x - rect.size.width;
            rect.origin.y = anchor_y - rect.size.height/2;
            break;
        case 7:  //左下角
            rect.origin.x = anchor_x;
            rect.origin.y = anchor_y - rect.size.height;
            break;
        case 8:  //下边中点
            rect.origin.x = anchor_x - rect.size.width/2;
            rect.origin.y = anchor_y - rect.size.height;
            break;
        case 9:  //右下角
            rect.origin.x = anchor_x - rect.size.width;
            rect.origin.y = anchor_y - rect.size.height;
            break;
        default:
            break;
    }
    
    return rect;
}


//添加线条水印
- (UIImage *)addLineWaterMark:(UIImage *)bgImage withRect:(CGRect)rect{
    
    
    //支持retina高分的关键
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(bgImage.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(bgImage.size);
    }
    
    //2.绘制图片
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), rect.size.height);  //线宽
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    if (self.white) {
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 1.0);  //白色
    }
    else{
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);  //黑色
    }
    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), rect.origin.x, rect.origin.y);  //起点坐标
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), rect.origin.x+rect.size.width, rect.origin.y);   //终点坐标
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    bgImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return bgImage;
}

//添加图片水印
- (UIImage *)addImageWaterMark:(UIImage *)bgImage addMaskImage:(UIImage *)maskImage maskRect:(CGRect)rect
{
    
    CGSize SVsize = self.scrollView.frame.size;
    //支持retina高分的关键
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(SVsize, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(SVsize);
    }
    [bgImage drawInRect:CGRectMake(0, 0, SVsize.width, SVsize.height)];
    
    //四个参数为水印图片的位置
    [maskImage drawInRect:rect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

//添加文字水印
- (UIImage *)addTextWaterMark:(UIImage *)bgImage withText:(NSString *)text maskRect:(CGRect)rect withFontSize:(NSInteger)fontSize withAnchor:(NSInteger)anchor{
    
    CGSize SVsize = self.scrollView.frame.size;
    //支持retina高分的关键
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(SVsize, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(SVsize);
    }
    [bgImage drawInRect:CGRectMake(0, 0, SVsize.width, SVsize.height)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    
    if (anchor == 1 || anchor == 4 || anchor == 7) {
        style.alignment = NSTextAlignmentLeft;
    }
    else if (anchor == 2 || anchor == 5 || anchor == 8){
        style.alignment = NSTextAlignmentCenter;
    }
    else{
        style.alignment = NSTextAlignmentRight;
    }
    
    NSDictionary *dic;
    
    NSInteger finalSize = (fontSize/96.f)*72.f;
    if (self.white) {
        dic = @{
                NSFontAttributeName:[UIFont systemFontOfSize:finalSize],
//                NSFontAttributeName:[UIFont fontWithName:FONTNAME size:finalSize],
                NSParagraphStyleAttributeName:style,
                NSForegroundColorAttributeName:[UIColor whiteColor]
                };
    }
    else{
        dic = @{
                NSFontAttributeName:[UIFont systemFontOfSize:finalSize],
                NSParagraphStyleAttributeName:style,
                NSForegroundColorAttributeName:[UIColor blackColor]
                };
    }
    
    //将文字绘制上去
    [text drawInRect:rect withAttributes:dic];
    //4.获取绘制到得图片
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.结束图片的绘制
    UIGraphicsEndImageContext();
    return watermarkImage;
}

- (UIImage *)addTrackWaterMark:(UIImage *)bgImage withTrackArray:(NSArray *) points maskRect:(CGRect)rect{
    
    //支持retina高分的关键
    if(&UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(rect.size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (self.white) {
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 1.0);  //白色
    }
    else{
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);  //黑色
    }
    CGContextSetLineWidth(context, 3.0);
    CGPoint firstPoint = [[points objectAtIndex:0]CGPointValue];
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    for(NSValue* pointvalue in points){
        CGPoint point = [pointvalue CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

@end

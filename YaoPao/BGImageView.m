//
//  scrollImageView.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/3.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "BGImageView.h"

//#define FONTNAME @"Verdana-Bold"

@implementation BGImageView

- (instancetype) initWithFrame:(CGRect)frame{

    return self;
}
- (void)initGestureRecognizer{
    
    
    self.workImage = self.image;
    
    self.userInteractionEnabled = YES;
    
    /*
    //监听左右滑动手势
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer];
    
    self.currentPage = 0;
     */
    
}

/*
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
  
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        //NSLog(@"swipe left");
        //执行程序
        if (self.currentPage == self.totalPage-1) {
            self.currentPage = 0;
        }
        else{
            self.currentPage++;
        }
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        //NSLog(@"swipe right");
        //执行程序
        if (self.currentPage == 0) {
            self.currentPage = self.totalPage-1;
        }
        else{
            self.currentPage--;
        }
    }
    
    NSLog(@"%@",@(self.currentPage).stringValue);
    
    [self reloadScrollImageView];
    
}

- (void)reloadScrollImageView{
    
    //切换水印
    WMItems *item = [self.delegate scrollToWaterMark:self.currentPage];
    [self changeWaterMark:item];
}

- (void)AddWaterMark:(UIImage *)Image withText:(NSString *)text{
    
   self.image = [self addTextWaterMark:Image withText:text maskRect:CGRectMake(100, 100, 100, 100)];
}
*/

/*
- (UIImage *)changeWaterMark:(WMItems *)item{
    
    static CGFloat BGImageWidth = 1080;
    CGFloat scale = BGImageWidth/self.frame.size.width;
    
    UIImage *WMImage = self.workImage;
    
     //添加图片
    if (item.images.count != 0) {
       
        for (ImageInfo *imageInfo in item.images) {
            CGRect rect = CGRectMake(imageInfo.x/scale, imageInfo.y/scale, imageInfo.width/scale, imageInfo.height/scale);
            UIImage *wmImage;
            if (self.white) {
                wmImage = [UIImage imageWithContentsOfFile:imageInfo.whiteImage];
            }
            else{
                wmImage = [UIImage imageWithContentsOfFile:imageInfo.blackImage];
            }
            [self addImageWaterMark:WMImage addMaskImage:wmImage maskRect:rect];
        }
    }
    
    //添加Line
    if (item.line) {
        
        CGRect rect = CGRectMake(item.line.x/scale, item.line.y/scale, item.line.width/scale, item.line.height/scale);
        
        [self addLineWaterMark:WMImage withRect:rect];
    }
    
    //添加Track
    if (item.track) {
        
        CGRect rect = CGRectMake(item.track.x/scale, item.track.y/scale, item.track.width/scale, item.track.height/scale);
        //TODO: 需要确认轨迹数据形式，以及来源.
        UIImage *wmImage;
        if (self.white) {
           // wmImage = [UIImage imageWithContentsOfFile:imageInfo.whiteImage];
        }
        else{
            //wmImage = [UIImage imageWithContentsOfFile:imageInfo.blackImage];
        }
        [self addImageWaterMark:WMImage addMaskImage:wmImage maskRect:rect];
    }
    
    //添加Distance
    if (item.distance) {

        CGRect rect = [self makeCGRectByAnchor:item.distance.anchor withX:item.distance.x/scale withY:item.distance.y/scale withText:item.distance.text withFontSiz:item.distance.fontsize];
        [self addTextWaterMark:WMImage withText:item.distance.text maskRect:rect];
        
    }
    
    //添加SeconPerKM
    if (item.secondPerKM) {
        
        CGRect rect = [self makeCGRectByAnchor:item.secondPerKM.anchor withX:item.secondPerKM.x/scale withY:item.secondPerKM.y/scale withText:item.secondPerKM.text withFontSiz:item.secondPerKM.fontsize];
        [self addTextWaterMark:WMImage withText:item.secondPerKM.text maskRect:rect];
        
    }
    
    //添加During
    if (item.during) {
        
        CGRect rect = [self makeCGRectByAnchor:item.during.anchor withX:item.during.x/scale withY:item.during.y/scale withText:item.during.text withFontSiz:item.during.fontsize];
        [self addTextWaterMark:WMImage withText:item.during.text maskRect:rect];
        
    }
    
    //添加Date
    if (item.date) {
        
        CGRect rect = [self makeCGRectByAnchor:item.date.anchor withX:item.date.x/scale withY:item.date.y/scale withText:item.date.text withFontSiz:item.date.fontsize];
        [self addTextWaterMark:WMImage withText:item.date.text maskRect:rect];
        
    }
    
    return WMImage;
}



- (CGRect)makeCGRectByAnchor:(NSInteger)anchor withX:(CGFloat)anchor_x withY:(CGFloat)anchor_y withText:(NSString *)text withFontSiz:(NSInteger)fontSize{
    
    UILabel *label = [[UILabel alloc]init];
    label.text= text;
    label.font = [UIFont fontWithName:FONTNAME size:fontSize];
    label.adjustsFontSizeToFitWidth = YES;
    
    
    CGRect rect;
    rect.size.width = label.frame.size.width;
    rect.size.height = label.frame.size.height;
    
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

#pragma mark DrawSomethingsOnImageView
//添加线条水印
- (UIImage *)addLineWaterMark:(UIImage *)bgImage withRect:(CGRect)rect{
    
    
    //1.获取上下文
    UIGraphicsBeginImageContext(bgImage.size);
    //2.绘制图片
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), rect.size.height);  //线宽
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    if (self.white) {
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);  //白色
    }
    else{
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 1.0, 1.0, 1.0);  //黑色
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
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    
    //四个参数为水印图片的位置
    [maskImage drawInRect:rect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

//添加文字水印
- (UIImage *)addTextWaterMark:(UIImage *)bgImage withText:(NSString *)text maskRect:(CGRect)rect{
    
    
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
    //CGRect rect = CGRectMake(0, bgImage.size.height/2, bgImage.size.width/2, 100);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *dic;
    if (self.white) {
        dic = @{
                NSFontAttributeName:[UIFont fontWithName:FONTNAME size:40],
                NSParagraphStyleAttributeName:style,
                NSForegroundColorAttributeName:[UIColor whiteColor]
                };
    }
    else{
        dic = @{
                NSFontAttributeName:[UIFont fontWithName:FONTNAME size:40],
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
*/

@end

//
//  ShowWMImageViewController.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/29.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "ShowWMImageViewController.h"

@interface ShowWMImageViewController ()

@end

@implementation ShowWMImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.AddVC= [[AddWaterMarkToImageViewController alloc]init];
    self.AddVC.AddWMDelegate = self;
}

- (void)addWaterDidSuccess:(UIImage *)image{
    
    self.BackGroundImage.image = [self addImageWaterMark:self.BackGroundImage.image addMaskImage:image];
}

- (void)addWaterDidFailed:(NSString *)desc{
    
    NSLog(@"%@",desc);
}

- (IBAction)ToAddWmView:(id)sender {
    
    
    self.AddVC.workImage = self.BackGroundImage.image;
    [self presentViewController:self.AddVC animated:YES completion:nil];
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//添加图片水印
- (UIImage *)addImageWaterMark:(UIImage *)bgImage addMaskImage:(UIImage *)maskImage
{
    
    CGSize BGsize = self.BackGroundImage.frame.size;
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
@end

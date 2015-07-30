//
//  ImageInfo.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/4.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageInfo : NSObject
@property (strong, nonatomic) NSString *whiteImage;
@property (strong, nonatomic) NSString *blackImage;
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) NSInteger imageType;      //0-普通图片  1-天气图片
@end

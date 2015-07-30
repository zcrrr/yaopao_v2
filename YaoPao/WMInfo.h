//
//  WMInfo.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/27.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WMStatus){
    WMStatusUnDownLoad  = 0,          //未下载
    WMStatusDownLoading = 1,          //下载中
    WMStatusDownLoaded  = 2,          //已下载

};

//WM == WaterMark
@interface WMInfo : NSObject
@property (strong, nonatomic) NSString *Name;
@property (strong, nonatomic) NSString *Details;
@property (assign, nonatomic) WMStatus Status;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageUrl;        //图片url地址
@property (strong, nonatomic) NSString *imageName;       //图片本地名称
@property (strong, nonatomic) NSString *WMZipUrl;        //本组水印包下载地址
@property (assign, nonatomic, setter=isNewOne:) BOOL newOne;

@end

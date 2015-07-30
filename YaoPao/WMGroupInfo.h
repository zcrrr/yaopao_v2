//
//  WMGroupInfo.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/3.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WMGroupInfo : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;      //缩略图
@property (strong, nonatomic) NSMutableArray *watermarkArray;
@property (strong, nonatomic) NSString *json;
@property (strong, nonatomic) NSString *path;
@property (assign, nonatomic) BOOL isDefaults;        //为默认水印组

- (void)InitWaterMarkInGroup:(NSString *)jsonStr withDistance:(NSString *)distance withSecondPerKM:(NSString *)secondPerKM withDuring:(NSString *)during withDate:(NSDate *)date;

//- (void)initWMItemswithDistance:(NSString *)distanceText withSecondPerKM:(NSString *)secondPerKMText withDuring:(NSString *)duringText withDate:(NSString *)dateText;
@end

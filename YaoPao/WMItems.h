//
//  WMItems.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/3.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageInfo.h"
#import "Line.h"
#import "Track.h"
#import "Distance.h"
#import "secondPerKM.h"
#import "During.h"
#import "Date.h"

@interface WMItems : NSObject

@property (strong, nonatomic) NSString *groupName;   //所在水印组名称
@property (assign, nonatomic) NSInteger WMID;
@property (strong, nonatomic) NSMutableArray *images;  //多张图片
@property (strong, nonatomic) NSMutableArray *multiDate;  //多个日期
@property (strong, nonatomic) Line *line;
@property (strong, nonatomic) Track *track;
@property (strong, nonatomic) Distance *distance;
@property (strong, nonatomic) SecondPerKM *secondPerKM;
@property (strong, nonatomic) During *during;
//@property (strong, nonatomic) Date *date;


@end

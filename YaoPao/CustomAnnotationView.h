//
//  CustomAnnotationView.h
//  YaoPao
//
//  Created by zc on 14-8-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface CustomAnnotationView : MAAnnotationView

@property (strong, nonatomic) NSString* paraminfo;
@property (nonatomic, strong) UILabel *label_km;
@property (nonatomic, strong) UILabel *label_time;

@end

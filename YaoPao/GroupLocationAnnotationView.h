//
//  GroupLocationAnnotationView.h
//  YaoPao
//
//  Created by 张驰 on 15/5/7.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "CustomCalloutView.h"

@interface GroupLocationAnnotationView : MAAnnotationView
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) CustomCalloutView *calloutView;
@end

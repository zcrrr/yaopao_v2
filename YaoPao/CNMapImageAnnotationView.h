//
//  CNMapImageAnnotationView.h
//  YaoPao
//
//  Created by zc on 14-9-1.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface CNMapImageAnnotationView : MAAnnotationView
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) NSString* type;
@end

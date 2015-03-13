//
//  CNTimeImageView.h
//  YaoPao
//
//  Created by zc on 14-9-2.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNTimeImageView : UIView

@property (assign, nonatomic) CGRect initFrame;
@property (assign, nonatomic) int time;
@property (strong, nonatomic) NSString* color;
@property (strong, nonatomic) UIImageView* image_time1;
@property (strong, nonatomic) UIImageView* image_time2;
@property (strong, nonatomic) UIImageView* image_time3;
@property (strong, nonatomic) UIImageView* image_time4;
@property (strong, nonatomic) UIImageView* image_time5;
@property (strong, nonatomic) UIImageView* image_time6;
@property (strong, nonatomic) UIImageView* image_colon1;
@property (strong, nonatomic) UIImageView* image_colon2;

- (void)fitToSize;

@end

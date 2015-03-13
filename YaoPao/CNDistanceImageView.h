//
//  CNDistanceImageView.h
//  YaoPao
//
//  Created by zc on 14-8-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNDistanceImageView : UIView


@property (assign, nonatomic) CGRect initFrame;
@property (assign, nonatomic) double distance;
@property (strong, nonatomic) NSString* color;
@property (strong, nonatomic) UIImageView* image_dis1;
@property (strong, nonatomic) UIImageView* image_dis2;
@property (strong, nonatomic) UIImageView* image_dis3;
@property (strong, nonatomic) UIImageView* image_dis4;
@property (strong, nonatomic) UIImageView* image_dis5;
@property (strong, nonatomic) UIImageView* image_dis6;
@property (strong, nonatomic) UIImageView* image_dot;

- (void)fitToSize;
- (void)fitToSizeLeft;
- (void)fitToSizeRight;
@property (assign, nonatomic) int digit;//位数



@end

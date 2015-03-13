//
//  CNNumImageView.h
//  YaoPao
//
//  Created by zc on 14-9-2.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNNumImageView : UIView

@property (assign, nonatomic) int digit;//位数
@property (assign, nonatomic) CGRect initFrame;
@property (assign, nonatomic) int num;
@property (strong, nonatomic) NSString* color;
@property (strong, nonatomic) UIImageView* image_num1;
@property (strong, nonatomic) UIImageView* image_num2;
@property (strong, nonatomic) UIImageView* image_num3;
@property (strong, nonatomic) UIImageView* image_num4;
@property (strong, nonatomic) UIImageView* image_num5;
- (void)fitToSize;
@end

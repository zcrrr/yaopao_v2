//
//  CNCustomButton.h
//  YaoPao
//
//  Created by 张驰 on 15/3/16.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNCustomButton : UIButton

@property (strong, nonatomic) UIColor* bgcolorNormal;
@property (strong, nonatomic) UIColor* bgcolorHighLight;
@property (strong, nonatomic) UIColor* titlecolorNormal;
@property (strong, nonatomic) UIColor* titlecolorHighLight;

- (void)fillColor:(UIColor*)bgcolorNormal1 :(UIColor*)bgcolorHighLight1 :(UIColor*)titlecolorNormal1 :(UIColor*)titlecolorHighLight1;

@end

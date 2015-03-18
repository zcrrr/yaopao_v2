//
//  CNCustomButton.m
//  YaoPao
//
//  Created by 张驰 on 15/3/16.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNCustomButton.h"

@implementation CNCustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)fillColor:(UIColor*)bgcolorNormal1 :(UIColor*)bgcolorHighLight1 :(UIColor*)titlecolorNormal1 :(UIColor*)titlecolorHighLight1{
    self.bgcolorNormal = bgcolorNormal1;
    self.bgcolorHighLight = bgcolorHighLight1;
    self.titlecolorNormal = titlecolorNormal1;
    self.titlecolorHighLight = titlecolorHighLight1;
    [super setBackgroundColor:self.bgcolorNormal];
    [self setTitleColor:titlecolorNormal1 forState:UIControlStateNormal];
    [self setTitleColor:titlecolorHighLight1 forState:UIControlStateHighlighted];
}

- (void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    if (highlighted) {
        [super setBackgroundColor:self.bgcolorHighLight];
    }else{
        [super setBackgroundColor:self.bgcolorNormal];
    }
}

@end

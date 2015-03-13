//
//  CNNumImageView.m
//  YaoPao
//
//  Created by zc on 14-9-2.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNNumImageView.h"

@implementation CNNumImageView
@synthesize image_num1;
@synthesize image_num2;
@synthesize image_num3;
@synthesize image_num4;
@synthesize image_num5;
@synthesize initFrame;
@synthesize digit;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.initFrame = frame;
        float image_height = frame.size.height;
        float image_width = image_height/160*100;
        self.image_num1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,image_width, image_height)];
        self.image_num1.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_num1];
        self.image_num2 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width, 0,image_width, image_height)];
        self.image_num2.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_num2];
        self.image_num3 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*2, 0,image_width, image_height)];
        self.image_num3.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_num3];
        self.image_num4 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*3, 0,image_width, image_height)];
        self.image_num4.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_num4];
        self.image_num5 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*4, 0,image_width, image_height)];
        self.image_num5.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_num5];
    }
    return self;
}
- (void)setNum:(int)num{
    _num = num;
}
- (void)setColor:(NSString *)color{
    _color = color;
}
- (void)fitToSize{
    self.image_num1.hidden = NO;
    self.image_num2.hidden = NO;
    self.image_num3.hidden = NO;
    self.image_num4.hidden = NO;
    self.frame = self.initFrame;
    
    if(self.num > 99999)self.num = 99999;
    
    int num1 = self.num/10000;
    self.num = self.num - num1*10000;
    int num2 = self.num/1000;
    self.num = self.num - num2*1000;
    int num3 = self.num/100;
    self.num = self.num - num3*100;
    int num4 = self.num/10;
    int num5 = self.num%10;
    self.image_num1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,num1]];
    self.image_num2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,num2]];
    self.image_num3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,num3]];
    self.image_num4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,num4]];
    self.image_num5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,num5]];
    
    self.digit = 5;
    if(num1 == 0){
        self.digit = 4;
        self.image_num1.hidden = YES;
        if(num2 == 0){
            self.digit = 3;
            self.image_num2.hidden = YES;
            if(num3 == 0){
                self.digit = 2;
                self.image_num3.hidden = YES;
                if(num4 == 0){
                    self.digit = 1;
                    self.image_num4.hidden = YES;
                }
            }
        }
    }
    [self offsizeView];
}
- (void)offsizeView{
    if(self.digit == 5){
        self.frame = initFrame;
    }
    int offsizeNum = 5-self.digit;//一位数字要往左偏移1个
    int width = self.image_num1.frame.size.width;
    CGRect newFrame = self.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left-width/2*offsizeNum, top);
    self.frame = newFrame;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

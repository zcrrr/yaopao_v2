//
//  CNDistanceImageView.m
//  YaoPao
//
//  Created by zc on 14-8-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNDistanceImageView.h"

@implementation CNDistanceImageView
@synthesize image_dis1;
@synthesize image_dis2;
@synthesize image_dis3;
@synthesize image_dis4;
@synthesize image_dis5;
@synthesize image_dis6;
@synthesize image_dot;
@synthesize digit;
@synthesize initFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.distance = 0.45;
//        self.color = @"red";
        self.initFrame = frame;
        
        float image_height = frame.size.height;
        float image_width = image_height/160*100;
        float interval = image_width/2;
        float dot_width = image_width/100*60;
        self.image_dis1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,image_width, image_height)];
        self.image_dis1.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_dis1];
        self.image_dis2 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width, 0,image_width, image_height)];
        self.image_dis2.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_dis2];
        self.image_dis3 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*2, 0,image_width, image_height)];
        self.image_dis3.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_dis3];
        self.image_dis4 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*3, 0,image_width, image_height)];
        self.image_dis4.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_dis4];
        self.image_dot = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*4+interval/2-dot_width/2, 0,dot_width, image_height)];
        image_dot.image = [UIImage imageNamed:@"red_point.png"];
        [self addSubview:image_dot];
        self.image_dis5 = [[UIImageView alloc]initWithFrame:CGRectMake(interval+image_width*4, 0,image_width, image_height)];
        self.image_dis5.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_dis5];
        self.image_dis6 = [[UIImageView alloc]initWithFrame:CGRectMake(interval+image_width*5, 0,image_width, image_height)];
        self.image_dis6.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_dis6];
    }
    return self;
}
- (void)setDistance:(double)distance{
    _distance = distance;
//    self.distance = distance;
}
- (void)setColor:(NSString *)color{
    _color = color;
}
- (void)fitToSize{
    
    self.image_dis1.hidden = NO;
    self.image_dis2.hidden = NO;
    self.image_dis3.hidden = NO;
    self.frame = self.initFrame;
    
    int distance100 = self.distance*100;
    int dis1num = distance100/100000;
    distance100 = distance100 - dis1num*100000;
    int dis2num = distance100/10000;
    distance100 = distance100 - dis2num*10000;
    int dis3num = distance100/1000;
    distance100 = distance100 - dis3num*1000;
    int dis4num = distance100/100;
    distance100 = distance100 - dis4num*100;
    int dis5num = distance100/10;
    int dis6num = distance100%10;
    self.image_dis1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis1num]];
    self.image_dis2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis2num]];
    self.image_dis3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis3num]];
    self.image_dis4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis4num]];
    self.image_dis5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis5num]];
    self.image_dis6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis6num]];
    image_dot.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_point.png",self.color]];
    
    
    self.digit = 4;
    if(dis1num == 0){
        self.digit = 3;
        self.image_dis1.hidden = YES;
        if(dis2num == 0){
            self.digit = 2;
            self.image_dis2.hidden = YES;
            if(dis3num == 0){
                self.digit = 1;
                self.image_dis3.hidden = YES;
            }
        }
    }
    [self offsizeView];
}
- (void)fitToSizeLeft{
    
    self.image_dis1.hidden = NO;
    self.image_dis2.hidden = NO;
    self.image_dis3.hidden = NO;
    self.frame = self.initFrame;
    
    int distance100 = self.distance*100;
    int dis1num = distance100/100000;
    distance100 = distance100 - dis1num*100000;
    int dis2num = distance100/10000;
    distance100 = distance100 - dis2num*10000;
    int dis3num = distance100/1000;
    distance100 = distance100 - dis3num*1000;
    int dis4num = distance100/100;
    distance100 = distance100 - dis4num*100;
    int dis5num = distance100/10;
    int dis6num = distance100%10;
    self.image_dis1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis1num]];
    self.image_dis2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis2num]];
    self.image_dis3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis3num]];
    self.image_dis4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis4num]];
    self.image_dis5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis5num]];
    self.image_dis6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis6num]];
    image_dot.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_point.png",self.color]];
    
    
    self.digit = 4;
    if(dis1num == 0){
        self.digit = 3;
        self.image_dis1.hidden = YES;
        if(dis2num == 0){
            self.digit = 2;
            self.image_dis2.hidden = YES;
            if(dis3num == 0){
                self.digit = 1;
                self.image_dis3.hidden = YES;
            }
        }
    }
    [self offsizeViewLeft];
}
- (void)fitToSizeRight{
    
    self.image_dis1.hidden = NO;
    self.image_dis2.hidden = NO;
    self.image_dis3.hidden = NO;
    self.frame = self.initFrame;
    
    int distance100 = self.distance*100;
    int dis1num = distance100/100000;
    distance100 = distance100 - dis1num*100000;
    int dis2num = distance100/10000;
    distance100 = distance100 - dis2num*10000;
    int dis3num = distance100/1000;
    distance100 = distance100 - dis3num*1000;
    int dis4num = distance100/100;
    distance100 = distance100 - dis4num*100;
    int dis5num = distance100/10;
    int dis6num = distance100%10;
    self.image_dis1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis1num]];
    self.image_dis2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis2num]];
    self.image_dis3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis3num]];
    self.image_dis4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis4num]];
    self.image_dis5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis5num]];
    self.image_dis6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i.png",self.color,dis6num]];
    image_dot.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_point.png",self.color]];
    
    
    self.digit = 4;
    if(dis1num == 0){
        self.digit = 3;
        self.image_dis1.hidden = YES;
        if(dis2num == 0){
            self.digit = 2;
            self.image_dis2.hidden = YES;
            if(dis3num == 0){
                self.digit = 1;
                self.image_dis3.hidden = YES;
            }
        }
    }
    [self offsizeViewRight];
}
- (void)offsizeView{
    if(self.digit == 4){
        self.frame = initFrame;
    }
    int offsizeNum = 4-self.digit;//一位数字要往左偏移1个
    int width = self.image_dis1.frame.size.width;
    CGRect newFrame = self.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left-width/2*offsizeNum, top);
    self.frame = newFrame;
}
- (void)offsizeViewLeft{
    if(self.digit == 4){
        self.frame = initFrame;
    }
    int offsizeNum = 4-self.digit;//一位数字要往左偏移1个
    int width = self.image_dis1.frame.size.width;
    CGRect newFrame = self.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left-width*offsizeNum, top);
    self.frame = newFrame;
}
- (void)offsizeViewRight{
    if(self.digit == 4){
        self.frame = initFrame;
    }
    int offsizeNum = 4-self.digit;
    int width = self.image_dis1.frame.size.width;
    CGRect newFrame = self.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left+width*offsizeNum, top);
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

//
//  CNTimeImageView.m
//  YaoPao
//
//  Created by zc on 14-9-2.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNTimeImageView.h"
#import "CNUtil.h"

@implementation CNTimeImageView
@synthesize image_time1;
@synthesize image_time2;
@synthesize image_time3;
@synthesize image_time4;
@synthesize image_time5;
@synthesize image_time6;
@synthesize image_colon1;
@synthesize image_colon2;
@synthesize initFrame;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.initFrame = frame;
        float image_height = frame.size.height;
        float image_width = image_height/160*100;
        float interval = image_width/2;
        float colon_width = image_width/100*60;
        self.image_time1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,image_width, image_height)];
        self.image_time1.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_time1];
        self.image_time2 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width, 0,image_width, image_height)];
        self.image_time2.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_time2];
        
        self.image_colon1 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*2+interval/2-colon_width/2, 0,colon_width, image_height)];
        self.image_colon1.image = [UIImage imageNamed:@"red_colon.png"];
        [self addSubview:image_colon1];
        
        self.image_time3 = [[UIImageView alloc]initWithFrame:CGRectMake(interval+image_width*2, 0,image_width, image_height)];
        self.image_time3.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_time3];
        self.image_time4 = [[UIImageView alloc]initWithFrame:CGRectMake(interval+image_width*3, 0,image_width, image_height)];
        self.image_time4.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_time4];
        
        self.image_colon2 = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*4+interval*3/2-colon_width/2, 0,colon_width, image_height)];
        self.image_colon2.image = [UIImage imageNamed:@"red_colon.png"];
        [self addSubview:image_colon2];
        
        self.image_time5 = [[UIImageView alloc]initWithFrame:CGRectMake(2*interval+image_width*4, 0,image_width, image_height)];
        self.image_time5.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_time5];
        self.image_time6 = [[UIImageView alloc]initWithFrame:CGRectMake(2*interval+image_width*5, 0,image_width, image_height)];
        self.image_time6.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_time6];
    }
    return self;
}
- (void)setTime:(int)time{
    _time = time;
}
- (void)setColor:(NSString *)color{
    _color = color;
}
- (void)fitToSize{
    
    self.image_time1.hidden = NO;
    self.image_time2.hidden = NO;
    self.image_colon1.hidden = NO;
    self.frame = self.initFrame;
    
    NSString* timeString = [CNUtil duringTimeStringFromSecond:self.time];
    unichar char1 = [timeString characterAtIndex:0];
    unichar char2 = [timeString characterAtIndex:1];
    unichar char3 = [timeString characterAtIndex:3];
    unichar char4 = [timeString characterAtIndex:4];
    unichar char5 = [timeString characterAtIndex:6];
    unichar char6 = [timeString characterAtIndex:7];
    //    NSLog(@"char1:%c,char2:%c,char3:%c,char4:%c,char5:%c,char6:%c",char1,char2,char3,char4,char5,char6);
    self.image_time1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char1]];
    self.image_time2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char2]];
    self.image_colon1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_colon.png",self.color]];
    self.image_time3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char3]];
    self.image_time4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char4]];
    self.image_colon2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_colon.png",self.color]];
    self.image_time5.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char5]];
    self.image_time6.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char6]];
    
    int hour = self.time/3600;
    if(hour == 0){//偏移
        self.image_time1.hidden = YES;
        self.image_time2.hidden = YES;
        self.image_colon1.hidden = YES;
        int width = self.image_time1.frame.size.width;
        CGRect newFrame = self.frame;
        int left = newFrame.origin.x;
        int top = newFrame.origin.y;
        newFrame.origin = CGPointMake(left-width*5.0/4.0, top);
        self.frame = newFrame;
    }
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

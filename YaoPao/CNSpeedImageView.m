//
//  CNSpeedImageView.m
//  YaoPao
//
//  Created by zc on 14-9-2.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNSpeedImageView.h"
#import "CNUtil.h"

@implementation CNSpeedImageView
@synthesize image_time1;
@synthesize image_time2;
@synthesize image_time3;
@synthesize image_time4;
@synthesize image_munite;
@synthesize image_second;
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
        
        self.image_munite = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*2+interval/2-colon_width/2, 0,colon_width, image_height)];
        self.image_munite.image = [UIImage imageNamed:@"red_minute.png"];
        [self addSubview:image_munite];
        
        self.image_time3 = [[UIImageView alloc]initWithFrame:CGRectMake(interval+image_width*2, 0,image_width, image_height)];
        self.image_time3.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_time3];
        self.image_time4 = [[UIImageView alloc]initWithFrame:CGRectMake(interval+image_width*3, 0,image_width, image_height)];
        self.image_time4.image = [UIImage imageNamed:@"red0.png"];
        [self addSubview:image_time4];
        
        self.image_second = [[UIImageView alloc]initWithFrame:CGRectMake(image_width*4+interval*3/2-colon_width/2, 0,colon_width, image_height)];
        self.image_second.image = [UIImage imageNamed:@"red_second"];
        [self addSubview:image_second];
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
    if(self.time > 59*60+59){
        self.time = 0;
    }
    NSString* timeString = [CNUtil pspeedStringFromSecond:self.time];
    unichar char1 = [timeString characterAtIndex:0];
    unichar char2 = [timeString characterAtIndex:1];
    unichar char3 = [timeString characterAtIndex:3];
    unichar char4 = [timeString characterAtIndex:4];
    self.image_time1.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char1]];
    self.image_time2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char2]];
    self.image_munite.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_minute.png",self.color]];
    self.image_time3.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char3]];
    self.image_time4.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%c.png",self.color,char4]];
    self.image_second.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_second.png",self.color]];
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

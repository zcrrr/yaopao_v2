//
//  CustomCalloutView.m
//  YaoPao
//
//  Created by 张驰 on 15/5/7.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CustomCalloutView.h"

@interface CustomCalloutView ()

@property (nonatomic, strong) UILabel *label_nickname;
@property (nonatomic, strong) UILabel *label_time;

@end

@implementation CustomCalloutView
@synthesize time;
@synthesize nickname;



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
    }
    return self;
}

- (void)setNickname:(NSString *)nickname1{
    self.label_nickname.text = nickname1;
}

- (void)setTime:(NSString *)time1{
    self.label_time.text = time1;
}

- (void)initSubViews
{
    UIImageView* imageview_bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 110, 65)];
    imageview_bg.image = [UIImage imageNamed:@"position_pop.png"];
    [self addSubview:imageview_bg];
    
    self.label_nickname = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 110, 20)];
    self.label_nickname.font = [UIFont boldSystemFontOfSize:15];
    self.label_nickname.textAlignment = NSTextAlignmentCenter;
    self.label_nickname.textColor = [UIColor blackColor];
    self.label_nickname.text = @"nickname";
    [self addSubview:self.label_nickname];
    
    // 添加副标题，即商户地址
    self.label_time = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, 110, 20)];
    self.label_time.font = [UIFont systemFontOfSize:10];
    self.label_time.textAlignment = NSTextAlignmentCenter;
    self.label_time.textColor = [UIColor blackColor];
    self.label_time.text = @"2015.4.9 13:23";
    [self addSubview:self.label_time];
}

@end

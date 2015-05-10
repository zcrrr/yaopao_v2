//
//  GroupLocationAnnotationView.m
//  YaoPao
//
//  Created by 张驰 on 15/5/7.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "GroupLocationAnnotationView.h"

@implementation GroupLocationAnnotationView
@synthesize calloutView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0, 0, 30.6, 41.2);
        UIImageView* image_back = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30.6, 41.2)];
        image_back.image = [UIImage imageNamed:@"position_bubble.png"];
        [self addSubview:image_back];
        self.imageview = [[UIImageView alloc]initWithFrame:CGRectMake(1.7,1.7, 27.2, 27.2)];
        self.imageview.layer.cornerRadius = self.imageview.bounds.size.width/2;
        self.imageview.layer.masksToBounds = YES;
        self.imageview.image = [UIImage imageNamed:@"avatar_default.png"];
        [self addSubview:self.imageview];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, 110, 65)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        
        self.calloutView.nickname = self.annotation.title;
        self.calloutView.time = self.annotation.subtitle;
        
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}
@end

//
//  CNMatchAvatarAnnotationView.m
//  YaoPao
//
//  Created by zc on 14-9-12.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNMatchAvatarAnnotationView.h"

@implementation CNMatchAvatarAnnotationView

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
        self.bounds = CGRectMake(0, 0, 45, 45);
        UIImageView* image_back = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 45, 45)];
        image_back.image = [UIImage imageNamed:@"avatar_pop.png"];
        [self addSubview:image_back];
        self.imageview = [[UIImageView alloc]initWithFrame:CGRectMake(7.5,5, 30, 30)];
        [self addSubview:self.imageview];
    }
    return self;
}
@end

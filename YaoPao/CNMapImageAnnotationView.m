//
//  CNMapImageAnnotationView.m
//  YaoPao
//
//  Created by zc on 14-9-1.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNMapImageAnnotationView.h"

@implementation CNMapImageAnnotationView
@synthesize imageview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (NSString*)type{
    return  self.type;
}
- (void)setType:(NSString *)type{
    if([type isEqualToString:@"start"]){
        self.imageview.image = [UIImage imageNamed:@"map_start.png"];
    }else{
        self.imageview.image = [UIImage imageNamed:@"map_end.png"];
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
#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0, 0, 20, 20);
        self.imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:self.imageview];
    }
    return self;
}

@end

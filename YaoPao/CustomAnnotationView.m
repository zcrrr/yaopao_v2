//
//  CustomAnnotationView.m
//  YaoPao
//
//  Created by zc on 14-8-31.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CNUtil.h"

@implementation CustomAnnotationView
@synthesize label_time;
@synthesize label_km;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (NSString*)paraminfo{
    return  self.paraminfo;
}
- (void)setParaminfo:(NSString *)paraminfo{
    NSArray* list = [paraminfo componentsSeparatedByString:@"_"];
    self.label_km.text = [NSString stringWithFormat:@"第%@公里",[list objectAtIndex:0]];
    self.label_time.text = [CNUtil pspeedStringFromSecond:[[list objectAtIndex:1] intValue]];
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
        self.bounds = CGRectMake(0, 0, 60, 45);
        UIImageView* image_back = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 45)];
        image_back.image = [UIImage imageNamed:@"map_pop.png"];
        
        [self addSubview:image_back];
        self.label_km = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 60, 15)];
        self.label_km.textAlignment = NSTextAlignmentCenter;
        self.label_km.font = [UIFont systemFontOfSize:12];
//        self.label_km.text = [NSString stringWithFormat:@"%@",[infolist objectAtIndex:0]];
        [self addSubview:self.label_km];
        
        self.label_time = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 60, 15)];
        self.label_time.textAlignment = NSTextAlignmentCenter;
        self.label_time.font = [UIFont systemFontOfSize:12];
//        self.label_time.text = [NSString stringWithFormat:@"%@",[infolist objectAtIndex:1]];
        [self addSubview:self.label_time];
    }
    return self;
}

@end

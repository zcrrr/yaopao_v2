//
//  CircleView.m
//  AssistUI
//
//  Created by 张驰 on 15/3/18.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView
@synthesize progress;


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect aRect= CGRectMake(2, 2, 176, 176);
    CGContextSetRGBStrokeColor(context, 48.0/255.0, 48.0/255.0, 48.0/255.0, 1.0);
    CGContextSetLineWidth(context, 3.0);
    CGContextAddEllipseInRect(context, aRect); //椭圆
    CGContextDrawPath(context, kCGPathStroke);
    
    NSLog(@"progress is %f",progress);
    CGContextSetRGBStrokeColor(context, 116.0/255.0,198.0/255.0,62.0/255.0,1.0);
    CGContextSetLineWidth(context, 3.0);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, 90, 90, 88, 0.5*M_PI, 0.5*M_PI+progress*2*M_PI, NO);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
}


@end

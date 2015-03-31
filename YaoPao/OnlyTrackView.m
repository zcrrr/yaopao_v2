//
//  OnlyTrackView.m
//  YaoPao
//
//  Created by 张驰 on 15/3/24.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "OnlyTrackView.h"

@implementation OnlyTrackView
@synthesize pointArray;
@synthesize color;

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(self.color == nil || [self.color isEqualToString:@"white"]){
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);//线条颜色
    }else if([self.color isEqualToString:@"black"]){
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);//线条颜色
    }else if([self.color isEqualToString:@"green"]){
        CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);//线条颜色
    }
    CGContextSetLineWidth(context, 3.0);
    CGPoint firstPoint = [[pointArray objectAtIndex:0]CGPointValue];
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    for(NSValue* pointvalue in pointArray){
        CGPoint point = [pointvalue CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
}


@end

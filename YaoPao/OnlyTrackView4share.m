//
//  OnlyTrackView4share.m
//  YaoPao
//
//  Created by 张驰 on 15/3/31.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "OnlyTrackView4share.h"

@implementation OnlyTrackView4share
@synthesize pointArray;

- (void)drawRect:(CGRect)rect {
    // Drawing code
    if(self.pointArray == nil){
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
//    int j = 0;
//    int i = 0;
//    int n = 0;
//    int pointCount = [self.pointArray count];
    CGContextSetRGBStrokeColor(context, 0, 0.5, 0, 1);//线条颜色
    CGContextSetLineWidth(context, 10);
    NSDictionary* firstPoint = [pointArray objectAtIndex:0];
    CGContextMoveToPoint(context, [[firstPoint objectForKey:@"x"]floatValue], [[firstPoint objectForKey:@"y"]floatValue]);
    for(NSDictionary* onePoint in pointArray){
        float x = [[onePoint objectForKey:@"x"]floatValue];
        float y = [[onePoint objectForKey:@"y"]floatValue];
        CGContextAddLineToPoint(context, x, y);
    }
    CGContextStrokePath(context);
    
//    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1);//线条颜色
//    CGContextSetLineWidth(context, 7.5);
//    CGContextMoveToPoint(context, [[firstPoint objectForKey:@"x"]floatValue], [[firstPoint objectForKey:@"y"]floatValue]);
//    for(NSDictionary* onePoint in pointArray){
//        float x = [[onePoint objectForKey:@"x"]floatValue];
//        float y = [[onePoint objectForKey:@"y"]floatValue];
//        CGContextAddLineToPoint(context, x, y);
//    }
//    CGContextStrokePath(context);
//    
//    
//    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);//线条颜色
//    CGContextSetLineWidth(context, 7.5);
//    int startIndex = 0;
//    int endIndex = 0;
//    for(i = 0;i<pointCount;i++){
//        NSDictionary* gpsPoint = [self.pointArray objectAtIndex:i];
//        int status_this = [[gpsPoint objectForKey:@"status"]intValue];
//        if(i==0){
//            startIndex = 0;
//            CGContextMoveToPoint(context, [[gpsPoint objectForKey:@"x"]floatValue], [[gpsPoint objectForKey:@"y"]floatValue]);
//        }else{
//            NSDictionary* lastPoint = [self.pointArray objectAtIndex:(i-1)];
//            int status_last = [[lastPoint objectForKey:@"status"]intValue];
//            if(status_this != status_last){
//                if(status_this == 1){//运动开始的序列
//                    startIndex = i;
//                    CGContextMoveToPoint(context, [[gpsPoint objectForKey:@"x"]floatValue], [[gpsPoint objectForKey:@"y"]floatValue]);
//                }else if(status_this == 2){//暂停开始的序列
//                    endIndex = i-1;
//                    if(endIndex-startIndex+1<2)continue;
//                    for(j=startIndex,n=0;j<=endIndex;j++,n++){
//                        NSDictionary* point = [self.pointArray objectAtIndex:j];
//                        int x = [[point objectForKey:@"x"]floatValue];
//                        int y = [[point objectForKey:@"y"]floatValue];
//                        CGContextAddLineToPoint(context, x, y);
//                    }
//                    CGContextStrokePath(context);
//                }
//            }else if(i == pointCount-1 && status_this == 1){//结束的一段
//                endIndex = i;
//                if(endIndex-startIndex+1<2)continue;
//                for(j=startIndex,n=0;j<=endIndex;j++,n++){
//                    NSDictionary* point = [self.pointArray objectAtIndex:j];
//                    int x = [[point objectForKey:@"x"]floatValue];
//                    int y = [[point objectForKey:@"y"]floatValue];
//                    CGContextAddLineToPoint(context, x, y);
//                }
//                CGContextStrokePath(context);
//            }
//        }
//    }
}

@end

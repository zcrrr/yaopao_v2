//
//  CNEncryption.h
//  YaoPao
//
//  Created by zc on 14-8-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CNEncryption : NSObject

+ (CLLocationCoordinate2D)encrypt:(CLLocationCoordinate2D)wgs84Point;
+ (double)Transform_yj5:(double)x :(double)y;
+ (double)yj_sin2:(double)x;

@end

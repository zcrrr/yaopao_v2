//
//  CNGoogleProjection.m
//  YaoPao
//
//  Created by zc on 14-8-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNGoogleProjection.h"
#import <CoreLocation/CoreLocation.h>
#define EarthRadius 6378137
#define MinLongitude -180
#define MaxLongitude 180
#define MinLatitude -85.05112878
#define MaxLatitude 85.05112878

@implementation CNGoogleProjection


- (double)getDistanceByLL:(CLLocationCoordinate2D)p1 :(CLLocationCoordinate2D)p2{
    double lon1 = [self getLoop:p1.longitude :MinLongitude :MaxLongitude];
    double lat1 = [self getRange:p1.latitude :MinLatitude :MaxLatitude];
    double lon2 = [self getLoop:p2.longitude :MinLongitude :MaxLongitude];
    double lat2 = [self getRange:p2.latitude :MinLatitude :MaxLatitude];
    lon1 = [self toRadians:lon1];
    lat1 = [self toRadians:lat1];
    lon2 = [self toRadians:lon2];
    lat2 = [self toRadians:lat2];
    return [self getDistance:lon1 :lon2 :lat1 :lat2];
}
- (double)getDistance:(double)radiansLon1 :(double)radiansLon2 :(double)radiansLat1 :(double)radiansLat2{
    return EarthRadius
    * acos((sin(radiansLat1) * sin(radiansLat2) + cos(radiansLat1)
                 * cos(radiansLat2)
                 * cos(radiansLon2 - radiansLon1)));
}
- (double)toRadians:(double)a{
    return M_PI*a/180;
}
- (double)getLoop:(double)n :(double)min :(double)max{
    double r = n;
    while (r > max) {
        r -= max - min;
    }
    while (r < min) {
        r += max - min;
    }
    return r;
}
- (double)getRange:(double)n :(double)min :(double)max{
    return MIN(MAX(n, min), max);
}

@end

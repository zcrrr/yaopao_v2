//
//  CNEncryption.m
//  YaoPao
//
//  Created by zc on 14-8-10.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNEncryption.h"
#import <CoreLocation/CoreLocation.h>

@implementation CNEncryption

#define CHINA_LON_LAT_PRECISION_FLOAT 3686400.0

+ (CLLocationCoordinate2D)encrypt:(CLLocationCoordinate2D) wgs84Point{
    CLLocationCoordinate2D china;
    
    double x_add;
    double y_add;
    double x_l;
    double y_l;
    
    x_l = (int) round(wgs84Point.longitude * CHINA_LON_LAT_PRECISION_FLOAT);
    x_l = x_l / CHINA_LON_LAT_PRECISION_FLOAT;
    y_l = (int) round(wgs84Point.latitude * CHINA_LON_LAT_PRECISION_FLOAT);
    y_l = y_l / CHINA_LON_LAT_PRECISION_FLOAT;
    
    if (x_l < 72.004 || x_l > 137.8347 || y_l < 0.8293 || y_l > 55.8271) {
        return china;
    }
    
    x_add = [CNEncryption Transform_yj5:x_l - 105 :y_l - 35];
    y_add = [CNEncryption Transform_yjy5:x_l - 105 :y_l - 35];
    x_l = (x_l + [CNEncryption Transform_jy5:y_l :x_add]) * CHINA_LON_LAT_PRECISION_FLOAT;
    y_l = (y_l + [CNEncryption Transform_jyj5:y_l :y_add])* CHINA_LON_LAT_PRECISION_FLOAT;
    
    if (x_l > 2147483647 || y_l > 2147483647) {
        return china;
    }
    
    china.longitude = x_l / CHINA_LON_LAT_PRECISION_FLOAT;
    china.latitude = y_l / CHINA_LON_LAT_PRECISION_FLOAT;
    return china;
}
+ (double)Transform_yj5:(double)x :(double)y{
    double tt;
    tt = 300 + 1 * x + 2 * y + 0.1 * x * x + 0.1 * x * y + 0.1
    * sqrt(sqrt(x * x));
    tt = tt
    + (20 * [self yj_sin2:(18.849555921538764 * x)] + 20 * [self yj_sin2:(6.283185307179588 * x)])
    * 0.6667;
    tt = tt
    + (20 * [self yj_sin2:(3.141592653589794 * x)] + 40 * [self yj_sin2:(1.047197551196598 * x)])
    * 0.6667;
    tt = tt
    + (150 * [self yj_sin2:(0.2617993877991495 * x)] + 300 * [self yj_sin2:(0.1047197551196598 * x)])
    * 0.6667;
    return tt;
}
+ (double)Transform_yjy5:(double)x : (double)y{
    double tt;
    tt = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y + 0.2
    * sqrt(sqrt(x * x));
    tt = tt
    + (20 * [self yj_sin2:(18.849555921538764 * x) ]+ 20 * [self yj_sin2:(6.283185307179588 * x)])
    * 0.6667;
    tt = tt
    + (20 * [self yj_sin2:(3.141592653589794 * y)] + 40 * [self yj_sin2:(1.047197551196598 * y)])
    * 0.6667;
    tt = tt
    + (160 * [self yj_sin2:(0.2617993877991495 * y)] + 320 * [self yj_sin2:(0.1047197551196598 * y)])
    * 0.6667;
    return tt;
}
+ (double)Transform_jy5:(double)x : (double)xx{
    double n;
    double a;
    double e;
    a = 6378245;
    e = 0.00669342;
    n = sqrt(1 - e * [self yj_sin2:(x * 0.0174532925199433)]
                  * [self yj_sin2:(x * 0.0174532925199433)]);
    n = (xx * 180) / (a / n * cos(x * 0.0174532925199433) * 3.1415926);
    return n;
}
+ (double)Transform_jyj5:(double)x : (double)yy{
    double m;
    double a;
    double e;
    double mm;
    a = 6378245;
    e = 0.00669342;
    mm = 1 - e * [self yj_sin2:(x * 0.0174532925199433)]
    * [self yj_sin2:(x * 0.0174532925199433)];
    m = (a * (1 - e)) / (mm * sqrt(mm));
    return (yy * 180) / (m * 3.1415926);
}
+ (double)yj_sin2:(double)x{
    double tt;
    double ss;
    int ff;
    double s2;
    int cc;
    ff = 0;
    if (x < 0) {
        x = -x;
        ff = 1;
    }
    cc = (int) (x / 6.28318530717959);
    tt = x - cc * 6.28318530717959;
    if (tt > 3.1415926535897932) {
        tt = tt - 3.1415926535897932;
        if (ff == 1)
            ff = 0;
        else if (ff == 0)
            ff = 1;
    }
    x = tt;
    ss = x;
    s2 = x;
    tt = tt * tt;
    s2 = s2 * tt;
    ss = ss - s2 * 0.166666666666667;
    s2 = s2 * tt;
    ss = ss + s2 * 8.33333333333333E-03;
    s2 = s2 * tt;
    ss = ss - s2 * 1.98412698412698E-04;
    s2 = s2 * tt;
    ss = ss + s2 * 2.75573192239859E-06;
    s2 = s2 * tt;
    ss = ss - s2 * 2.50521083854417E-08;
    if (ff == 1)
        ss = -ss;
    return ss;
}

@end

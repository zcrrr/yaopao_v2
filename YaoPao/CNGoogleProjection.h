//
//  CNGoogleProjection.h
//  YaoPao
//
//  Created by zc on 14-8-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CNGoogleProjection : NSObject

- (double)getDistanceByLL:(CLLocationCoordinate2D)p1 :(CLLocationCoordinate2D)p2;

@end

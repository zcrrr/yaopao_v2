//
//  CNProjectionFactory.m
//  YaoPao
//
//  Created by zc on 14-8-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNProjectionFactory.h"
#import "geos.h"
#import <CoreLocation/CoreLocation.h>
#import "CNGoogleProjection.h"

@implementation CNProjectionFactory

- (double)getLength:(LineString*)ls{
    double length = 0.0;
    CLLocationCoordinate2D llp1;
    CLLocationCoordinate2D llp2;
    int count = ls->getNumPoints();
    for (int i = 1; i < count; i++) {
        CoordinateSequence *cl = ls->getCoordinates();
        
        llp1 = CLLocationCoordinate2DMake(cl->getAt(i-1).y, cl->getAt(i-1).x);
        llp2 = CLLocationCoordinate2DMake(cl->getAt(i).y, cl->getAt(i).x);
        CNGoogleProjection* pj = [[CNGoogleProjection alloc]init];
        length += [pj getDistanceByLL:llp1 :llp2];
    }
    return length;
}

@end

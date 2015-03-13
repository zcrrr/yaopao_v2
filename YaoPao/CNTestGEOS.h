//
//  CNTestGEOS.h
//  YaoPao
//
//  Created by zc on 14-8-12.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "geos.h"
#include <list>
#include "DistanceOp.h"

@interface CNTestGEOS : NSObject
{
    GeometryFactory *gf;
    
    NSString* name;
    BOOL isLap;
    double claimedLength;
    
    LineString *srcLS;
    double actualLength;
    
    LineString *lsStartZone;
    Polygon *pgStartZone;
    
    std::list<LineString*> lsTakeOverZones;
    std::list<Polygon*> pgTakeOverZones;
    
    std::list<LineString*> lsTracks;
    std::list<Polygon*> pgTracks;
    
    
    
    
    int segmentIndex;
    
}
@property (strong, nonatomic) NSMutableArray* positionsOfTOZs;
@property (assign, nonatomic) double lon_after_convert;
@property (assign, nonatomic) double lat_after_convert;;

//从文件初始化
- (void)initFromFile:(NSString*)filename;
//是否在出发区
- (BOOL)isInTheStartZone:(double)lon :(double)lat;
//是否在交接区
- (int)isInTheTakeOverZones:(double)lon :(double)lat;
//是否在赛道上？
- (BOOL)isInTheTracks:(double)lon :(double)lat;
//将一个点匹配到赛道上
- (void)match:(double)lon :(double)lat :(int)direction;
//计算泡过的距离
- (double)runningLength;
- (double)returnClaimedLength;
- (double)getDistanceToNextTakeOverZone:(double)runningDistance;


+ (BOOL)isInChina:(double)lon :(double)lat;




@end

//
//  CNTestGEOS.m
//  YaoPao
//
//  Created by zc on 14-8-12.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNTestGEOS.h"
#import "geos.h"
#include "Point.h"
#include "BufferParameters.h"
#include "GeometryLocation.h"
#include "DistanceOp.h"
#import "CNProjectionFactory.h"

@implementation CNTestGEOS
@synthesize positionsOfTOZs;
@synthesize lat_after_convert;
@synthesize lon_after_convert;

+ (BOOL)isInChina:(double)lon :(double)lat{
    const std::string &wkt_zone = [@"POLYGON ((73.740192 53.545317, 135.039985 53.545317, 135.039985 18.156599, 73.740192 18.156599, 73.740192 53.545317))" UTF8String];
    Polygon *pgChinaZone = dynamic_cast<Polygon*>((new WKTReader())->read(wkt_zone));
    Coordinate c(lon, lat);
    geos::geom::Point *p = (new GeometryFactory())->createPoint(c);
    return pgChinaZone->contains(p);
    
}

- (void)initClass:(NSString*)name1 :(BOOL)isLap1 :(int)claimedLength1{
    gf = new GeometryFactory();
    name = name1;
    isLap = isLap1;
    claimedLength = claimedLength1;
    
    
    
    const std::string &wkt_srcLS = "aaa";
    srcLS = dynamic_cast<LineString*>((new WKTReader())->read(wkt_srcLS));
//    this.actualLength = pf.getLength(this.srcLS);
    
    const std::string &wkt_lsStartZone = "aaa";
    lsStartZone = dynamic_cast<LineString*>((new WKTReader())->read(wkt_lsStartZone));
    pgStartZone = [self buffer:lsStartZone :30 :8 :geos::operation::buffer::BufferParameters::CAP_ROUND];
    
}
- (Polygon*)buffer:(LineString*)llls :(double)distance :(int)quadrantSegments :(int)endCapStyle{
    return nil;
}

- (void)initFromFile:(NSString*)filename{
    self.positionsOfTOZs = [[NSMutableArray alloc]init];
    gf = new GeometryFactory();
    //读取文件
    NSError *error;
    NSString *textFileContents = [NSString
                                  stringWithContentsOfFile:[[NSBundle mainBundle]
                                                            pathForResource:filename
                                                            ofType:@"txt"]
                                  encoding:NSUTF8StringEncoding
                                  error: & error];
    // If there are no results, something went wrong
    if (textFileContents == nil) {
        // an error occurred
        NSLog(@"Error reading text file. %@", [error localizedFailureReason]);
    }
    NSArray *lines = [textFileContents componentsSeparatedByString:@"\n"];
    int i=0;
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    for(i=0;i<[lines count];i++){
        NSString* oneline = [lines objectAtIndex:i];
        oneline = [oneline stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        oneline = [oneline stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        NSArray* onePro = [oneline componentsSeparatedByString:@"="];
        [dic setObject:[onePro objectAtIndex:1] forKey:[onePro objectAtIndex:0]];
    }
    kApp.match_track_line = [dic objectForKey:@"match_track_line"];
    kApp.match_takeover_zone = [dic objectForKey:@"takeoverzone"];
    kApp.match_stringTrackZone = [dic objectForKey:@"stringTrackZone"];
    kApp.match_stringStartZone = [dic objectForKey:@"stringStartZone"];
    //初始化数据
    name = [dic objectForKey:@"name"];
    isLap = [[dic objectForKey:@"isLap"]boolValue];
    claimedLength = [[dic objectForKey:@"claimedLength"]doubleValue];
    
    const std::string &wkt_srcLS = [[dic objectForKey:@"srcLS"] UTF8String];
    srcLS = dynamic_cast<LineString*>((new WKTReader())->read(wkt_srcLS));
    
    actualLength = [[dic objectForKey:@"actualLength"]doubleValue];
    
    const std::string &wkt_lsStartZone = [[dic objectForKey:@"lsStartZone"] UTF8String];
    lsStartZone = dynamic_cast<LineString*>((new WKTReader())->read(wkt_lsStartZone));
    
    const std::string &wkt_pgStartZone = [[dic objectForKey:@"pgStartZone"] UTF8String];
    pgStartZone = dynamic_cast<Polygon*>((new WKTReader())->read(wkt_pgStartZone));

    NSArray* wkts;
    wkts = [[dic objectForKey:@"lsTakeOverZones"] componentsSeparatedByString:@":"];
    for(i=0;i<[wkts count];i++){
        const std::string &wkt = [[wkts objectAtIndex:i] UTF8String];
        LineString *line22 = dynamic_cast<LineString*>((new WKTReader())->read(wkt));
        lsTakeOverZones.push_back(line22);
    }
    wkts = [[dic objectForKey:@"pgTakeOverZones"] componentsSeparatedByString:@":"];
    for(i=0;i<[wkts count];i++){
        const std::string &wkt = [[wkts objectAtIndex:i] UTF8String];
        Polygon *polygon = dynamic_cast<Polygon*>((new WKTReader())->read(wkt));
        pgTakeOverZones.push_back(polygon);
    }
    wkts = [[dic objectForKey:@"positionsOfTOZs"] componentsSeparatedByString:@":"];
    for(i=0;i<[wkts count];i++){
        [self.positionsOfTOZs addObject:[wkts objectAtIndex:i]];
    }
    wkts = [[dic objectForKey:@"lsTracks"] componentsSeparatedByString:@":"];
    for(i=0;i<[wkts count];i++){
        const std::string &wkt = [[wkts objectAtIndex:i] UTF8String];
        LineString *line = dynamic_cast<LineString*>((new WKTReader())->read(wkt));
        lsTracks.push_back(line);
    }
    wkts = [[dic objectForKey:@"pgTracks"] componentsSeparatedByString:@":"];
    for(i=0;i<[wkts count];i++){
        const std::string &wkt = [[wkts objectAtIndex:i] UTF8String];
        Polygon *polygon = dynamic_cast<Polygon*>((new WKTReader())->read(wkt));
        pgTracks.push_back(polygon);
    }
}
//是否在出发区
- (BOOL)isInTheStartZone:(double)lon :(double)lat{
    Coordinate c(lon, lat);
	geos::geom::Point *p = gf->createPoint(c);
    return pgStartZone->contains(p);
}
//是否在交接区
- (int)isInTheTakeOverZones:(double)lon :(double)lat{
    Coordinate c(lon, lat);
	geos::geom::Point *p = gf->createPoint(c);
    std::list<Polygon*>::iterator it;
    int i = 0;
    for (it = pgTakeOverZones.begin();it != pgTakeOverZones.end(); i++,it++) {
        if ((*it)->contains(p))
            return i;
    }
    return -1;
}
//是否在赛道上？
- (BOOL)isInTheTracks:(double)lon :(double)lat{
    Coordinate c(lon, lat);
	geos::geom::Point *p = gf->createPoint(c);
    std::list<Polygon*>::iterator it;
    int i = 0;
    for (i = 0,it = pgTakeOverZones.begin();it != pgTakeOverZones.end(); i++,it++) {
        if ((*it)->contains(p))
            return YES;
    }
    for (i = 0,it = pgTracks.begin();it != pgTracks.end(); i++,it++) {
        if ((*it)->contains(p))
            return YES;
    }
    return NO;
}
//找到GPS在赛道上的匹配点后，计算跑过的距离
- (double)runningLength{
    if (lon_after_convert == srcLS->getCoordinateN(0).x
        && lat_after_convert == srcLS->getCoordinateN(0).y)
        return 0;
    
    CoordinateSequence *cl = new CoordinateArraySequence();
    for (int i = 0; i <= segmentIndex; i++) {
        cl->add(srcLS->getCoordinateN(i));
    }
    Coordinate coo(lon_after_convert,lat_after_convert);
    cl->add(coo);
    LineString *lsRunning = gf->createLineString(cl);
    CNProjectionFactory* pf = [[CNProjectionFactory alloc]init];
    double runningLength = [pf getLength:lsRunning] * claimedLength / actualLength;
    NSLog(@"runningLength is %f",runningLength);
    return runningLength;
}

- (void)match:(double)lon :(double)lat :(int)direction{
    Coordinate c(lon, lat);
	geos::geom::Point *p = gf->createPoint(c);
    geos::operation::distance::DistanceOp dop(srcLS,p);
    geos::operation::distance::GeometryLocation* gl = dop.nearestPoints_byzc();
    segmentIndex = gl->getSegmentIndex();
    lon_after_convert = gl->getCoordinate().x;
    lat_after_convert = gl->getCoordinate().y;
    NSLog(@"segmentIndex is %i",segmentIndex);
    NSLog(@"%f,%f",lon_after_convert,lat_after_convert);
}
- (double)returnClaimedLength{
    return claimedLength;
}
- (double)getDistanceToNextTakeOverZone:(double)runningDistance{
    for (int i = 0; i < [self.positionsOfTOZs count]; i++) {
        double start_distance = [[self.positionsOfTOZs objectAtIndex:i]doubleValue];
        if (runningDistance < start_distance) {
            return start_distance - runningDistance;
        }
    }
    if (isLap) {
        return claimedLength - runningDistance + [[self.positionsOfTOZs objectAtIndex:0]doubleValue];
    } else {
        return claimedLength - runningDistance; // 不是环形赛道的话，给个离终点的距离吧。
    }
}


@end

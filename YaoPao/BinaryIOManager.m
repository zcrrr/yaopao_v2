//
//  BinaryIOManager.m
//  YaoPao
//
//  Created by zc on 14-12-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "BinaryIOManager.h"
#import "CNRunManager.h"
#import "BinaryIO.h"
#import "CNGPSPoint.h"
#import "OneKMInfo.h"
#import "OneMileInfo.h"
#import "OneMinuteInfo.h"

@implementation BinaryIOManager

- (void)writeBinary:(NSString*)filename{
    int version = 1;
    int i = 0;
    int pointCount = (int)[kApp.runManager.GPSList count];
    int kmCount = (int)[kApp.runManager.dataKm count];
    int mileCount = (int)[kApp.runManager.dataMile count];
    int minCount = (int)[kApp.runManager.dataMin count];
    
    //元数据
    //赋值
    ST_METADATA stTest;
    stTest.blank = 0;
    stTest.minuteCount = minCount;
    stTest.mileCount = mileCount;
    stTest.kmCount = kmCount;
    stTest.altRed = (int)(kApp.runManager.altitudeReduce*10+0.5) ;
    stTest.altAdd = (int)(kApp.runManager.altitudeAdd*10+0.5) ;
    stTest.calorie = 0 ;
    stTest.step = 0 ;
    stTest.during = [kApp.runManager during] ;
    stTest.distance =  kApp.runManager.distance;
    stTest.startTime =  ((CNGPSPoint*)[kApp.runManager.GPSList firstObject]).time;
    stTest.coor = 1 ;
    stTest.pointCount = pointCount ;
    stTest.version = version ;
    //得到数组
    int byteCount1 = sizeof(ST_METADATA);
    int arrayCount1 = 1;
    int size1 = byteCount1*arrayCount1;
    char pBuf1[size1];
    memcpy(pBuf1,&stTest,size1);
    
    //gps数组
    ST_GPSDATA gpsArray[pointCount];
    for(i = 0;i<pointCount;i++){
        CNGPSPoint* point = [kApp.runManager.GPSList objectAtIndex:(pointCount-1-i)];
        gpsArray[i].lon = (int) ((point.lon + 180) * 1000000);
        gpsArray[i].lat = (int) ((point.lat + 90) * 1000000);
        gpsArray[i].status = point.status;
        int timeIncrement = 0;
        if (i < pointCount-1) {
            CNGPSPoint *lastPoint = [kApp.runManager.GPSList objectAtIndex:(pointCount-1-i-1)];
            timeIncrement = (int) (point.time - lastPoint.time);
        }
        gpsArray[i].timeAdd = timeIncrement;
        gpsArray[i].course = point.course;
        gpsArray[i].altitude = (int)((point.altitude+1000)*10+0.5);
        gpsArray[i].speed = point.speed;
        gpsArray[i].blank = 0;
    }
    int byteCount2 = sizeof(ST_GPSDATA);
    int arrayCount2 = pointCount;
    int size2 = byteCount2*arrayCount2;
    char pBuf2[size2];
    memcpy(pBuf2,gpsArray,size2);
    
    
    //km数组
    ST_KMDATA kmArray[kmCount];
    for(i = 0;i<kmCount;i++){
        OneKMInfo* onekm = [kApp.runManager.dataKm objectAtIndex:(kmCount-1-i)];
        kmArray[i].lon = (int) ((onekm.lon + 180) * 1000000);
        kmArray[i].lat = (int) ((onekm.lat + 90) * 1000000);
        kmArray[i].distance = onekm.distance;
        kmArray[i].time = onekm.during;
        kmArray[i].step = 0;
        kmArray[i].calorie = 0;
        kmArray[i].altAdd = (int)(onekm.altitudeAdd*10+0.5);
        kmArray[i].altRed =  (int)(onekm.altitudeReduce*10+0.5);
        kmArray[i].blank = 0;
    }
    int byteCount3 = sizeof(ST_KMDATA);
    int arrayCount3 = kmCount;
    int size3 = byteCount3*arrayCount3;
    char pBuf3[size3];
    memcpy(pBuf3,kmArray,size3);
    
    //mile数组
    ST_MILEDATA mileArray[mileCount];
    for(i = 0;i<mileCount;i++){
        OneMileInfo* oneMile = [kApp.runManager.dataMile objectAtIndex:(mileCount-1-i)];
        mileArray[i].lon = (int) ((oneMile.lon + 180) * 1000000);
        mileArray[i].lat = (int) ((oneMile.lat + 90) * 1000000);
        mileArray[i].distance = oneMile.distance;
        mileArray[i].time = oneMile.during;
        mileArray[i].step = 0;
        mileArray[i].calorie = 0;
        mileArray[i].altAdd = (int)(oneMile.altitudeAdd*10+0.5);
        mileArray[i].altRed =  (int)(oneMile.altitudeReduce*10+0.5);
        mileArray[i].blank = 0;
    }
    int byteCount4 = sizeof(ST_MILEDATA);
    int arrayCount4 = mileCount;
    int size4 = byteCount4*arrayCount4;
    char pBuf4[size4];
    memcpy(pBuf4,mileArray,size4);
    
    //minute数组
    ST_MINUTEDATA minArray[minCount];
    for(i = 0;i<minCount;i++){
        OneMinuteInfo* oneMin = [kApp.runManager.dataMin objectAtIndex:(minCount-1-i)];
        minArray[i].lon = (int) ((oneMin.lon + 180) * 1000000);
        minArray[i].lat = (int) ((oneMin.lat + 90) * 1000000);
        minArray[i].distance = oneMin.distance;
        minArray[i].time = oneMin.during;
        minArray[i].step = 0;
        minArray[i].calorie = 0;
        minArray[i].altAdd = (int)(oneMin.altitudeAdd*10+0.5);
        minArray[i].altRed =  (int)(oneMin.altitudeReduce*10+0.5);
        minArray[i].blank = 0;
    }
    int byteCount5 = sizeof(ST_MINUTEDATA);
    int arrayCount5 = minCount;
    int size5 = byteCount5*arrayCount5;
    char pBuf5[size5];
    memcpy(pBuf5,minArray,size5);
    int size = size1 + size2 + size3 + size4 + size5;

    char pBuf[size];
    int j = 0;
    for( i = 0 ; i < size5 ; i ++,j++){
        pBuf[j] = pBuf5[i];
    }
    for( i = 0 ; i < size4 ; i ++,j++){
        pBuf[j] = pBuf4[i];
    }
    for( i = 0 ; i < size3 ; i ++,j++){
        pBuf[j] = pBuf3[i];
    }
    for( i = 0 ; i < size2 ; i ++,j++){
        pBuf[j] = pBuf2[i];
    }
    for( i = 0 ; i < size1 ; i ++,j++){
        pBuf[j] = pBuf1[i];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [documentsDirectory stringByAppendingPathComponent:filename];
    const char * str =[file UTF8String];
    writeBinaryFile(str,pBuf,size);
}
- (void)readBinary:(NSString*)filename :(int)gpsCount :(int)kmCount :(int)mileCount :(int)minCount{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [documentsDirectory stringByAppendingPathComponent:filename];
    const char * str =[file UTF8String];
    
    int size1 = sizeof(ST_METADATA);
    
    int byteCount2 = sizeof(ST_GPSDATA);
    int size2 = byteCount2*gpsCount;
    
    int byteCount3 = sizeof(ST_KMDATA);
    int size3 = byteCount3*kmCount;
    
    int byteCount4 = sizeof(ST_MILEDATA);
    int size4 = byteCount4*mileCount;
    
    int byteCount5 = sizeof(ST_MINUTEDATA);
    int size5 = byteCount5*minCount;

    int size = size1 + size2 + size3 + size4 + size5;
    char pBuf[size];
    readBinaryFile(str, pBuf, size);
    
    char pBuf5[size5];
    char pBuf4[size4];
    char pBuf3[size3];
    char pBuf2[size2];
    char pBuf1[size1];
    
    int i = 0,j = 0;
    for( i = 0 ; i < size5 ; i ++,j++){
        pBuf5[i] = pBuf[j];
    }
    for( i = 0 ; i < size4 ; i ++,j++){
        pBuf4[i] = pBuf[j];
    }
    for( i = 0 ; i < size3 ; i ++,j++){
        pBuf3[i] = pBuf[j];
    }
    for( i = 0 ; i < size2 ; i ++,j++){
        pBuf2[i] = pBuf[j];
    }
    for( i = 0 ; i < size1 ; i ++,j++){
        pBuf1[i] = pBuf[j];
    }
    
    
    kApp.runManager = [[CNRunManager alloc]initData];
    long long startTimeStamp = 0;
    long long lastTimeStamp = 0;
    ST_METADATA stTest;
    memcpy(&stTest,pBuf1,size1);
    if(stTest.version == 1){//解析版本1
        startTimeStamp = stTest.startTime;
        
        kApp.runManager.distance = stTest.distance;
        kApp.runManager.altitudeAdd = stTest.altAdd;
        kApp.runManager.altitudeReduce = stTest.altRed;
        
        ST_GPSDATA gpsArray[gpsCount];
        memcpy(gpsArray,pBuf2,size2);
        for(i=0;i<gpsCount;i++){
            ST_GPSDATA gps = gpsArray[gpsCount-i-1];
            
            double lon = gps.lon/1000000.0-180;
            double lat = gps.lat/1000000.0-90;
            int status = gps.status;
            //计算下时间
            long long timeStamp = 0;
            if(i == 0){//第一个点
                timeStamp = startTimeStamp + gps.timeAdd;
            }else{
                timeStamp = lastTimeStamp + gps.timeAdd;
            }
            lastTimeStamp = timeStamp;
            int dir = gps.course;
            double alt = gps.altitude/10.0-1000;
            int speed = gps.speed;
            CNGPSPoint* point = [[CNGPSPoint alloc]initWithLon:lon andLat:lat andStatus:status andTime:timeStamp andCourse:dir andAltitude:alt andSpeed:speed];
            [kApp.runManager.GPSList addObject:point];
            
        }
        
        ST_KMDATA kmArray[kmCount];
        memcpy(kmArray,pBuf3,size3);
        for(i=0;i<kmCount;i++){
            ST_KMDATA oneKm = kmArray[kmCount-i-1];
            
            double lon = oneKm.lon/1000000.0-180;
            double lat = oneKm.lat/1000000.0-90;
            int distance = oneKm.distance;//距离
            int time = oneKm.time;//时间
            double altitudeAdd = oneKm.altAdd/10.0;
            double altitudeReduce = oneKm.altRed/10.0;
            OneKMInfo* oneKmInfo = [[OneKMInfo alloc]initWithNumber:(i+1) andLon:lon andLat:lat andDisTance:distance andDuring:time andAltitudeAdd:altitudeAdd andAltitudeReduce:altitudeReduce];
            [kApp.runManager.dataKm addObject:oneKmInfo];
        }
        
        ST_MILEDATA mileArray[mileCount];
        memcpy(mileArray,pBuf4,size4);
        for(i=0;i<mileCount;i++){
            ST_MILEDATA oneMile = mileArray[mileCount-i-1];
            double lon = oneMile.lon/1000000.0-180;
            double lat = oneMile.lat/1000000.0-90;
            int distance = oneMile.distance;//距离
            int time = oneMile.time;//时间
            double altitudeAdd = oneMile.altAdd/10.0;
            double altitudeReduce = oneMile.altRed/10.0;
            OneMileInfo* oneMileInfo = [[OneMileInfo alloc]initWithNumber:(i+1) andLon:lon andLat:lat andDisTance:distance andDuring:time andAltitudeAdd:altitudeAdd andAltitudeReduce:altitudeReduce];
            [kApp.runManager.dataMile addObject:oneMileInfo];
        }
        
        ST_MINUTEDATA minArray[minCount];
        memcpy(minArray,pBuf5,size5);
        for(i=0;i<minCount;i++){
            ST_MINUTEDATA oneMin = minArray[minCount-i-1];
            double lon = oneMin.lon/1000000.0-180;
            double lat = oneMin.lat/1000000.0-90;
            int distance = oneMin.distance;//距离
            int time = oneMin.time;//时间
            double altitudeAdd = oneMin.altAdd/10.0;
            double altitudeReduce = oneMin.altRed/10.0;
            OneMinuteInfo* oneMinInfo = [[OneMinuteInfo alloc]initWithNumber:(i+1) andLon:lon andLat:lat andDisTance:distance andDuring:time andAltitudeAdd:altitudeAdd andAltitudeReduce:altitudeReduce];
            [kApp.runManager.dataMin addObject:oneMinInfo];
        }
    }
}

@end

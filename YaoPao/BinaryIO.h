//
//  BinaryIO.h
//  YaoPao
//
//  Created by zc on 14-12-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#ifndef __YaoPao__BinaryIO__
#define __YaoPao__BinaryIO__

#include <stdio.h>
#pragma pack(1)
typedef struct metaData {//192位 24
    //从上往下依次是低位到高位
    unsigned int blank:6;
    unsigned int minuteCount:14;
    unsigned int mileCount:10;
    unsigned int kmCount:10;
    unsigned int altRed:18;
    unsigned int altAdd:18;
    unsigned int calorie:17;
    unsigned int step:20;
    unsigned int during:29;
    unsigned int distance:20;
    unsigned long long startTime:42;
    unsigned int coor:2;
    unsigned int pointCount:18;
    unsigned int version:8;
} ST_METADATA;

typedef struct gpsData {//120位 15
    unsigned int blank:4;
    unsigned int speed:8;
    unsigned int altitude:17;
    unsigned int course:9;
    unsigned int timeAdd:21;
    unsigned int status:4;
    unsigned int lat:28;
    unsigned int lon:29;
} ST_GPSDATA;

typedef struct kmData {//144位 18
    unsigned int blank:4;
    unsigned int altRed:12;
    unsigned int altAdd:12;
    unsigned int calorie:10;
    unsigned int step:13;
    unsigned int time:25;
    unsigned int distance:11;
    unsigned int lat:28;
    unsigned int lon:29;
} ST_KMDATA;

typedef struct mileData {//144位 18
    unsigned int blank:4;
    unsigned int altRed:12;
    unsigned int altAdd:12;
    unsigned int calorie:10;
    unsigned int step:13;
    unsigned int time:25;
    unsigned int distance:11;
    unsigned int lat:28;
    unsigned int lon:29;
} ST_MILEDATA;

typedef struct minuteData {//128位 16
    unsigned int blank:4;
    unsigned int altRed:10;
    unsigned int altAdd:10;
    unsigned int calorie:8;
    unsigned int step:10;
    unsigned int time:17;
    unsigned int distance:12;
    unsigned int lat:28;
    unsigned int lon:29;
} ST_MINUTEDATA;

#pragma pack()

void writeBinaryFile(const char *str,char* pBuf,int count);

void readBinaryFile(const char *str,char* pBuf, int count);



#endif /* defined(__YaoPao__BinaryIO__) */

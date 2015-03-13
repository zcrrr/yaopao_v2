//
//  BinaryIO.c
//  YaoPao
//
//  Created by zc on 14-12-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#include "BinaryIO.h"
/*
 注意要有4次颠倒,因为c都是先写低位后写高位
 1.结构体定义倒着定义
 2.数组赋值倒着赋值
 3.合并数组先倒着合并
 4.最后数组倒序写入
 */



//------------------write--------------------

void writeBinary_minData(const char *str,ST_MINUTEDATA minArray[],int count){
    int byteSize = sizeof(ST_MINUTEDATA);
    int totolBytes = byteSize*count;
    char pBuf[totolBytes];
    memcpy(pBuf,minArray,totolBytes);
    char pBuf_invert[totolBytes];
    for(int i=0;i<totolBytes;i++){
        pBuf_invert[i] = pBuf[totolBytes-1-i];
    }
    FILE* outfile;
    outfile = fopen(str, "wb");
    fwrite(pBuf_invert,byteSize,count,outfile);
    fclose(outfile);
}
void writeBinaryFile(const char *str,char* pBuf,int count){
    char pBuf_invert[count];
    for(int i=0;i<count;i++){
        pBuf_invert[i] = pBuf[count-1-i];
    }
    FILE* outfile;
    outfile = fopen(str, "wb");
    fwrite(pBuf_invert,count,1,outfile);
    fclose(outfile);
}



//------------------read--------------------
void readBinaryFile(const char *str,char* pBuf, int count){
    FILE* infile;
    infile = fopen(str, "r");
    char pBuf_invert[count];
    fread(pBuf_invert, count, 1, infile);
    fclose(infile);
    for(int i=0;i<count;i++){
        pBuf[i] = pBuf_invert[count-1-i];
    }
}

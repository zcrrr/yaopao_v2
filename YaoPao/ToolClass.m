//
//  ToolClass.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/1.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "ToolClass.h"

@implementation ToolClass


+(NSString*)getDocument:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *document = [paths objectAtIndex:0];
    NSString *path = [document stringByAppendingPathComponent:fileName];
    return path;
}

+ (void)saveToPlist:(NSString *)fileName :(id)arrayOrDic{
    NSString* filePath = [ToolClass getDocument:fileName];
    [arrayOrDic writeToFile:filePath atomically:YES];
}

@end

//
//  CNPersistenceHandler.m
//  YaoPao
//
//  Created by zc on 14-7-29.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNPersistenceHandler.h"

@implementation CNPersistenceHandler

+(NSString*)getDocument:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *document = [paths objectAtIndex:0];
	NSString *path = [document stringByAppendingPathComponent:fileName];
	return path;
}

+ (void)saveToPlist:(NSString *)fileName :(id)arrayOrDic{
    NSString* filePath = [CNPersistenceHandler getDocument:fileName];
    [arrayOrDic writeToFile:filePath atomically:YES];
}
+ (BOOL)DeleteSingleFile:(NSString*)filePath{
    NSError *err = nil;
    
    if (nil == filePath) {
        return NO;
    }
    
    NSFileManager *appFileManager = [NSFileManager defaultManager];
    
    if (![appFileManager fileExistsAtPath:filePath]) {
        return YES;
    }
    
    if (![appFileManager isDeletableFileAtPath:filePath]) {
        return NO;
    }
    
    return [appFileManager removeItemAtPath:filePath error:&err];
}

@end

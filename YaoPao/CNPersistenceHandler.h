//
//  CNPersistenceHandler.h
//  YaoPao
//
//  Created by zc on 14-7-29.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNPersistenceHandler : NSObject


//获取plist path
+ (NSString *)getDocument:(NSString *)fileName;
//存储到plist
+ (void)saveToPlist:(NSString *)fileName :(id)arrayOrDic;

+ (BOOL)DeleteSingleFile:(NSString*)filePath;


@end

//
//  ToolClass.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/1.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolClass : NSObject

//获取plist path
+ (NSString *)getDocument:(NSString *)fileName;
//存储到plist
+ (void)saveToPlist:(NSString *)fileName :(id)arrayOrDic;

@end

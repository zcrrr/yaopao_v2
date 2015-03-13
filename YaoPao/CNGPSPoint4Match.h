//
//  CNGPSPoint4Match.h
//  YaoPao
//
//  Created by zc on 14-8-25.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNGPSPoint4Match : NSObject


@property (assign, nonatomic) double lon;
@property (assign, nonatomic) double lat;
@property (assign, nonatomic) long long time;
@property (assign, nonatomic) int course;
@property (assign, nonatomic) int isInTrack;
@end

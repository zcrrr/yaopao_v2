//
//  BinaryIOManager.h
//  YaoPao
//
//  Created by zc on 14-12-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BinaryIOManager : NSObject

- (void)writeBinary:(NSString*)filename;

- (void)readBinary:(NSString*)filename :(int)gpsCount :(int)kmCount :(int)mileCount :(int)minCount;

@end

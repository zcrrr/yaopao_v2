//
//  CNProjectionFactory.h
//  YaoPao
//
//  Created by zc on 14-8-20.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "geos.h"

@interface CNProjectionFactory : NSObject

- (double)getLength:(LineString*)ls;

@end

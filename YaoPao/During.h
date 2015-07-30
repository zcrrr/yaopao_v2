//
//  During.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/4.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface During : NSObject
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) NSInteger anchor;
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) NSInteger fontsize;
@end

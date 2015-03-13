//
//  CNMatchCountDownViewController.h
//  YaoPao
//
//  Created by zc on 14-8-17.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNNumImageView;

@interface CNMatchCountDownViewController : UIViewController
@property (strong, nonatomic) CNNumImageView* niv;
@property (assign, nonatomic) int startSecond;
@property (strong ,nonatomic) NSTimer* timer_countdown;

@property (strong, nonatomic) IBOutlet UILabel *label_isInStart;

@end

//
//  CountDownViewController.h
//  AssistUI
//
//  Created by 张驰 on 15/3/14.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountDownViewController : UIViewController
@property (strong, nonatomic) NSTimer* timer_countdown;
@property (assign, nonatomic) int count;
- (IBAction)view_touched:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label_num;

@end

//
//  AboutViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/3/24.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController
@property (assign, nonatomic) int count;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button_debug;

@end

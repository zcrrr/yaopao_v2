//
//  CNWarningBackGroundViewController.h
//  YaoPao
//
//  Created by zc on 14-9-1.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNWarningBackGroundViewController : UIViewController
- (IBAction)button_help_clicked:(id)sender;
- (IBAction)button_back_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

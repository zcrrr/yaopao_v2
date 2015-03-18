//
//  StartRunViewController.h
//  AssistUI
//
//  Created by 张驰 on 15/3/13.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartRunViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *label_target;
@property (weak, nonatomic) IBOutlet UILabel *label_type;
@property (weak, nonatomic) IBOutlet UIView *view_target;
@property (weak, nonatomic) IBOutlet UIView *view_type;
- (IBAction)button_clicked:(id)sender;

@end

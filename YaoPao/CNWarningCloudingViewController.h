//
//  CNWarningCloudingViewController.h
//  YaoPao
//
//  Created by zc on 15-1-26.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNWarningCloudingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *label_step;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

- (IBAction)button_back_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_pop;


@end

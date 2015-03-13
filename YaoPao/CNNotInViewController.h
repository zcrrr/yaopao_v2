//
//  CNNotInViewController.h
//  YaoPao
//
//  Created by zc on 14-9-6.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNNotInViewController : UIViewController

- (IBAction)button_back_clicked:(id)sender;
@property (strong, nonatomic) NSTimer* checkInTakeOver;
@property (strong, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (strong, nonatomic) IBOutlet UILabel *label_uname;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

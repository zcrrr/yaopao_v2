//
//  CNNotRunTransmitRelayViewController.h
//  YaoPao
//
//  Created by zc on 14-9-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"

@interface CNNotRunTransmitRelayViewController : UIViewController<transmitRelayDelegate>
@property (strong, nonatomic) NSTimer* timer_transmit;
@property (strong, nonatomic) IBOutlet UIImageView *image_myavatar;
@property (strong, nonatomic) IBOutlet UILabel *label_name;
@property (strong, nonatomic) IBOutlet UIView *view_back;
@property (strong, nonatomic) IBOutlet UIView *view_run_user;
@property (strong, nonatomic) IBOutlet UIImageView *image_run_user;
@property (strong, nonatomic) IBOutlet UILabel *lable_run_user;
@property (strong, nonatomic) NSString* imagePath_runner;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
@property (strong, nonatomic) IBOutlet UIView *view_cartoon1;
@property (strong, nonatomic) IBOutlet UIView *view_cartoon2;
- (IBAction)button_back_clicked:(id)sender;

@end

//
//  CNNotInTakeOverViewController.h
//  YaoPao
//
//  Created by zc on 14-9-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"

@interface CNNotInTakeOverViewController : UIViewController<UIActionSheetDelegate,endMatchDelegate,UIAlertViewDelegate>
- (IBAction)button_back_clicked:(id)sender;
- (IBAction)button_finish_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageview_avatar;
@property (strong, nonatomic) IBOutlet UILabel *label_uname;
@property (strong, nonatomic) NSTimer* checkInTakeOver;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

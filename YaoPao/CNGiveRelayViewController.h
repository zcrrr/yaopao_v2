//
//  CNGiveRelayViewController.h
//  YaoPao
//
//  Created by zc on 14-8-26.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNNetworkHandler.h"

@interface CNGiveRelayViewController : UIViewController<UIAlertViewDelegate,transmitRelayDelegate,confirmTransmitDelegate,UIActionSheetDelegate,endMatchDelegate,cancelTransmitDelegate>
@property (strong ,nonatomic) NSString* joinid;
@property (strong ,nonatomic) NSString* joinid1;
@property (strong ,nonatomic) NSString* joinid2;
@property (strong ,nonatomic) NSString* joinid3;
@property (strong ,nonatomic) NSString* avatarurl1;
@property (strong ,nonatomic) NSString* avatarurl2;
@property (strong ,nonatomic) NSString* avatarurl3;
@property (strong, nonatomic) IBOutlet UILabel *label_back;
@property (strong, nonatomic) IBOutlet UILabel *label_finish;
@property (strong, nonatomic) IBOutlet UIImageView *image_me;
@property (strong, nonatomic) IBOutlet UILabel *label_myname;
- (IBAction)button_back_clicked:(id)sender;

- (IBAction)button_finish_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *view_user2;
@property (strong, nonatomic) IBOutlet UIView *view_user1;
@property (strong, nonatomic) IBOutlet UIView *view_user3;
- (IBAction)button_user_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_user2;
@property (strong, nonatomic) IBOutlet UIButton *button_user1;
@property (strong, nonatomic) IBOutlet UIButton *button_user3;
@property (strong, nonatomic) IBOutlet UILabel *label_user2;
@property (strong, nonatomic) IBOutlet UILabel *label_user1;
@property (strong, nonatomic) IBOutlet UILabel *label_user3;
@property (strong, nonatomic) IBOutlet UIView *view_back;
@property (strong, nonatomic) IBOutlet UIView *view_finish;
@property (strong, nonatomic) NSTimer* timer_look_submit;
@property (strong, nonatomic) IBOutlet UILabel *label_test;
@property (strong, nonatomic) IBOutlet UIImageView *imageview_relay;
@property (strong, nonatomic) IBOutlet UIImageView *image_gps;
@property (strong, nonatomic) IBOutlet UIView *view_cartoon1;
@property (strong, nonatomic) IBOutlet UIView *view_cartoon2;

@end

/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
#import "FirstLevelViewController.h"
#import "EMSDKFull.h"
#import "FriendsHandler.h"

@interface ChatListViewController : FirstLevelViewController<requestFriendsDelegate,UIWebViewDelegate>

@property (assign, nonatomic) int selectTab;
@property (strong, nonatomic) UIButton * button_myGroup;
@property (strong, nonatomic) UIButton * button_otherGroup;
@property (strong, nonatomic) UIView* view_line_select1;
@property (strong, nonatomic) UIView* view_line_select2;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIImageView* imageview_tip;

- (void)refreshDataSource;

- (void)isConnect:(BOOL)isConnect;
- (void)networkChanged:(EMConnectionState)connectionState;

@end

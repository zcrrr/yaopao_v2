//
//  ScanQRCodeViewController.h
//  QRCodeDemo
//
//  Created by Kelven on 15/6/25.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CNNetworkHandler.h"
@interface ScanQRCodeViewController : UIViewController<searchFriendDelegate>
- (IBAction)button_clicked:(id)sender;

@end

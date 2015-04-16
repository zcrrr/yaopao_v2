//
//  CNAddFriendViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/16.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendInfo;
#import "CNNetworkHandler.h"

@interface CNAddFriendViewController : UIViewController<sendMakeFriendsRequestDelegate>

@property (strong, nonatomic) FriendInfo* friend;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textfield_verifyMessage;

@end

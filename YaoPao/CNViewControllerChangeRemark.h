//
//  CNViewControllerChangeRemark.h
//  YaoPao
//
//  Created by 张驰 on 15/7/31.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendInfo;
#import "CNNetworkHandler.h"

@protocol remarkDelegate<NSObject>
- (void)remarkDidSuccess;
@end


@interface CNViewControllerChangeRemark : UIViewController<changeRemarkDelegate>
@property (strong, nonatomic) FriendInfo* friend;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textfield;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) id<remarkDelegate> delegate_remark;
@end

//
//  ChangeGroupNameViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/5/4.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSDKFull.h"
#import "CNNetworkHandler.h"

@protocol changeNameDelegate <NSObject>
//修改跑团名
- (void)changeNameDidSuccess:(NSString*)name;
@end

@interface ChangeGroupNameViewController : UIViewController<changeGroupNameDelegate>
@property (strong, nonatomic) EMGroup *chatGroup;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
- (IBAction)button_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) id<changeNameDelegate> delegate_changename;
@end

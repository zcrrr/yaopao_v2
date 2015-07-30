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
@class CNGroupInfo;

@protocol changeNameDelegate <NSObject>
//修改跑团名
- (void)changeNameDidSuccess:(NSString*)name;
@end

@interface ChangeGroupNameViewController : UIViewController<changeGroupNameDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,updateAvatarDelegate>
@property (strong, nonatomic) CNGroupInfo *chatGroup;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
- (IBAction)button_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UIButton *button_avatar;
@property (strong, nonatomic) id<changeNameDelegate> delegate_changename;
@property (strong, nonatomic) UIImage* image_avatar;
@end

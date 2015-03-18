//
//  CNOverlayViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/3/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CNImagePreviewViewController;

@interface CNOverlayViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UIImagePickerController* cameraPicker;
@property (strong, nonatomic) CNImagePreviewViewController* imagePreviewVC;
- (IBAction)button_clicked:(id)sender;

@end

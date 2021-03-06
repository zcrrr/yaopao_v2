//
//  CNOverlayViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/3/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol saveImageDelegate <NSObject>
//登录接口成功或者失败的协议，如果失败了会有原因mes
- (void)saveImageDidSuccess:(UIImage*)image;
- (void)saveImageDidFailed;
@end

@interface CNOverlayViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) UIImagePickerController* cameraPicker;
@property (weak, nonatomic) IBOutlet UIButton *button_takephoto;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button_cancel;
@property (strong, nonatomic) id<saveImageDelegate> delegate_savaImage;
@end

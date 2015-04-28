//
//  CNImagePreviewViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/3/17.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol saveImageDelegate <NSObject>
//登录接口成功或者失败的协议，如果失败了会有原因mes
- (void)saveImageDidSuccess:(UIImage*)image;
- (void)saveImageDidFailed;
@end

@interface CNImagePreviewViewController : UIViewController
@property (strong, nonatomic) UIImagePickerController* cameraPicker;
@property (strong, nonatomic) UIImage* image;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UIButton *button_rePhoto;
@property (weak, nonatomic) IBOutlet UIButton *button_save;
@property (strong, nonatomic) id<saveImageDelegate> delegete_saveImage;

@end

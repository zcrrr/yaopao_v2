//
//  CombineImagePreviewViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/5/6.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol combineImageDelegate <NSObject>
//点击按钮
- (void)combineImageDidSuccess:(UIImage*)image;
@end
@interface CombineImagePreviewViewController : UIViewController
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) id<combineImageDelegate> delegate_combineImage;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

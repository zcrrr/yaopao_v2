//
//  CNImagePreviewViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/3/17.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNImagePreviewViewController : UIViewController
@property (strong, nonatomic) UIImage* image;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

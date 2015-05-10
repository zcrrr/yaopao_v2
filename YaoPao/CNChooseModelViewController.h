//
//  CNChooseModelViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/5/6.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoImagePickerController.h"
#import "CombineImagePreviewViewController.h"

@interface CNChooseModelViewController : UIViewController<DoImagePickerControllerDelegate>
@property (strong, nonatomic) id<combineImageDelegate> delegate_combineImage;
@property (assign, nonatomic) int modelType;
@property (weak, nonatomic) IBOutlet UIButton *button_model1;
@property (weak, nonatomic) IBOutlet UIButton *button_model2;
@property (weak, nonatomic) IBOutlet UIButton *button_model3;
- (IBAction)button_clicked:(id)sender;

@end

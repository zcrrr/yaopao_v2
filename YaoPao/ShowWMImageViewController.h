//
//  ShowWMImageViewController.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/29.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddWaterMarkToImageViewController.h"

@interface ShowWMImageViewController : UIViewController<addWaterDelegate>

@property AddWaterMarkToImageViewController *AddVC;
@property (weak, nonatomic) IBOutlet UIImageView *BackGroundImage;
- (IBAction)ToAddWmView:(id)sender;
- (IBAction)back:(id)sender;
@end

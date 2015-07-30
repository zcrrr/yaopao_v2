//
//  WaterMarkTableViewCell.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/27.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterMarkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *IconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *NewFlagImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *downLoadBtn;
@property (strong, nonatomic)  UIProgressView *downLoadProgress;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

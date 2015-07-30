//
//  WaterMarkTableViewCell.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/27.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "WaterMarkTableViewCell.h"

@implementation WaterMarkTableViewCell
@synthesize nameLabel;
@synthesize NewFlagImageView;
@synthesize IconImageView;
@synthesize detailTextLabel;
@synthesize downLoadBtn;
@synthesize downLoadProgress;
@synthesize deleteBtn;

- (void)awakeFromNib {
    // Initialization code
    self.downLoadProgress.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.downLoadBtn.hidden = YES;
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.downLoadProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(width-60-20, 39, 60, 10)];
    
    self.downLoadProgress.layer.cornerRadius = 2;
    self.downLoadProgress.progressTintColor = [UIColor colorWithRed:58.f/255.f green:165.f/255.f blue:255.f/255.f alpha:1.0];
    self.downLoadProgress.trackTintColor = [UIColor colorWithRed:223.f/255.f green:223.f/255.f blue:223.f/255.f alpha:1.0];
    [self addSubview:self.downLoadProgress];
    
    
     
    self.IconImageView.layer.cornerRadius = self.IconImageView.frame.size.width/2;
    
    self.downLoadBtn.layer.cornerRadius = 5;
    self.deleteBtn.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteBtn:(id)sender {
}
@end

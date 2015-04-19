//
//  IntroduceFriendsTableViewCellCondition4.m
//  YaoPao
//
//  Created by 张驰 on 15/4/9.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "IntroduceFriendsTableViewCellCondition4.h"

@implementation IntroduceFriendsTableViewCellCondition4

- (void)awakeFromNib {
    // Initialization code
    self.imageview1.layer.cornerRadius = self.imageview1.bounds.size.width/2;
    self.imageview1.layer.masksToBounds = YES;
    self.imageview2.layer.cornerRadius = self.imageview2.bounds.size.width/2;
    self.imageview2.layer.masksToBounds = YES;
    self.imageview3.layer.cornerRadius = self.imageview3.bounds.size.width/2;
    self.imageview3.layer.masksToBounds = YES;
    self.imageview4.layer.cornerRadius = self.imageview4.bounds.size.width/2;
    self.imageview4.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
    // Configure the view for the selected state
}

@end

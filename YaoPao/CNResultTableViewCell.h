//
//  CNResultTableViewCell.h
//  YaoPao
//
//  Created by zc on 15-1-15.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNResultTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIImageView* image_type;
@property (strong, nonatomic) IBOutlet UILabel* label_date;
@property (weak, nonatomic) IBOutlet UILabel *label_dis;
@property (strong, nonatomic) IBOutlet UIImageView* image_mood;
@property (strong, nonatomic) IBOutlet UIImageView* image_way;
@property (strong, nonatomic) IBOutlet UIImageView* image_photo;
@property (weak, nonatomic) IBOutlet UIImageView *image_weather;
@property (strong, nonatomic) IBOutlet UILabel* label_pspeed;
@property (strong, nonatomic) IBOutlet UILabel* label_during;
@end

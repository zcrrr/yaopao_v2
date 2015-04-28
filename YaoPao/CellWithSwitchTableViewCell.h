//
//  CellWithSwitchTableViewCell.h
//  YaoPao
//
//  Created by 张驰 on 15/4/28.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellWithSwitchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UISwitch *myswitch;

@end

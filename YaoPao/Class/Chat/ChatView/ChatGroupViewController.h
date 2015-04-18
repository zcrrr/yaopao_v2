//
//  ChatGroupViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatGroupViewController : UIViewController

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;
- (void)reloadData;

@end

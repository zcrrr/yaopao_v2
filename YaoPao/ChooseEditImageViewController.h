//
//  ChooseEditImageViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/5/6.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol buttonClickDelegate <NSObject>
//点击按钮
- (void)buttonClickDidSuccess:(NSString*)type;
@end

@interface ChooseEditImageViewController : UIViewController
@property (strong, nonatomic) id<buttonClickDelegate> delegate_buttonClick;
- (IBAction)button_clicked:(id)sender;

@end

//
//  CNAboutViewController.h
//  YaoPao
//
//  Created by zc on 14-8-29.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNAboutViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webview;
- (IBAction)button_back_clicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

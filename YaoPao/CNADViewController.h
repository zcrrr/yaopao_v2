//
//  CNADViewController.h
//  YaoPao
//
//  Created by zc on 14-9-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNADViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
- (IBAction)button_back_clicked:(id)sender;

@end

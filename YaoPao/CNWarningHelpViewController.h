//
//  CNWarningHelpViewController.h
//  YaoPao
//
//  Created by zc on 14-9-1.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNWarningHelpViewController : UIViewController<UIWebViewDelegate>
- (IBAction)button_back_clicked:(id)sender;
@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) IBOutlet UIButton *button_back;

@end

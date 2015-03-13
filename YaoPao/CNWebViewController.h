//
//  CNWebViewController.h
//  YaoPao
//
//  Created by zc on 14-10-4.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNWebViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) NSString* externalURL;
@property (strong, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) IBOutlet UIButton *button_back;
- (IBAction)button_back_clicked:(id)sender;

@end

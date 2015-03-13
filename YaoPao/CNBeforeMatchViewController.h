//
//  CNBeforeMatchViewController.h
//  YaoPao
//
//  Created by zc on 14-9-11.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNBeforeMatchViewController : UIViewController<UIWebViewDelegate>
@property (assign ,nonatomic) BOOL excuteCallback;
@property (strong, nonatomic) IBOutlet UIWebView *webview;

@end

//
//  MatchViewController.h
//  AssistUI
//
//  Created by 张驰 on 15/3/10.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstLevelViewController.h"

@interface MatchViewController : FirstLevelViewController<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

@end

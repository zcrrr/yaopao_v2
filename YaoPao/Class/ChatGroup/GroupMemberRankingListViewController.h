//
//  GroupMemberRankingListViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/28.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMemberRankingListViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) NSString* groupid;
@property (strong, nonatomic) NSString* type;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (weak, nonatomic) IBOutlet UILabel *label_title;

@end

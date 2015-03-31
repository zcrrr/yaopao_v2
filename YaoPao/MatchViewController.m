//
//  MatchViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/10.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "MatchViewController.h"

@interface MatchViewController ()

@end

@implementation MatchViewController

- (void)viewDidLoad {
    self.selectIndex = 2;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://182.92.97.144:8888/chSports/sys/redirectMatchUrl.htm"]];
    self.webview.scalesPageToFit = YES;
    self.webview.delegate = self;
    [self.webview setBackgroundColor:[UIColor clearColor]];
    [self.webview loadRequest:request];
    [self displayLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self hideLoading];
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

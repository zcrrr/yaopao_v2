//
//  GroupMemberRankingListViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/28.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "GroupMemberRankingListViewController.h"

@interface GroupMemberRankingListViewController ()

@end

@implementation GroupMemberRankingListViewController
@synthesize type;
@synthesize groupid;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"type is %@",type);
    NSString* urlString = @"";
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    if([type isEqualToString:@"ranklist"]){
        self.label_title.text = @"团员运动排行榜";
        urlString = [NSString stringWithFormat:@"%@chSports/group/ranklist.htm?uid=%@&X-PID=%@&groupid=%@&version=1.0",ENDPOINTS,uid,kApp.pid,self.groupid];
    }else if([type isEqualToString:@"latestRecords"]){
        self.label_title.text = @"团员运动记录";
        urlString = [NSString stringWithFormat:@"%@chSports/group/record.htm?uid=%@&X-PID=%@&groupid=%@&version=1.0",ENDPOINTS,uid,kApp.pid,self.groupid];
    }
    self.webview.delegate = self;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)button_clicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
    self.view.userInteractionEnabled = NO;
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
    self.view.userInteractionEnabled = YES;
}
@end

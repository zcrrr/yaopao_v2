//
//  CNMessageViewController.m
//  YaoPao
//
//  Created by zc on 14-8-27.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNMessageViewController.h"

@interface CNMessageViewController ()

@end

@implementation CNMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webview.delegate = self;
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"message_index" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    self.webview.scalesPageToFit = YES;
    [self.webview setBackgroundColor:[UIColor clearColor]];
    [self.webview loadRequest:request];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self jsCallbackMethod:@"window.pageLoad()"];
    NSString* uid = [kApp.userInfoDic objectForKey:@"uid"];
    NSString* userinfoJson = [NSString stringWithFormat:@"{\"uid\":\"%@\",\"bid\":\"\",\"gid\":\"\",\"username\":\"\",\"nikename\":\"\",\"groupname\":\"\",\"userphoto\":\"\",\"isleader\":\"\",\"isbaton\":\"\"}",uid];
    NSString* matchinfoJson = [NSString stringWithFormat:@"{\"mid\":\"\",\"stime\":\"\",\"etime\":\"\"}"];
    NSString* deviceinfoJson = [NSString stringWithFormat:@"{\"deviceid\":\"%@\",\"platform\":\"ios\"}",kApp.pid];
    userinfoJson = [userinfoJson stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    matchinfoJson = [matchinfoJson stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    deviceinfoJson = [deviceinfoJson stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSLog(@"userinfoJson is %@",userinfoJson);
    NSLog(@"matchinfoJson is %@",matchinfoJson);
    NSLog(@"deviceinfoJson is %@",deviceinfoJson);
    NSString *jsparam = [NSString stringWithFormat:@"window.callbackInit('%@','%@','%@','%@')",userinfoJson,matchinfoJson,deviceinfoJson,ENDPOINTS];
    [self jsCallbackMethod:jsparam];
}
//js调用本地方法
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *requestURL = [request URL];
    if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ] || [ [ requestURL scheme ] isEqualToString: @"https" ] || [ [ requestURL scheme ] isEqualToString: @"mailto" ])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {
        return ![ [ UIApplication sharedApplication ] openURL: requestURL];
    }
    
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"urlString is %@",urlString);
    
    NSArray *urlComps = [urlString componentsSeparatedByString:@":??"];
    
    if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"objc"])
    {
        NSArray *arrFucnameAndParameter = [(NSString*)[urlComps objectAtIndex:1] componentsSeparatedByString:@":?"];
        NSString *funcStr = [arrFucnameAndParameter objectAtIndex:0];
        
        if (1 == [arrFucnameAndParameter count])
        {
            // 没有参数
            if([funcStr isEqualToString:@"gotoPrePage"])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    return YES;
}
//js回调
- (void)jsCallbackMethod:(NSString*)param{
    NSLog(@"----callbackjs----param is %@",param);
    [self.webview stringByEvaluatingJavaScriptFromString:param];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_back_clicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end

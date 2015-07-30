//
//  CNBeforeMatchViewController.m
//  YaoPao
//
//  Created by zc on 14-9-11.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNBeforeMatchViewController.h"
#import "CNWebViewController.h"

@interface CNBeforeMatchViewController ()

@end

@implementation CNBeforeMatchViewController
@synthesize excuteCallback;

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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"team_index" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    self.webview.scalesPageToFit = YES;
    [self.webview setBackgroundColor:[UIColor clearColor]];
    [self.webview loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString* currentURL = webView.request.URL.absoluteString;
    NSLog(@"currentURL is %@",currentURL);
    [self jsCallbackMethod:@"window.pageLoad()"];
    if([currentURL hasSuffix:@"/team_index.html"]){
//        if(self.excuteCallback){
//            return;
//        }
        NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
        if (uid == nil || ([NSNull null] == (NSNull *)uid)) {
            uid = @"";
        }
        NSString* bid = [kApp.matchDic objectForKey:@"issign"];
        if (bid == nil || ([NSNull null] == (NSNull *)bid) || [bid isEqualToString:@"0"]) {
            bid = @"";
        }
        NSString* gid = kApp.gid;
        if (gid == nil || ([NSNull null] == (NSNull *)gid)) {
            gid = @"";
        }
        NSString* username = [kApp.userInfoDic objectForKey:@"username"];
        if (username == nil || ([NSNull null] == (NSNull *)username)) {
            username = @"";
        }
        NSString* nickname = [kApp.userInfoDic objectForKey:@"nickname"];
        if (nickname == nil || ([NSNull null] == (NSNull *)nickname)) {
            nickname = @"";
        }
        NSString* groupname = [kApp.matchDic objectForKey:@"groupname"];
        if (groupname == nil || ([NSNull null] == (NSNull *)groupname)) {
            groupname = @"";
        }
        NSString* userphoto = [kApp.userInfoDic objectForKey:@"imgpath"];
        if (userphoto == nil || ([NSNull null] == (NSNull *)userphoto)) {
            userphoto = @"";
        }
        NSString* isleader = [kApp.matchDic objectForKey:@"isleader"];
        if (isleader == nil || ([NSNull null] == (NSNull *)isleader)) {
            isleader = @"";
        }
        NSString* isbaton = [kApp.matchDic objectForKey:@"isbaton"];
        if (isbaton == nil || ([NSNull null] == (NSNull *)isbaton)) {
            isbaton = @"";
        }
        NSString* userinfoJson = [NSString stringWithFormat:@"{\"uid\":\"%@\",\"bid\":\"%@\",\"gid\":\"%@\",\"username\":\"%@\",\"nickname\":\"%@\",\"groupname\":\"%@\",\"userphoto\":\"%@\",\"isleader\":\"%@\",\"isbaton\":\"%@\"}",uid,bid,gid,username,nickname,groupname,userphoto,isleader,isbaton];
        NSString* matchinfoJson = [NSString stringWithFormat:@"{\"mid\":\"1\",\"stime\":\"\",\"etime\":\"\"}"];
        NSString* deviceinfoJson = [NSString stringWithFormat:@"{\"deviceid\":\"%@\",\"platform\":\"ios\"}",kApp.pid];
        userinfoJson = [userinfoJson stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        matchinfoJson = [matchinfoJson stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        deviceinfoJson = [deviceinfoJson stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        //    NSLog(@"userinfoJson is %@",userinfoJson);
        //    NSLog(@"matchinfoJson is %@",matchinfoJson);
        //    NSLog(@"deviceinfoJson is %@",deviceinfoJson);
        NSString *jsparam = [NSString stringWithFormat:@"window.callbackInit('%@','%@','%@','%@','%@')",userinfoJson,matchinfoJson,deviceinfoJson,ENDPOINTS,kApp.imageurl];
        [self jsCallbackMethod:jsparam];
        self.excuteCallback = YES;
    }
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
        
        if([funcStr isEqualToString:@"showThirdWeb:"])
        {
            NSString *str1 = [arrFucnameAndParameter objectAtIndex:1];
            NSLog(@"str1 is %@",str1);
            CNWebViewController* webviewVC = [[CNWebViewController alloc]init];
            webviewVC.externalURL = str1;
            [self.navigationController pushViewController:webviewVC animated:YES];
            
        }
    }
    return YES;
}
//js回调
- (void)jsCallbackMethod:(NSString*)param{
    NSLog(@"----callbackjs----param is %@",param);
    [self.webview stringByEvaluatingJavaScriptFromString:param];
}

@end

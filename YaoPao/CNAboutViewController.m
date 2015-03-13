//
//  CNAboutViewController.m
//  YaoPao
//
//  Created by zc on 14-8-29.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNAboutViewController.h"

@interface CNAboutViewController ()

@end

@implementation CNAboutViewController

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
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    NSString* path = [[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:@"setup_about.html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    self.webview.scalesPageToFit = YES;
    [self.webview setBackgroundColor:[UIColor clearColor]];
    [self.webview loadRequest:request];
    
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

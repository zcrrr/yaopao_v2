//
//  CNWarningCheckTimeViewController.m
//  YaoPao
//
//  Created by zc on 14-10-5.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNWarningCheckTimeViewController.h"

@interface CNWarningCheckTimeViewController ()

@end

@implementation CNWarningCheckTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self displayLoading];
    NSString* NOTIFICATION_CHECK_TIME = @"check_time";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeSelf) name:NOTIFICATION_CHECK_TIME object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)closeSelf{
    [self dismissViewControllerAnimated:NO completion:^(void){NSLog(@"close");}];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
}
@end

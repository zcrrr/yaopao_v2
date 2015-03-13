//
//  CNWarningNotInStartZoneViewController.m
//  YaoPao
//
//  Created by zc on 14-10-5.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNWarningNotInStartZoneViewController.h"

@interface CNWarningNotInStartZoneViewController ()

@end

@implementation CNWarningNotInStartZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_NOT_IN_START_ZONE = @"not_in_start_zone";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeSelf) name:NOTIFICATION_NOT_IN_START_ZONE object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end

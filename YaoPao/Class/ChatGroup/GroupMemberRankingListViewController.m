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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"type is %@",type);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
@end

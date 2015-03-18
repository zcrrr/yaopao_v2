//
//  CountDownViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/14.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "CountDownViewController.h"
#import "RunningViewController.h"

@interface CountDownViewController ()

@end

@implementation CountDownViewController
@synthesize timer_countdown;
@synthesize count;

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 5;
    self.timer_countdown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
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

- (IBAction)view_touched:(id)sender {
    RunningViewController* runningVC = [[RunningViewController alloc]init];
    [self.navigationController pushViewController:runningVC animated:YES];
    [self.timer_countdown invalidate];
}
- (void)countdown{
    count--;
    self.label_num.text = [NSString stringWithFormat:@"%i",count];
    if(count == 0){
        RunningViewController* runningVC = [[RunningViewController alloc]init];
        [self.navigationController pushViewController:runningVC animated:YES];
        [self.timer_countdown invalidate];
    }
    
}

@end

//
//  CNCountDownViewController.m
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNCountDownViewController.h"
#import "CNRunMainViewController.h"

@interface CNCountDownViewController ()

@end

@implementation CNCountDownViewController
@synthesize timer_countdown;
@synthesize count;

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
    count = 5;
    // Do any additional setup after loading the view from its nib.
    self.timer_countdown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
    [self offLeft];
}
- (void)countdown{
    count--;
//    if(count == 9){
//        self.image1.hidden = YES;
//        [self offLeft];
//    }
    self.image2.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",count]];
    if(count == 0){
        CNRunMainViewController* runVC = [[CNRunMainViewController alloc]init];
        [self.navigationController pushViewController:runVC animated:YES];
        [self.timer_countdown invalidate];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)view_touched:(id)sender {
    CNRunMainViewController* runVC = [[CNRunMainViewController alloc]init];
    [self.navigationController pushViewController:runVC animated:YES];
    [self.timer_countdown invalidate];
}
- (void)offLeft{
    //往左偏移width的一半，使居中
    int width = self.image1.frame.size.width;
    CGRect newFrame = self.view_num.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left-width/2, top);
    self.view_num.frame = newFrame;
}
- (IBAction)button_clicked:(id)sender {
    CNRunMainViewController* runVC = [[CNRunMainViewController alloc]init];
    [self.navigationController pushViewController:runVC animated:YES];
    [self.timer_countdown invalidate];
}
@end

//
//  CNWarningBackGroundViewController.m
//  YaoPao
//
//  Created by zc on 14-9-1.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNWarningBackGroundViewController.h"
#import "CNWarningHelpViewController.h"

@interface CNWarningBackGroundViewController ()

@end

@implementation CNWarningBackGroundViewController

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
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    self.view_pop.layer.cornerRadius = 4;
    self.button_back.layer.cornerRadius = 4;
    self.button_how.layer.cornerRadius = 4;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (IBAction)button_help_clicked:(id)sender {
    NSLog(@"help");
    CNWarningHelpViewController* helpVC = [[CNWarningHelpViewController alloc]init];
    helpVC.type = @"background";
    [self.navigationController pushViewController:helpVC animated:YES];
}

- (IBAction)button_back_clicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"close");}];
}
@end

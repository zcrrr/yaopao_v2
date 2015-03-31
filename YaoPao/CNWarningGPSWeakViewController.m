//
//  CNWarningGPSWeakViewController.m
//  YaoPao
//
//  Created by zc on 14-9-1.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNWarningGPSWeakViewController.h"

@interface CNWarningGPSWeakViewController ()

@end

@implementation CNWarningGPSWeakViewController

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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_back_clicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"close");}];
    
}
@end

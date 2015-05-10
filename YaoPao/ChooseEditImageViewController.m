//
//  ChooseEditImageViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/5/6.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "ChooseEditImageViewController.h"

@interface ChooseEditImageViewController ()

@end

@implementation ChooseEditImageViewController
@synthesize delegate_buttonClick;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    switch ([sender tag]) {
        case 0:
        {
            [self dismissViewControllerAnimated:NO completion:^(void){NSLog(@"close");}];
            break;
        }
        case 1:
        {
            [self.delegate_buttonClick buttonClickDidSuccess:@"beautify"];
            break;
        }
        case 2:
        {
            [self.delegate_buttonClick buttonClickDidSuccess:@"combination"];
            break;
        }
        default:
            break;
    }
}
@end

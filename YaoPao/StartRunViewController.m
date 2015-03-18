//
//  StartRunViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/13.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "StartRunViewController.h"

@interface StartRunViewController ()

@end

@implementation StartRunViewController

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
            NSLog(@"返回");
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"目标");
            break;
        }
        case 2:
        {
            NSLog(@"类型");
            break;
        }
        case 3:
        {
            NSLog(@"开始运动");
            break;
        }
        default:
            break;
    }
    
}
@end

//
//  FirstLevelViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/10.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "FirstLevelViewController.h"
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width

@interface FirstLevelViewController ()

@end

@implementation FirstLevelViewController
@synthesize selectIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    kApp.currentSelect = self.selectIndex;
    UIView* bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-42, 320, 42)];
    [bottomBar setBackgroundColor:[UIColor colorWithRed:55.0/255.0 green:53.0/255.0 blue:69.0/255.0 alpha:1]];
    [self.view addSubview:bottomBar];
    int i = 0;
    int offsize = 27;
    for(i = 0;i<4;i++){
        UIImageView* imageview = [[UIImageView alloc]initWithFrame:CGRectMake(offsize, 2.5, 26, 26)];
        NSString* imagename;
        if(self.selectIndex == i){//当前页面高亮显示button
            imagename = [NSString stringWithFormat:@"menu%i_on.png",i];
        }else{
            imagename = [NSString stringWithFormat:@"menu%i.png",i];
        }
        imageview.image = [UIImage imageNamed:imagename];
        [bottomBar addSubview:imageview];
        offsize += 80;
    }
    offsize = 27;
    NSArray* titles = [[NSArray alloc]initWithObjects:@"首页",@"运动记录",@"跑团",@"设置",nil];
    for(i = 0;i<4;i++){
        UILabel* label;
        if(i != 1){
            label = [[UILabel alloc]initWithFrame:CGRectMake(offsize, 31, 26, 8)];
        }else{//第二个label有点长。。特殊处理
            label = [[UILabel alloc]initWithFrame:CGRectMake(100, 31, 40, 8)];
        }
        if(self.selectIndex == i){
            [label setTextColor:[UIColor colorWithRed:44.0/255.0 green:157.0/255.0 blue:219.0/255.0 alpha:1]];
        }else{
            [label setTextColor:[UIColor colorWithRed:146.0/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1]];
        }
        [label setText:[titles objectAtIndex:i]];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [bottomBar addSubview:label];
        offsize += 80;
    }
    offsize = 27;
    for(i = 0;i<4;i++){
        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(offsize-7, 2.5, 40, 42)];
        button.tag = i;
        [button addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bottomBar addSubview:button];
        offsize += 80;
    }
    UIView* view_line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    view_line.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:34.0/255.0 blue:43.0/255.0 alpha:1];
    [bottomBar addSubview:view_line];
}
- (void)tabButtonClicked:(id)sender{
    int tag = (int)[sender tag];
    [kApp showTab:tag];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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

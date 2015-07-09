//
//  AboutViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/3/24.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "AboutViewController.h"
#import "CNNetworkHandler.h"
#import "CNUtil.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize count;

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
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            count++;
            if(count == 5){
                self.button_debug.hidden = NO;
            }
            break;
        }
        case 2:
        {
            NSString* filePath = [CNPersistenceHandler getDocument:@"debug.plist"];
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
            NSString* string2upload;
            if(dic != nil){
                NSString* strHistory = [dic objectForKey:@"userOperation"];
                string2upload = [NSString stringWithFormat:@"%@\n%@",strHistory,kApp.userOperation];
            }else{
                string2upload = [NSString stringWithFormat:@"%@",kApp.userOperation];
            }
            NSLog(@"上报debug信息：%@",string2upload);
            NSData* data = [string2upload dataUsingEncoding:NSUTF8StringEncoding];
            NSString* username = @"";
            if(kApp.isLogin == 1){
                username = [kApp.userInfoDic objectForKey:@"nickname"];
            }else{
                username = @"unknown";
            }
            NSString* filename = [NSString stringWithFormat:@"%@%lli.txt",username,[CNUtil getNowTime1000]];
            [kApp.networkHandler dorequest_debug:filename :data];
        }
        default:
            break;
    }
    
}
@end

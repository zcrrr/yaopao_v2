//
//  ChangeGroupNameViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/5/4.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "ChangeGroupNameViewController.h"
#import "Toast+UIView.h"
#import "FriendsHandler.h"

@interface ChangeGroupNameViewController ()

@end

@implementation ChangeGroupNameViewController
@synthesize chatGroup;
@synthesize delegate_changename;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textfield.placeholder = self.chatGroup.groupSubject;
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
            [self.view endEditing:YES];
            if([self.textfield.text isEqualToString:@""]){
                [kApp.window makeToast:@"跑团名称不能为空!"];
                return;
            }
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
            [params setObject:uid forKey:@"uid"];
            [params setObject:self.chatGroup.groupId forKey:@"groupid"];
            [params setObject:self.chatGroup.groupDescription forKey:@"desc"];
            [params setObject:self.textfield.text forKey:@"groupname"];
            kApp.networkHandler.delegate_changeGroupName = self;
            [kApp.networkHandler doRequest_changeGroupName:params];
            [self displayLoading];
            break;
        }
        default:
            break;
    }
}
- (void)changeGroupNameDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)changeGroupNameDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    [self.delegate_changename changeNameDidSuccess:self.textfield.text];
    [self.navigationController popViewControllerAnimated:YES];
    //跑团名称改变，需要刷新4个数组
    kApp.friendHandler.friendList1NeedRefresh = YES;
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
    self.view.userInteractionEnabled = NO;
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
    self.view.userInteractionEnabled = YES;
}
@end

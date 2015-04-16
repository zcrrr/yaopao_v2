//
//  AddFriendViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/14.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "AddFriendViewController.h"
#import "FriendInfo.h"
#import "CNNetworkHandler.h"
#import "Toast+UIView.h"

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController
@synthesize friend;

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
            //发送
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
            [params setObject:uid forKey:@"uid"];
            [params setObject:self.friend.uid forKey:@"someonesID"];
            [params setObject:self.textfield_verifyMessage.text forKey:@"desc"];
            kApp.networkHandler.delegate_sendMakeFriendsRequest = self;
            [kApp.networkHandler doRequest_sendMakeFriendsRequest:params];
            [self displayLoading];
            break;
        }
        default:
            break;
    }
    
}
- (void)sendMakeFriendsRequestDidFailed:(NSString *)mes{
    [kApp.window makeToast:@"发送好友请求失败"];
    [self hideLoading];
}
- (void)sendMakeFriendsRequestDidSuccess:(NSDictionary *)resultDic{
    [kApp.window makeToast:@"发送好友请求成功"];
    [self hideLoading];
    self.friend.status = 3;
    //如果此时回到list1，应该刷新
    extern BOOL friendList1NeedRefresh;
    friendList1NeedRefresh = YES;
    //如果此时回到list2，应该刷新
    extern BOOL friendList2NeedRefresh;
    friendList2NeedRefresh = YES;
    
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
}
@end

//
//  CNViewControllerChangeRemark.m
//  YaoPao
//
//  Created by 张驰 on 15/7/31.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNViewControllerChangeRemark.h"
#import "FriendInfo.h"
#import "Toast+UIView.h"
#import "FriendsHandler.h"

@interface CNViewControllerChangeRemark ()

@end

@implementation CNViewControllerChangeRemark
@synthesize friend;
@synthesize delegate_remark;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textfield.placeholder = [friend.remark isEqualToString:@""]?friend.nameInYaoPao:friend.remark;
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
            [self setEditing:NO];
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
            [params setObject:uid forKey:@"uid"];
            [params setObject:self.friend.uid forKey:@"someonesID"];
            [params setObject:self.textfield.text forKey:@"rename"];
            kApp.networkHandler.delegate_changeRemark = self;
            [kApp.networkHandler doRequest_changeRemark:params];
            [self displayLoading];
            break;
        }
        default:
            break;
    }
}
- (void)changeRemarkDidFailed:(NSString *)mes{
    [kApp.window makeToast:@"修改备注失败，请稍后重试！"];
    [self hideLoading];
}
- (void)changeRemarkDidSuccess:(NSDictionary *)resultDic{
    self.friend.remark = self.textfield.text;
    [kApp.window makeToast:@"修改备注成功"];
    //去kApp.friendHandler.groupNeedRefresh中修改所有跑团，如果包含该好友，的备注
    [self setMemoryGroupMemberDic];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate_remark remarkDidSuccess];
    [self hideLoading];
}
- (void)setMemoryGroupMemberDic{
    NSArray* groupIds = [kApp.friendHandler.groupNeedRefresh allKeys];
    for(NSString* groupid in groupIds){
        NSDictionary* onegroup = [kApp.friendHandler.groupNeedRefresh objectForKey:groupid];
        NSArray* friendsPhones = [onegroup allKeys];
        for(NSString* phone in friendsPhones){
            if([phone isEqualToString:self.friend.phoneNO]){
                NSMutableDictionary* friendIngroup = [onegroup objectForKey:phone];
                [friendIngroup setObject:self.textfield.text forKey:@"beizhu"];
            }
        }
    }
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

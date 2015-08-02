//
//  FriendFromQRCodeViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/7/30.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "FriendFromQRCodeViewController.h"
#import "FriendInfo.h"
#import "AvatarManager.h"
#import "ChatViewController.h"
#import "CNNetworkHandler.h"
#import "Toast+UIView.h"
#import "CNADBookViewController.h"

@interface FriendFromQRCodeViewController ()

@end

@implementation FriendFromQRCodeViewController
@synthesize friend;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageview_avatar.layer.cornerRadius = self.imageview_avatar.bounds.size.width/2;
    self.imageview_avatar.layer.masksToBounds = YES;
    if(self.friend.avatarUrlInYaoPao != nil && ![self.friend.avatarUrlInYaoPao isEqualToString:@""]){//有头像url
        [kApp.avatarManager setImageToImageView:self.imageview_avatar fromUrl:self.friend.avatarUrlInYaoPao];
    }
    self.label_name.text =  [self.friend.remark isEqualToString:@""]?self.friend.nameInYaoPao:[NSString stringWithFormat:@"%@（%@）",self.friend.remark, self.friend.nameInYaoPao];
    self.label_phone.text = self.friend.phoneNO;
    NSString* imageName = [NSString stringWithFormat:@"sex_%@.png",self.friend.sex];
    self.imageview_sex.image = [UIImage imageNamed:imageName];
    if(self.friend.status == 1){
        [self.button_action setTitle:@"发送消息" forState:UIControlStateNormal];
    }else{
        [self.button_action setTitle:@"加为好友" forState:UIControlStateNormal];
    }
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
- (IBAction)button_clicked:(id)sender{
    switch ([sender tag]) {
        case 0:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            if(self.friend.status == 1){
                ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:friend.phoneNO isGroup:NO];
                chatVC.title = friend.phoneNO;
                chatVC.from = @"qrcode";
                [self.navigationController pushViewController:chatVC animated:YES];
            }else{
                NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
                [params setObject:uid forKey:@"uid"];
                [params setObject:friend.uid forKey:@"someonesID"];
                kApp.networkHandler.delegate_agreeMakeFriends = self;
                [kApp.networkHandler doRequest_agreeMakeFriends:params];
                [self displayLoading];
            }
        }
        default:
            break;
    }
}
- (void)agreeMakeFriendsDidFailed:(NSString *)mes{
    [self hideLoading];
    [kApp.window makeToast:@"添加好友失败，请重试"];
}
- (void)agreeMakeFriendsDidSuccess:(NSDictionary *)resultDic{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self hideLoading];
    [kApp.window makeToast:@"添加好友成功！"];
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

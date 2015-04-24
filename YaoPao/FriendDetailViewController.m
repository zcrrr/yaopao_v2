//
//  FriendDetailViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/14.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "FriendDetailViewController.h"
#import "FriendInfo.h"
#import "ASIHTTPRequest.h"
#import "ChatViewController.h"
#import "EMSDKFull.h"
#import "Toast+UIView.h"
#import "FriendsHandler.h"
#import "ColorValue.h"
#import "CNCustomButton.h"

@interface FriendDetailViewController ()

@end

@implementation FriendDetailViewController
@synthesize friend;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_deletefriend fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    self.imageview_avatar.layer.cornerRadius = self.imageview_avatar.bounds.size.width/2;
    self.imageview_avatar.layer.masksToBounds = YES;
    if(self.friend.avatarUrlInYaoPao != nil && ![self.friend.avatarUrlInYaoPao isEqualToString:@""]){//有头像url
        NSString* fullurl = [NSString stringWithFormat:@"%@%@",kApp.imageurl,self.friend.avatarUrlInYaoPao];
        __block UIImage* image = [kApp.avatarDic objectForKey:fullurl];
        if(image != nil){//缓存中有
            NSLog(@"缓存中有");
            self.imageview_avatar.image = image;
        }else{//下载
            NSURL *url = [NSURL URLWithString:fullurl];
            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setCompletionBlock :^{
                image = [[UIImage alloc] initWithData:[request responseData]];
                if(image != nil){
                    self.imageview_avatar.image = image;
                    [kApp.avatarDic setObject:image forKey:fullurl];
                }
            }];
            [request startAsynchronous ];
        }
    }
    self.label_name.text =  [NSString stringWithFormat:@"昵称:%@",self.friend.nameInYaoPao];
    self.label_phone.text = self.friend.phoneNO;
    NSString* imageName = [NSString stringWithFormat:@"sex_%@.png",self.friend.sex];
    self.imageview_sex.image = [UIImage imageNamed:imageName];
    
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
            NSLog(@"发起聊天");
            ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:friend.phoneNO isGroup:NO];
            chatVC.title = friend.phoneNO;
            [self.navigationController pushViewController:chatVC animated:YES];
            break;
        }
        case 2:
        {
            NSString* message = [NSString stringWithFormat:@"确定删除与%@的聊天记录？",friend.nameInYaoPao];
            UIAlertView* alert =[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
            alert.tag = 0;
            [alert show];
            break;
        }
        case 3:
        {
            NSLog(@"删除好友");
            NSString* message = [NSString stringWithFormat:@"确定删除好友？"];
            UIAlertView* alert =[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
            alert.tag = 1;
            [alert show];
            break;
        }
        default:
            break;
    }
}
#pragma -mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch ([alertView tag]) {
        case 0:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [[EaseMob sharedInstance].chatManager removeConversationByChatter:friend.phoneNO deleteMessages:YES append2Chat:YES];
                    break;
                }
                case 1:
                {
                    [alertView dismissWithClickedButtonIndex:1 animated:YES];
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            switch (buttonIndex) {
                case 0:
                {
                    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
                    [params setObject:uid forKey:@"uid"];
                    [params setObject:self.friend.uid forKey:@"someonesID"];
                    kApp.networkHandler.delegate_deleteFriend = self;
                    [kApp.networkHandler doRequest_deleteFriend:params];
                    //删除好友
                    break;
                }
                case 1:
                {
                    [alertView dismissWithClickedButtonIndex:1 animated:YES];
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
- (void)deleteFriendDidFailed:(NSString *)mes{
    [kApp.window makeToast:@"删除好友失败"];
    [self hideLoading];
    
}
- (void)deleteFriendDidSuccess:(NSDictionary *)resultDic{
    [kApp.window makeToast:@"删除好友成功"];
    //同时需要删除环信聊天信息
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:friend.phoneNO deleteMessages:YES append2Chat:YES];
    [self hideLoading];
    self.friend.status = 2;
    //如果此时回到list1，应该刷新
    kApp.friendHandler.friendList1NeedRefresh = YES;
    //如果此时回到list2，应该刷新
    kApp.friendHandler.friendList2NeedRefresh = YES;
    [self.navigationController popViewControllerAnimated:YES];
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

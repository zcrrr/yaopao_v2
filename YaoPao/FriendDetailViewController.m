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
#import "CNCustomButton.h"
#import "AvatarManager.h"
#import "CNViewControllerChangeRemark.h"

@interface FriendDetailViewController ()

@end

@implementation FriendDetailViewController
@synthesize friend;
@synthesize from;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageview_avatar.layer.cornerRadius = self.imageview_avatar.bounds.size.width/2;
    self.imageview_avatar.layer.masksToBounds = YES;
    if(self.friend.avatarUrlInYaoPao != nil && ![self.friend.avatarUrlInYaoPao isEqualToString:@""]){//有头像url
//        NSString* fullurl = [NSString stringWithFormat:@"%@%@",kApp.imageurl,self.friend.avatarUrlInYaoPao];
//        __block UIImage* image = [kApp.avatarDic objectForKey:fullurl];
//        if(image != nil){//缓存中有
//            NSLog(@"缓存中有");
//            self.imageview_avatar.image = image;
//        }else{//下载
//            NSURL *url = [NSURL URLWithString:fullurl];
//            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//            [request setCompletionBlock :^{
//                image = [[UIImage alloc] initWithData:[request responseData]];
//                if(image != nil){
//                    self.imageview_avatar.image = image;
//                    [kApp.avatarDic setObject:image forKey:fullurl];
//                }
//            }];
//            [request startAsynchronous ];
//        }
        [kApp.avatarManager setImageToImageView:self.imageview_avatar fromUrl:self.friend.avatarUrlInYaoPao];
    }
    self.label_name.text =  [self.friend.remark isEqualToString:@""]?self.friend.nameInYaoPao:[NSString stringWithFormat:@"%@（昵称:%@）",self.friend.remark, self.friend.nameInYaoPao];
    self.label_phone.text = self.friend.phoneNO;
    NSString* imageName = [NSString stringWithFormat:@"sex_%@.png",self.friend.sex];
    self.imageview_sex.image = [UIImage imageNamed:imageName];
    if([self.from isEqualToString:@"chat"]){
        self.button_chat.hidden = YES;
        self.button_clearHistory.frame = self.button_chat.frame;
    }else if([self.from isEqualToString:@"search"]){
        self.button_threedot.hidden = YES;
        self.button_threedotbutton.hidden = YES;
        NSString* hidePhoneNo = [NSString stringWithFormat:@"%@******%@",[self.friend.phoneNO substringToIndex:3],[self.friend.phoneNO substringFromIndex:9]];
        if([self.friend.nameInYaoPao isEqualToString:self.friend.phoneNO]){
            self.label_name.text = hidePhoneNo;
        }else{
            self.label_name.text = [self.friend.remark isEqualToString:@""]?self.friend.nameInYaoPao:[NSString stringWithFormat:@"%@（昵称:%@）",self.friend.remark, self.friend.nameInYaoPao];
        }
        self.label_phone.text = hidePhoneNo;
    }
    [self.view addSubview:self.view_pop];
    self.view_pop.hidden = YES;
    UITapGestureRecognizer* tapRecognizer_switch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePopView:)];
    [self.view_pop addGestureRecognizer:tapRecognizer_switch];
}
- (void)hidePopView:(id)sender
{
    self.view_pop.hidden = YES;
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
        case 4:
        {
            self.view_pop.hidden = NO;
            break;
        }
        case 5:
        {
            NSLog(@"修改备注");
            self.view_pop.hidden = YES;
            CNViewControllerChangeRemark* crVC = [[CNViewControllerChangeRemark alloc]init];
            crVC.friend = self.friend;
            crVC.delegate_remark = self;
            [self.navigationController pushViewController:crVC animated:YES];
            break;
        }
        case  6:
        {
            NSLog(@"删除好友");
            self.view_pop.hidden = YES;
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
- (void)remarkDidSuccess{
    self.label_name.text =  [self.friend.remark isEqualToString:@""]?self.friend.nameInYaoPao:[NSString stringWithFormat:@"%@（昵称:%@）",self.friend.remark, self.friend.nameInYaoPao];
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
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:nil];
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
    [kApp.window makeToast:@"删除好友失败,请稍后重试"];
    [self hideLoading];
}
- (void)deleteFriendDidSuccess:(NSDictionary *)resultDic{
    [kApp.window makeToast:@"删除好友成功"];
    //同时需要删除环信聊天信息
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:friend.phoneNO deleteMessages:YES append2Chat:YES];
    [self hideLoading];
    self.friend.status = 2;
    //如果此时回到list1，应该刷新，删除好友，必刷新
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

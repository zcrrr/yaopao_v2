//
//  FriendDetailWantMeViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/20.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "FriendDetailWantMeViewController.h"
#import "FriendInfo.h"
#import "ASIHTTPRequest.h"
#import "Toast+UIView.h"
#import "FriendsHandler.h"

@interface FriendDetailWantMeViewController ()

@end

@implementation FriendDetailWantMeViewController
@synthesize friend;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    self.label_verifymessage.text = friend.verifyMessage;
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
            NSLog(@"通过验证");
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
            [params setObject:uid forKey:@"uid"];
            [params setObject:friend.uid forKey:@"someonesID"];
            kApp.networkHandler.delegate_agreeMakeFriends = self;
            [kApp.networkHandler doRequest_agreeMakeFriends:params];
            [self displayLoading];
            break;
        }
        case 2:
        {
            NSLog(@"忽略");
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
            [params setObject:uid forKey:@"uid"];
            [params setObject:friend.uid forKey:@"someonesID"];
            kApp.networkHandler.delegate_rejectMakeFriends = self;
            [kApp.networkHandler doRequest_rejectMakeFriends:params];
            [self displayLoading];
            break;
        }
        default:
            break;
    }
}
- (void)agreeMakeFriendsDidFailed:(NSString *)mes{
    [kApp.window makeToast:@"添加失败,请稍后重试"];
    [self hideLoading];
}
- (void)agreeMakeFriendsDidSuccess:(NSDictionary *)resultDic{
    [kApp.window makeToast:@"添加成功"];
    self.friend.status = 5;
    [self hideLoading];
    //如果此时回到list1，应该刷新
    kApp.friendHandler.friendList1NeedRefresh = YES;
    kApp.friendHandler.friendList2NeedRefresh = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rejectMakeFriendsDidFailed:(NSString *)mes{
    [kApp.window makeToast:@"忽略好友请求失败,请稍后重试"];
    [self hideLoading];
}
- (void)rejectMakeFriendsDidSuccess:(NSDictionary *)resultDic{
    [kApp.window makeToast:@"已忽略好友请求"];
    self.friend.status = 6;
    [self hideLoading];
    //如果此时回到list1，应该刷新
    kApp.friendHandler.friendList1NeedRefresh = YES;
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

//
//  FriendDetailNotFriendViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/20.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "FriendDetailNotFriendViewController.h"
#import "FriendInfo.h"
#import "ASIHTTPRequest.h"
#import "AvatarManager.h"

@interface FriendDetailNotFriendViewController ()

@end

@implementation FriendDetailNotFriendViewController
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
    self.label_nameInPhone.text =  self.friend.nameInPhone;
    if([self.friend.nameInYaoPao hasPrefix:@"通讯录"]){
        self.label_nameInYaoPao.hidden = YES;
    }else{
        self.label_nameInYaoPao.text =  [NSString stringWithFormat:@"昵称:%@",self.friend.nameInYaoPao];
    }
    self.label_phone.text = self.friend.phoneNO;
    NSString* imageName = [NSString stringWithFormat:@"sex_%@.png",self.friend.sex];
    self.imageview_sex.image = [UIImage imageNamed:imageName];
    if([self.from isEqualToString:@"search"]){
        NSString* hidePhoneNo = [NSString stringWithFormat:@"%@******%@",[self.friend.phoneNO substringToIndex:3],[self.friend.phoneNO substringFromIndex:9]];
        if([self.friend.nameInYaoPao isEqualToString:self.friend.phoneNO]){
            self.label_nameInYaoPao.text = hidePhoneNo;
        }else{
            self.label_nameInYaoPao.text = friend.nameInYaoPao;
        }
        self.label_phone.text = hidePhoneNo;
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

- (IBAction)button_clicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

//
//  InviteFriendViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/14.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "InviteFriendViewController.h"
#import "FriendInfo.h"
#import <SMS_SDK/SMS_SDK.h>;

@interface InviteFriendViewController ()

@end

@implementation InviteFriendViewController
@synthesize friend;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.label_nameInPhone.text = self.friend.nameInPhone;
    self.label_phoneNO.text = self.friend.phoneNO;
    if(self.friend.avatarInPhone != nil){
        self.imageview_avatar.image = self.friend.avatarInPhone;
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
    switch ([sender tag]) {
        case 0:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:
        {
            [SMS_SDK sendSMS:self.friend.phoneNO AndMessage:@"一起来跑步吧"];
            break;
        }
        default:
            break;
    }
    
}
@end

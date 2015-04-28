//
//  ZCGroupSettingViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/27.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "ZCGroupSettingViewController.h"
#import "ContactSelectionViewController.h"
#import "GroupSettingViewController.h"
#import "EMGroup.h"
#import "ContactView.h"
#import "GroupBansViewController.h"
#import "GroupSubjectChangingViewController.h"
#import "UIViewController+HUD.h"
#import "WCAlertView.h"
#import "CNNetworkHandler.h"
#import "CellWithSwitchTableViewCell.h"
#import "GroupMemberRankingListViewController.h"
#import "Toast+UIView.h"

@interface ZCGroupSettingViewController ()

@end

@implementation ZCGroupSettingViewController
@synthesize chatGroupId;
@synthesize chatGroup;
@synthesize dataSource;
@synthesize isOwner;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:self.chatGroupId completion:^(EMGroup *group, EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                self.chatGroup = group;
                //判断是否为群主
                self.isOwner = NO;
                NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
                NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
                if ([self.chatGroup.owner isEqualToString:loginUsername]) {
                    self.isOwner = YES;
                    NSLog(@"我是群主");
                    CGRect frame_tableview = self.tableview.frame;
                    [self.button_exit setTitle:@"解散跑团" forState:UIControlStateNormal];
                    self.tableview.frame = CGRectMake(frame_tableview.origin.x, frame_tableview.origin.y, 320, 44*4);
                }
                
                if (!self.isOwner) {
                    for (NSString *str in self.chatGroup.members) {
                        if ([str isEqualToString:loginUsername]) {
                            self.isOwner = NO;
                            NSLog(@"我是成员");
                            CGRect frame_tableview = self.tableview.frame;
                            [self.button_exit setTitle:@"退出跑团" forState:UIControlStateNormal];
                            self.tableview.frame = CGRectMake(frame_tableview.origin.x, frame_tableview.origin.y, 320, 44*3);
                            break;
                        }
                    }
                }
                [self.tableview reloadData];
                //获取所有成员
                NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
                [params setObject:uid forKey:@"uid"];
                [params setObject:self.chatGroupId forKey:@"groupid"];
                kApp.networkHandler.delegate_groupMember = self;
                [kApp.networkHandler doRequest_groupMember:params];
            }
            else{
                NSLog(@"获取群详细信息出错");
            }
        });
    } onQueue:nil];
    [self registerNotifications];
    
}
- (void)groupMemberDidFailed:(NSString *)mes{
    
}
- (void)groupMemberDidSuccess:(NSDictionary *)resultDic{
    self.dataSource = [resultDic objectForKey:@"users"];
    [self refreshMemberView];
    
}
- (void)refreshMemberView{
    //先删除所有按钮
    [self.view_member.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //重新计算view_member大小
    int memberCount = (int)[self.dataSource count];
    int buttonCount = self.isOwner?(memberCount+2):(memberCount+1);
    int row = (buttonCount%5 == 0)?(buttonCount/5):(buttonCount/5+1);
    NSLog(@"有%i个成员，有%i个按钮，有%i行",memberCount,buttonCount,row);
    self.view_member.frame = CGRectMake(0, 9, 320, 11+54*row);
    //填入按钮
    //重新移动tableview
    CGRect frame_tableview = self.tableview.frame;
    CGRect frame_tableview_new;
    frame_tableview_new.origin = CGPointMake(0, self.view_member.frame.origin.y + self.view_member.frame.size.height + 9);
    frame_tableview_new.size = frame_tableview.size;
    self.tableview.frame = frame_tableview_new;
    //重新移动按钮
    self.button_clear.frame = CGRectMake(self.button_clear.frame.origin.x, self.tableview.frame.origin.y + self.tableview.frame.size.height + 21, self.button_clear.frame.size.width, self.button_clear.frame.size.height);
    self.button_exit.frame = CGRectMake(self.button_exit.frame.origin.x, self.button_clear.frame.origin.y + self.button_clear.frame.size.height + 13, self.button_exit.frame.size.width, self.button_exit.frame.size.height);
}
- (void)registerNotifications {
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
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
            NSLog(@"返回");
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"增加成员");
            break;
        }
        case 2:
        {
            NSLog(@"减少成员");
            break;
        }
        case 3:
        {
            NSLog(@"清空聊天记录");
            [self clearAction];
            break;
        }
        case 4:
        {
            NSLog(@"退出or解散跑团");
            if(self.isOwner){
                [self dissolveAction];
            }else{
                [self exitAction];
            }
            break;
        }
        default:
            break;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.isOwner){
        return 4;
    }else{
        return 3;
    }
    
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    static NSString *CellIdentifier = @"CellWithSwitchTableViewCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([CellWithSwitchTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    CellWithSwitchTableViewCell *cell = (CellWithSwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    switch (row) {
        case 0:
        {
            cell.label_title.text = @"团员运动排行榜";
            cell.myswitch.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1:
        {
            cell.label_title.text = @"团员运动记录";
            cell.myswitch.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2:
        {
            cell.label_title.text = @"接收并提示跑团消息";
            cell.myswitch.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.myswitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 3:
        {
            cell.label_title.text = @"修改跑团名称";
            cell.myswitch.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:
        {
            GroupMemberRankingListViewController* gmrlVC = [[GroupMemberRankingListViewController alloc]init];
            [self.navigationController pushViewController:gmrlVC animated:YES];
            break;
        }
        case 1:
        {
            GroupMemberRankingListViewController* gmrlVC = [[GroupMemberRankingListViewController alloc]init];
            [self.navigationController pushViewController:gmrlVC animated:YES];
            break;
        }
        case 2:
        {
            break;
            
        }
        case 3:
        {
            break;
        }
        default:
            break;
    }
}
- (void)switchValueChanged:(id)sender
{
    if(self.isOwner){
        if(!((UISwitch*)sender).isOn){
            [kApp.window makeToast:@"不能屏蔽自己创建的跑团的消息"];
            ((UISwitch*)sender).on = YES;
        }
    }else{
        [self isIgnoreGroup:!((UISwitch*)sender).isOn];
    }
}
- (void)isIgnoreGroup:(BOOL)isIgnore
{
    [self showHudInView:self.view hint:NSLocalizedString(@"group.setting.save", @"set properties")];
    __weak ZCGroupSettingViewController *weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncIgnoreGroupPushNotification:self.chatGroupId isIgnore:isIgnore completion:^(NSArray *ignoreGroupsList, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            [weakSelf showHint:NSLocalizedString(@"group.setting.success", @"set success")];
        }
        else{
            [weakSelf showHint:NSLocalizedString(@"group.setting.fail", @"set failure")];
        }
    } onQueue:nil];
}
//退出群组
- (void)exitAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"group.leave", @"quit the group")];
    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:self.chatGroupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
        [weakSelf hideHud];
        if (error) {
            [weakSelf showHint:NSLocalizedString(@"group.leaveFail", @"exit the group failure")];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
        }
    } onQueue:nil];
    
    //    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_chatGroup.groupId];
}
//解散群组
- (void)dissolveAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"group.destroy", @"dissolution of the group")];
    [[EaseMob sharedInstance].chatManager asyncDestroyGroup:self.chatGroupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
        [weakSelf hideHud];
        if (error) {
            [weakSelf showHint:NSLocalizedString(@"group.destroyFail", @"dissolution of group failure")];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
        }
    } onQueue:nil];
    
    //    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_chatGroup.groupId];
}
//清空聊天记录
- (void)clearAction
{
    __weak typeof(self) weakSelf = self;
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") customizationBlock:nil completionBlock:
     ^(NSUInteger buttonIndex, WCAlertView *alertView) {
         if (buttonIndex == 1) {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:weakSelf.chatGroup.groupId];
         }
     } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
}
@end

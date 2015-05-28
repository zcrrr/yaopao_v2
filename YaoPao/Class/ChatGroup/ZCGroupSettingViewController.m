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
#import "FriendsHandler.h"
#import "SBJson.h"
#import "ChangeGroupNameViewController.h"

@interface ZCGroupSettingViewController ()

@end

@implementation ZCGroupSettingViewController
@synthesize chatGroupId;
@synthesize chatGroup;
@synthesize dataSource;
@synthesize isOwner;
@synthesize delButtonList;
@synthesize isDelBtnDisplay;
@synthesize handleIndex;
@synthesize isShareLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self displayLoading];
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:self.chatGroupId completion:^(EMGroup *group, EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                self.chatGroup = group;
                NSLog(@"self.chatGroup.occupants is %@",self.chatGroup.occupants);
                //判断是否为群主
                self.isOwner = NO;
                NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
                NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
                if ([self.chatGroup.owner isEqualToString:loginUsername]) {
                    self.isOwner = YES;
                    NSLog(@"我是群主");
                    CGRect frame_tableview = self.tableview.frame;
                    [self.button_exit setTitle:@"解散跑团" forState:UIControlStateNormal];
                    self.tableview.frame = CGRectMake(frame_tableview.origin.x, frame_tableview.origin.y, 320, 44*5);
                }
                
                if (!self.isOwner) {
                    for (NSString *str in self.chatGroup.members) {
                        if ([str isEqualToString:loginUsername]) {
                            self.isOwner = NO;
                            NSLog(@"我是成员");
                            CGRect frame_tableview = self.tableview.frame;
                            [self.button_exit setTitle:@"退出跑团" forState:UIControlStateNormal];
                            self.tableview.frame = CGRectMake(frame_tableview.origin.x, frame_tableview.origin.y, 320, 44*4);
                            break;
                        }
                    }
                }
                [self.tableview reloadData];
                [self refreshGroupinfo];
            }
            else{
                NSLog(@"获取群详细信息出错");
                [self hideLoading];
            }
        });
    } onQueue:nil];
    [self registerNotifications];
}
- (void)refreshGroupinfo{
    self.label_title.text = [NSString stringWithFormat:@"%@/%i",self.chatGroup.groupSubject,(int)(self.chatGroup.groupOccupantsCount)];
    //获取所有成员
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    [params setObject:self.chatGroupId forKey:@"groupid"];
    kApp.networkHandler.delegate_groupMember = self;
    [kApp.networkHandler doRequest_groupMember:params];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.isDelBtnDisplay){
        [self displayDelButton];
    }
}
- (void)groupMemberDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)groupMemberDidSuccess:(NSDictionary *)resultDic{
    self.dataSource = [resultDic objectForKey:@"users"];
    [self refreshMemberView];
    [self hideLoading];
    
    //同时更新下缓存
    NSMutableDictionary* groupMemberDic = [[NSMutableDictionary alloc]init];
    for(NSDictionary* dic in self.dataSource){
        NSString* phone = [dic objectForKey:@"phone"];
        [groupMemberDic setObject:dic forKey:phone];
    }
    NSString* isShareLocation = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"enable"]];
    NSLog(@"isShareLocation is %@",isShareLocation);
    [kApp.friendHandler.groupNeedRefresh setObject:groupMemberDic forKey:self.chatGroupId];
    if([isShareLocation isEqualToString:@"1"]){//上报
        if(![kApp.friendHandler.groupIsShareLocation containsObject:self.chatGroupId]){
            [kApp.friendHandler.groupIsShareLocation addObject:self.chatGroupId];
        }
    }
    
}
- (void)refreshMemberView{
    //先删除所有按钮
    [self.view_member.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.delButtonList = [[NSMutableArray alloc]init];
    //重新计算view_member大小
    int memberCount = (int)[self.dataSource count];
    int buttonCount = self.isOwner?(memberCount+2):(memberCount+1);
    int row = (buttonCount%5 == 0)?(buttonCount/5):(buttonCount/5+1);
    NSLog(@"有%i个成员，有%i个按钮，有%i行",memberCount,buttonCount,row);
    self.view_member.frame = CGRectMake(0, 9, 320, 11+54*row);
    //填入按钮
    int i = 0;
    for( i = 0;i<[self.dataSource count];i++){
        //通过i计算行列
        int index = i+1;
        int whichRow = (index%5 == 0)?(index/5):(index/5+1);
        int whichCol = (index%5 == 0)?5:(index%5);
        NSLog(@"第%i行，第%i列",whichRow,whichCol);
        int originx = 11+(whichCol-1)*(43+21);
        int originy = 11+(whichRow-1)*(43+11);
        UIButton *memButton = [UIButton buttonWithType:UIButtonTypeCustom];
        memButton.frame = CGRectMake(originx, originy, 43, 43);
        memButton.layer.cornerRadius = 43.0/2.0;
        memButton.layer.masksToBounds = YES;
        memButton.userInteractionEnabled = NO;
        [memButton setBackgroundImage:[UIImage imageNamed:@"avatar_default.png"] forState:UIControlStateNormal];
        memButton.tag = i;
        [self.view_member addSubview:memButton];
        
        UIButton *delButton = [UIButton buttonWithType:UIButtonTypeCustom];
        delButton.frame = CGRectMake(originx-5, originy-5, 21, 21);
        [delButton setBackgroundImage:[UIImage imageNamed:@"remove_member_small.png"] forState:UIControlStateNormal];
        [delButton setBackgroundImage:[UIImage imageNamed:@"remove_member_small_on.png"] forState:UIControlStateHighlighted];
        [delButton addTarget:self action:@selector(delOneMember:) forControlEvents:UIControlEventTouchUpInside];
        delButton.tag = i;
        delButton.hidden = YES;
        [self.view_member addSubview:delButton];
        [self.delButtonList addObject:delButton];
        
        NSDictionary* memberInfo = [self.dataSource objectAtIndex:i];
        if([memberInfo objectForKey:@"imgpath"] != nil && ![[memberInfo objectForKey:@"imgpath"] isEqualToString:@""]){//有头像url
            NSString* fullurl = [NSString stringWithFormat:@"%@%@",kApp.imageurl,[memberInfo objectForKey:@"imgpath"]];
            __block UIImage* image = [kApp.avatarDic objectForKey:fullurl];
            if(image != nil){//缓存中有
                [memButton setBackgroundImage:image forState:UIControlStateNormal];
            }else{//下载
                NSURL *url = [NSURL URLWithString:fullurl];
                __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request setCompletionBlock :^{
                    image = [[UIImage alloc] initWithData:[request responseData]];
                    if(image != nil){
                        [memButton setBackgroundImage:image forState:UIControlStateNormal];
                        [kApp.avatarDic setObject:image forKey:fullurl];
                    }
                }];
                [request startAsynchronous ];
            }
        }
    }
    //增加addmember按钮
    int index = (int)[self.dataSource count]+1;
    int whichRow = (index%5 == 0)?(index/5):(index/5+1);
    int whichCol = (index%5 == 0)?5:(index%5);
    NSLog(@"第%i行，第%i列",whichRow,whichCol);
    int originx = 11+(whichCol-1)*(43+21);
    int originy = 11+(whichRow-1)*(43+11);
    self.button_addMember.frame = CGRectMake(originx, originy, 43, 43);
    [self.view_member addSubview:self.button_addMember];
    //如果是owner增加showDel按钮
    if(self.isOwner){
        int index = (int)[self.dataSource count]+2;
        int whichRow = (index%5 == 0)?(index/5):(index/5+1);
        int whichCol = (index%5 == 0)?5:(index%5);
        NSLog(@"第%i行，第%i列",whichRow,whichCol);
        int originx = 11+(whichCol-1)*(43+21);
        int originy = 11+(whichRow-1)*(43+11);
        self.button_showDelButtons.frame = CGRectMake(originx, originy, 43, 43);
        [self.view_member addSubview:self.button_showDelButtons];
    }
    
    //重新移动tableview
    CGRect frame_tableview = self.tableview.frame;
    CGRect frame_tableview_new;
    frame_tableview_new.origin = CGPointMake(0, self.view_member.frame.origin.y + self.view_member.frame.size.height + 9);
    frame_tableview_new.size = frame_tableview.size;
    self.tableview.frame = frame_tableview_new;
    //重新移动按钮
    self.button_clear.frame = CGRectMake(self.button_clear.frame.origin.x, self.tableview.frame.origin.y + self.tableview.frame.size.height + 21, self.button_clear.frame.size.width, self.button_clear.frame.size.height);
    self.button_exit.frame = CGRectMake(self.button_exit.frame.origin.x, self.button_clear.frame.origin.y + self.button_clear.frame.size.height + 13, self.button_exit.frame.size.width, self.button_exit.frame.size.height);
    self.scrollview.contentSize = CGSizeMake(320, self.button_exit.frame.origin.y + self.button_exit.frame.size.height + 10);
}
- (void)displayDelButton{
    if(self.isDelBtnDisplay){//正在显示，隐藏
        self.isDelBtnDisplay = NO;
        for(UIButton* button in self.delButtonList){
            button.hidden = YES;
        }
    }else{//显示
        self.isDelBtnDisplay = YES;
        for(UIButton* button in self.delButtonList){
            button.hidden = NO;
        }
    }
}
- (void)delOneMember:(id)sender{
    NSString* nickname = [[self.dataSource objectAtIndex:[sender tag]] objectForKey:@"nickname"];
    NSString* phone = [[self.dataSource objectAtIndex:[sender tag]] objectForKey:@"phone"];
    NSString* myphone = [kApp.userInfoDic objectForKey:@"phone"];
    if([myphone isEqualToString:phone]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"不能删除自己"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSString* message = [NSString stringWithFormat:@"确定要删除%@吗?",nickname];
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message customizationBlock:nil completionBlock:
     ^(NSUInteger buttonIndex, WCAlertView *alertView) {
         if (buttonIndex == 1) {
             [self displayLoading];
             NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
             NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
             [params setObject:uid forKey:@"uid"];
             [params setObject:self.chatGroupId forKey:@"groupid"];
             [params setObject:phone forKey:@"username"];
             kApp.networkHandler.delegate_delMember = self;
             [kApp.networkHandler doRequest_delMember:params];
             self.handleIndex = [sender tag];
         }
     } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
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
            ContactSelectionViewController *selectionController = [[ContactSelectionViewController alloc] initWithBlockSelectedUsernames:self.chatGroup.occupants];
            NSLog(@"self.chatGroup.occupants is %@",self.chatGroup.occupants);
            selectionController.delegate = self;
            [self.navigationController pushViewController:selectionController animated:YES];
            break;
        }
        case 2:
        {
            NSLog(@"减少成员");
            [self displayDelButton];
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
        return 5;
    }else{
        return 4;
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
            cell.myswitch.on = self.chatGroup.isPushNotificationEnabled;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.myswitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 3:
        {
            cell.label_title.text = @"向跑团上报我的位置";
            cell.myswitch.hidden = NO;
            if([kApp.friendHandler.groupIsShareLocation containsObject:self.chatGroupId]){
                cell.myswitch.on = YES;
                self.isShareLocation = YES;
            }else{
                cell.myswitch.on = NO;
                self.isShareLocation = NO;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.myswitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 4:
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
- (void)switchAction:(id)sender{
    if(!self.isShareLocation){
        NSLog(@"打开位置");
        [self setShareLocation:YES];
        if(!kApp.isOpenShareLocation){
            kApp.isOpenShareLocation = YES;
        }
    }else{
        NSLog(@"关闭位置");
        [self setShareLocation:NO];
    }
}
- (void)setShareLocation:(BOOL)isShare{
    NSString* des = isShare?@"true":@"false";
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    [params setObject:self.chatGroupId forKey:@"groupid"];
    [params setObject:des forKey:@"enable"];
    kApp.networkHandler.delegate_enableMyLocationInGroup = self;
    [kApp.networkHandler doRequest_enableMyLocationInGroup:params];
    [self displayLoading];
}
- (void)enableMyLocationInGroupDidFailed:(NSString *)mes{
    [self hideLoading];
    [kApp.window makeToast:@"设置失败，请稍后重试！"];
}
- (void)enableMyLocationInGroupDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    [kApp.window makeToast:@"设置成功！"];
    //本地记录最新的设置：
    if(!self.isShareLocation){
        self.isShareLocation = YES;
        if(![kApp.friendHandler.groupIsShareLocation containsObject:self.chatGroupId]){
            [kApp.friendHandler.groupIsShareLocation addObject:self.chatGroupId];
        }
    }else{
        self.isShareLocation = NO;
        if([kApp.friendHandler.groupIsShareLocation containsObject:self.chatGroupId]){
            [kApp.friendHandler.groupIsShareLocation removeObject:self.chatGroupId];
            if([kApp.friendHandler.groupIsShareLocation count] == 0){//如果一个也么有了，就不用上报了
                if(kApp.isOpenShareLocation){
                    kApp.isOpenShareLocation = NO;
                }
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    switch (row) {
        case 0:
        {
            GroupMemberRankingListViewController* gmrlVC = [[GroupMemberRankingListViewController alloc]init];
            gmrlVC.groupid = self.chatGroupId;
            gmrlVC.type = @"ranklist";
            [self.navigationController pushViewController:gmrlVC animated:YES];
            break;
        }
        case 1:
        {
            GroupMemberRankingListViewController* gmrlVC = [[GroupMemberRankingListViewController alloc]init];
            gmrlVC.groupid = self.chatGroupId;
            gmrlVC.type = @"latestRecords";
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
        case 4:
        {
            ChangeGroupNameViewController* cgnVC = [[ChangeGroupNameViewController alloc]init];
            cgnVC.delegate_changename = self;
            cgnVC.chatGroup = self.chatGroup;
            [self.navigationController pushViewController:cgnVC animated:YES];
            
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [self displayLoading];
    __weak ZCGroupSettingViewController *weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncIgnoreGroupPushNotification:self.chatGroupId isIgnore:isIgnore completion:^(NSArray *ignoreGroupsList, EMError *error) {
        [self hideLoading];
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
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:@"确认退出该跑团？" customizationBlock:nil completionBlock:
     ^(NSUInteger buttonIndex, WCAlertView *alertView) {
         if (buttonIndex == 1) {
             NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
             NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
             NSString* phone = [kApp.userInfoDic objectForKey:@"phone"];
             [params setObject:uid forKey:@"uid"];
             [params setObject:self.chatGroupId forKey:@"groupid"];
             [params setObject:phone forKey:@"username"];
             kApp.networkHandler.delegate_exitGroup = self;
             [kApp.networkHandler doRequest_exitGroup:params];
             [self displayLoading];
         }
     } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
}
//解散群组
- (void)dissolveAction
{
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:@"确认解散该跑团？" customizationBlock:nil completionBlock:
     ^(NSUInteger buttonIndex, WCAlertView *alertView) {
         if (buttonIndex == 1) {
             NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
             NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
             [params setObject:uid forKey:@"uid"];
             [params setObject:self.chatGroupId forKey:@"groupid"];
             kApp.networkHandler.delegate_deleteGroup = self;
             [kApp.networkHandler doRequest_deleteGroup:params];
             [self displayLoading];
         }
     } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
}
//清空聊天记录
- (void)clearAction
{
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") customizationBlock:nil completionBlock:
     ^(NSUInteger buttonIndex, WCAlertView *alertView) {
         if (buttonIndex == 1) {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:self.chatGroup.groupId];
         }
     } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
}
- (void)delMemberDidFailed:(NSString *)mes{
    __weak ZCGroupSettingViewController *weakSelf = self;
    [self hideLoading];
    NSLog(@"删除成员失败");
}
- (void)delMemberDidSuccess:(NSDictionary *)resultDic{
    NSString* nickname = [[self.dataSource objectAtIndex:self.handleIndex] objectForKey:@"nickname"];
//    NSString* phone = [[self.dataSource objectAtIndex:self.handleIndex] objectForKey:@"phone"];
//    NSArray* occupants = [[NSArray alloc]initWithObjects:phone, nil];
//    [[EaseMob sharedInstance].chatManager asyncRemoveOccupants:occupants fromGroup:self.chatGroupId completion:^(EMGroup *group, EMError *error) {
//        __weak ZCGroupSettingViewController *weakSelf = self;
//        if (!error) {
//            self.chatGroup = group;
//            [kApp.window makeToast:[NSString stringWithFormat:@"已删除%@",nickname]];
//            [self.dataSource removeObjectAtIndex:self.handleIndex];
//            self.label_title.text = [NSString stringWithFormat:@"%@/%i",self.chatGroup.groupSubject,(int)(self.chatGroup.groupOccupantsCount)];
//            [self refreshMemberView];
//        }
//        else{
//            [kApp.window makeToast:@"删除成员失败"];
//        }
//    } onQueue:nil];
    
    
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:self.chatGroupId completion:^(EMGroup *group, EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (!error) {
                self.chatGroup = group;
                [kApp.window makeToast:[NSString stringWithFormat:@"已删除%@",nickname]];
                [self.dataSource removeObjectAtIndex:self.handleIndex];
                self.label_title.text = [NSString stringWithFormat:@"%@/%i",self.chatGroup.groupSubject,(int)(self.chatGroup.groupOccupantsCount)];
                [self refreshMemberView];
            }
            else{
                NSLog(@"获取群详细信息出错");
                [self hideLoading];
            }
        });
    } onQueue:nil];
    
}
- (void)exitGroupDidFailed:(NSString *)mes{
    [self hideLoading];
    NSLog(@"退出跑团失败");
}
- (void)exitGroupDidSuccess:(NSDictionary *)resultDic{
//    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:self.chatGroupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
//        if (error) {
//            [kApp.window makeToast:@"退出跑团失败"];
//            [self hideLoading];
//        }
//        else{
//            [self hideLoading];
//            [kApp.window makeToast:@"您已退出跑团！"];
//            kApp.friendHandler.friendList1NeedRefresh = YES;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
//        }
//    } onQueue:nil];
    [self hideLoading];
    [kApp.window makeToast:@"您已退出跑团！"];
    //退出跑团，肯定要刷新
    kApp.friendHandler.friendList1NeedRefresh = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
}
- (void)deleteGroupDidFailed:(NSString *)mes{
    [self hideLoading];
    NSLog(@"解散跑团失败");
}
- (void)deleteGroupDidSuccess:(NSDictionary *)resultDic{
//    [[EaseMob sharedInstance].chatManager asyncDestroyGroup:self.chatGroupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
//        if (error) {
//            NSLog(@"解散跑团失败");
//            [self hideLoading];
//        }
//        else{
//            [self hideLoading];
//            [kApp.window makeToast:@"成功解散跑团！"];
//            kApp.friendHandler.friendList1NeedRefresh = YES;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
//        }
//    } onQueue:nil];
    [self hideLoading];
    [kApp.window makeToast:@"成功解散跑团！"];
    //参与跑团发生变化，，必刷新
    kApp.friendHandler.friendList1NeedRefresh = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
}
- (void)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources{
    NSLog(@"选好了");
    NSMutableString* addMemberPhones = [NSMutableString stringWithString:@""];
    for (EMBuddy *buddy in selectedSources) {
        [addMemberPhones appendString:buddy.username];
        [addMemberPhones appendString:@","];
    }
    if([addMemberPhones hasSuffix:@","]){
        addMemberPhones = [NSMutableString stringWithString:[addMemberPhones substringToIndex:addMemberPhones.length - 1]];
    }
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    [params setObject:self.chatGroupId forKey:@"groupid"];
    [params setObject:addMemberPhones forKey:@"usernames"];
    kApp.networkHandler.delegate_addMember = self;
    [kApp.networkHandler doRequest_addMember:params];
    [self displayLoading];
}
- (void)addMemberDidSuccess:(NSDictionary *)resultDic{
    [kApp.window makeToast:@"添加成功"];
    //添加成员之后更新self.chatGroup
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:self.chatGroupId completion:^(EMGroup *group, EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                self.chatGroup = group;
                //获取所有成员，刷新列表
                [self refreshGroupinfo];
            }
            else{
                [self displayLoading];
                NSLog(@"获取群详细信息出错");
            }
        });
    } onQueue:nil];
}
- (void)addMemberDidFailed:(NSString *)mes{
    [kApp.window makeToast:@"添加失败"];
    [self hideLoading];
}
- (void)changeNameDidSuccess:(NSString *)name{
    self.label_title.text = [NSString stringWithFormat:@"%@/%i",name,(int)(self.chatGroup.groupOccupantsCount)];
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

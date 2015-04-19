//
//  NewFriendsViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/9.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "NewFriendsViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/SMS_AddressBook.h>
#import <AddressBook/AddressBook.h>
#import "FriendInfo.h"
#import "NewFriendsTableViewCell.h"
#import "InviteFriendViewController.h"
#import "CNAddFriendViewController.h"
#import "CNNetworkHandler.h"
#import "Toast+UIView.h"
#import "FriendsHandler.h"

@interface NewFriendsViewController ()

@end

@implementation NewFriendsViewController
@synthesize friendsToInvite;
@synthesize friendOnHandle;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsToInvite = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    int i = 0;
    int k = 0;
    for(i = 0; i < CFArrayGetCount(results); i++){
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        } else {
            if ((__bridge id)abLastName != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        NSData *image = (__bridge NSData*)ABPersonCopyImageData(person);
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (k = 0; k<ABMultiValueGetCount(phones); k++)
        {
            CFTypeRef value = ABMultiValueCopyValueAtIndex(phones, k);
            NSString* phoneNO = (__bridge NSString*)value;
            phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
            FriendInfo* friend2Invite = [[FriendInfo alloc]initWithUid:@"" phoneNO:phoneNO nameInPhone:nameString nameInYaoPao:@"" avatarInPhone:[UIImage imageWithData:image] avatarUrlInYaoPao:@"" status:0 verifyMessage:@"" sex:@""];
            if(![self isFriendAlreadyJoin:friend2Invite]){//不在已经加入app列表
                [self.friendsToInvite addObject:friend2Invite];
//                NSLog(@"%@:%@",friend2Invite.nameInPhone,friend2Invite.phoneNO);
            }
        }
    }
    kApp.friendHandler.friendList2NeedRefresh = YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(kApp.friendHandler.friendList2NeedRefresh){
        NSLog(@"需要刷新好友列表2");
        kApp.friendHandler.friendList2NeedRefresh = NO;
        [self.tableview reloadData];
    }else{
        NSLog(@"不需要刷新好友列表2");
    }
    
}
- (BOOL)isFriendAlreadyJoin:(FriendInfo*)friend{
    NSString* phoneNO = friend.phoneNO;
    int i = 0;
    for(i = 0;i<[kApp.myContactUseApp count];i++){
        FriendInfo* oneObject = [kApp.myContactUseApp objectAtIndex:i];
        if([phoneNO containsString:oneObject.phoneNO]){
            oneObject.nameInPhone = friend.nameInPhone;
            return YES;
        }
    }
    return NO;
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
#pragma mark - TableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return [kApp.friendHandler.friendsNew count];
    }else{
        return [self.friendsToInvite count];
    }
}
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc]init];
    customView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1];
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 22)];
    headerLabel.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1];
    [headerLabel setFont:[UIFont systemFontOfSize:12]];
    if(section == 0){
        headerLabel.text = @"已加入要跑的好友";
    }else{
        headerLabel.text = @"邀请好友加入要跑";
    }
    [customView addSubview:headerLabel];
    return customView;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    static NSString *CellIdentifier = @"NewFriendsTableViewCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([NewFriendsTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    NewFriendsTableViewCell *cell = (NewFriendsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendInfo* friend;
    if(section == 0){
        friend = [kApp.friendHandler.friendsNew objectAtIndex:row];
        cell.label_username.text = friend.nameInYaoPao;
        if(friend.avatarUrlInYaoPao != nil && ![friend.avatarUrlInYaoPao isEqualToString:@""]){//有头像url
            NSString* fullurl = [NSString stringWithFormat:@"%@%@",kApp.imageurl,friend.avatarUrlInYaoPao];
            __block UIImage* image = [kApp.avatarDic objectForKey:fullurl];
            if(image != nil){//缓存中有
                cell.imageview_avatar.image = image;
            }else{//下载
                NSURL *url = [NSURL URLWithString:fullurl];
                __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request setCompletionBlock :^{
                    image = [[UIImage alloc] initWithData:[request responseData]];
                    if(image != nil){
                        cell.imageview_avatar.image = image;
                        [kApp.avatarDic setObject:image forKey:fullurl];
                    }
                }];
                [request startAsynchronous ];
            }
        }else{
            cell.imageview_avatar.image = [UIImage imageNamed:@"avatar_default.png"];
        }
    }else{
        friend = [self.friendsToInvite objectAtIndex:row];
        cell.label_username.text = friend.nameInPhone;
        if(friend.avatarInPhone != nil){
            cell.imageview_avatar.image = friend.avatarInPhone;
        }else{
            cell.imageview_avatar.image = [UIImage imageNamed:@"avatar_default.png"];
        }
    }
    NSString* action = @"";
    switch (friend.status) {
        case 0:
            action = @"邀请";
            break;
        case 1:
            action = @"";
            break;
        case 2:
            action = @"添加";
            break;
        case 3:
            action = @"接受";
            break;
        case 4:
            action = @"等待验证";
            break;
        case 5:
            action = @"已接受";
            break;
        case 6:
            action = @"已忽略";
            break;
        default:
            break;
    }
    [cell.button_action setTitle:action forState:UIControlStateNormal];
    if(friend.status <= 3){
        if(section == 0){
            cell.button_action.tag = 10000+row;
        }else{
            cell.button_action.tag = row;
        }
        [cell.button_action addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [cell.button_action setEnabled:NO];
    }
    
    return cell;
}
- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 1:
        {
            NSLog(@"添加");
            break;
        }
        default:
            break;
    }
    
}
- (void)actionButtonClicked:(id)sender{
    int tag = (int)[sender tag];
    int row = tag>9999?tag-10000:tag;
    FriendInfo* friend = tag>9999?[kApp.friendHandler.friendsNew objectAtIndex:row]:[self.friendsToInvite objectAtIndex:row];
    switch (friend.status) {
        case 0:
        {
            InviteFriendViewController* ifVC = [[InviteFriendViewController alloc]init];
            ifVC.friend = friend;
            [self.navigationController pushViewController:ifVC animated:YES];
            break;
        }
        case 1:
            break;
        case 2:
        {
            CNAddFriendViewController* afVC = [[CNAddFriendViewController alloc]init];
            afVC.friend = friend;
            [self.navigationController pushViewController:afVC animated:YES];
            break;
        }
        case 3:
        {
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
            [params setObject:uid forKey:@"uid"];
            [params setObject:friend.uid forKey:@"someonesID"];
            kApp.networkHandler.delegate_agreeMakeFriends = self;
            [kApp.networkHandler doRequest_agreeMakeFriends:params];
            self.friendOnHandle = friend;
            [self displayLoading];
            break;
        }
        case 4:
            break;
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
    self.friendOnHandle.status = 5;
    [self.tableview reloadData];
    [self hideLoading];
    //如果此时回到list1，应该刷新
    kApp.friendHandler.friendList1NeedRefresh = YES;
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

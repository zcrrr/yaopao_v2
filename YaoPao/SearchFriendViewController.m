//
//  SearchFriendViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/20.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "SearchFriendViewController.h"
#import "SearchFriendTableViewCell.h"
#import "FriendInfo.h"
#import "ASIHTTPRequest.h"
#import "CNAddFriendViewController.h"
#import "FriendsHandler.h"
#import "Toast+UIView.h"
#import "CNNetworkHandler.h"
#import "FriendDetailNotFriendViewController.h"
#import "FriendDetailWantMeViewController.h"
#import "FriendDetailViewController.h"
#import "FriendDetailNotFriendNotContactViewController.h"
#import "CNUtil.h"


@interface SearchFriendViewController ()

@end

@implementation SearchFriendViewController
@synthesize searchResult;
@synthesize friendOnHandle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableview reloadData];
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
            NSLog(@"搜索");
            [self.textfield resignFirstResponder];
            if(self.textfield.text == nil || [self.textfield.text isEqualToString:@""]){
                [kApp.window makeToast:@"手机号不能为空，支持模糊查询"];
            }else if(self.textfield.text.length < 3){
                [kApp.window makeToast:@"至少输入3位手机号！"];
            }else{
                NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
                [params setObject:uid forKey:@"uid"];
                [params setObject:self.textfield.text forKey:@"phone"];
                kApp.networkHandler.delegate_searchFriend = self;
                [kApp.networkHandler doRequest_searchFriend:params];
                [self displayLoading];
            }
            break;
        }
        default:
            break;
    }
}
#pragma mark - TableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.searchResult count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    static NSString *CellIdentifier = @"SearchFriendTableViewCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([SearchFriendTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    SearchFriendTableViewCell *cell = (SearchFriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendInfo* friend;
    friend = [self.searchResult objectAtIndex:row];
    NSString* hidePhoneNo = [NSString stringWithFormat:@"%@******%@",[friend.phoneNO substringToIndex:3],[friend.phoneNO substringFromIndex:9]];
    if([friend.nameInYaoPao isEqualToString:friend.phoneNO]){
        cell.label_name.text = hidePhoneNo;
    }else{
        cell.label_name.text = friend.nameInYaoPao;
    }
    cell.label_phone.text = hidePhoneNo;
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
    cell.button_action.tag = row;
    if(friend.status <= 3){
        [cell.button_action addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.button_action setEnabled:YES];
        [cell.button_action setBackgroundImage:[UIImage imageNamed:@"action_buttonbg.png"] forState:UIControlStateNormal];
        [cell.button_action setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }else{
        [cell.button_action setEnabled:NO];
        [cell.button_action setBackgroundImage:[UIImage imageNamed:@"action_buttonbg_no.png"] forState:UIControlStateNormal];
        [cell.button_action setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    NSString* action = @"";
    switch (friend.status) {
        case 0:
            action = @"邀请";
            break;
        case 1:
        {
            action = @"";
            cell.button_action.hidden = YES;
            break;
        }
        case 2:
        {
            action = @"添加";
            cell.button_action.hidden = NO;
            break;
        }
        case 3:
        {
            action = @"接受";
            cell.button_action.hidden = NO;
            break;
        }
        case 4:
        {
            action = @"等待验证";
            cell.button_action.hidden = NO;
            break;
        }
        case 5:
        {
            action = @"已接受";
            cell.button_action.hidden = NO;
            break;
        }
        case 6:
        {
            action = @"已忽略";
            cell.button_action.hidden = NO;
            break;
        }
        default:
            break;
    }
    [cell.button_action setTitle:action forState:UIControlStateNormal];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    FriendInfo* friend = [self.searchResult objectAtIndex:row];
    switch (friend.status) {
        case 1://已经是好友
        {
            FriendDetailViewController* fdVC = [[FriendDetailViewController alloc]init];
            fdVC.friend = friend;
            fdVC.from = @"search";
            [self.navigationController pushViewController:fdVC animated:YES];
            break;
        }
        case 2://可添加
        {
            FriendDetailNotFriendNotContactViewController* fdnfVC = [[FriendDetailNotFriendNotContactViewController alloc]init];
            fdnfVC.friend = friend;
            fdnfVC.from = @"search";
            [self.navigationController pushViewController:fdnfVC animated:YES];
            break;
        }
        case 3://可接受或忽略
        {
            FriendDetailWantMeViewController* fdwmVC = [[FriendDetailWantMeViewController alloc]init];
            fdwmVC.friend = friend;
            fdwmVC.from = @"search";
            [self.navigationController pushViewController:fdwmVC animated:YES];
            break;
        }
        case 4://等待验证
        {
            FriendDetailNotFriendViewController* fdnfVC = [[FriendDetailNotFriendViewController alloc]init];
            fdnfVC.friend = friend;
            fdnfVC.from = @"search";
            [self.navigationController pushViewController:fdnfVC animated:YES];
            break;
        }
        case 5://已经是好友
        {
            FriendDetailViewController* fdVC = [[FriendDetailViewController alloc]init];
            fdVC.friend = friend;
            [self.navigationController pushViewController:fdVC animated:YES];
            break;
        }
        case 6://已忽略
        {
            FriendDetailNotFriendViewController* fdnfVC = [[FriendDetailNotFriendViewController alloc]init];
            fdnfVC.friend = friend;
            fdnfVC.from = @"search";
            [self.navigationController pushViewController:fdnfVC animated:YES];
            break;
        }
        
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)actionButtonClicked:(id)sender{
    FriendInfo* friend = [self.searchResult objectAtIndex:[sender tag]];
    switch (friend.status) {
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
    //如果此时回到list1，应该刷新，添加好友必刷新
    kApp.friendHandler.friendList1NeedRefresh = YES;
}
- (void)searchFriendDidFailed:(NSString *)mes{
    [CNUtil showAlert:mes];
    [self hideLoading];
}
- (void)searchFriendDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    NSArray* array = [resultDic objectForKey:@"frdlist"];
    if(array == nil || [array count] == 0){
        [kApp.window makeToast:@"没有相关搜索结果!"];
        return;
    }
    self.searchResult = [[NSMutableArray alloc]init];
    for(NSDictionary* dic in array){
        NSString* uid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        NSString* phone = [dic objectForKey:@"phone"];
        NSString* name = [dic objectForKey:@"nickname"];
        NSString* avatar = [dic objectForKey:@"imgpath"];
        int status = [[dic objectForKey:@"friend"]intValue];
        NSString* sex = [dic objectForKey:@"gender"];
        FriendInfo* oneFriend = [[FriendInfo alloc]initWithUid:uid phoneNO:phone nameInPhone:@"" nameInYaoPao:name avatarInPhone:nil avatarUrlInYaoPao:avatar status:status verifyMessage:@"" sex:sex];
        [self.searchResult addObject:oneFriend];
    }
    [self.tableview reloadData];
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

//
//  CNADBookViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/9.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNADBookViewController.h"
#import "GetFirstLetter.h"
#import "IntroduceFriendsTableViewCellCondition1.h"
#import "IntroduceFriendsTableViewCellCondition3.h"
#import "IntroduceFriendsTableViewCellCondition4.h"
#import "NewFriendsViewController.h"
#import "FriendInfo.h"
#import <SMS_SDK/SMS_SDK.h>
#import "NewFriendsTableViewCell.h"
#import "FriendDetailViewController.h"
#import "CNGroupInfo.h"
#import "ChatGroupViewController.h"

@interface CNADBookViewController ()

@end

@implementation CNADBookViewController
@synthesize friends;
@synthesize friendsIWant;
@synthesize frinedsWantMe;
@synthesize myContactUseAppButNotFriend;
@synthesize keys;
@synthesize groupedMap;
@synthesize friendsNew;
@synthesize haveNewFriends;
@synthesize FriendNewString;
BOOL friendList1NeedRefresh;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.friends = [[NSMutableArray alloc]initWithObjects:@"张驰",@"王雨",@"董杉",@"钟鸣",@"王晓瑄",@"张驰",@"王雨",@"董杉",@"钟鸣",@"王晓瑄",@"张驰",@"王雨",@"董杉",@"钟鸣",@"王晓瑄",@"张驰",@"王雨",@"董杉",@"钟鸣",@"王晓瑄",nil];
    if(kApp.myContactUseApp == nil){
        kApp.myContactUseApp = [[NSMutableArray alloc]init];
    }
    friendList1NeedRefresh = YES;
    //发送请求
//    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
//    [params setObject:@"5" forKey:@"uid"];
//    [params setObject:@"7" forKey:@"someonesID"];
//    [params setObject:@"add me please" forKey:@"desc"];
//    kApp.networkHandler.delegate_sendMakeFriendsRequest = self;
//    [kApp.networkHandler doRequest_sendMakeFriendsRequest:params];
    //接受请求
//    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
//    [params setObject:@"7" forKey:@"uid"];
//    [params setObject:@"5" forKey:@"someonesID"];
//    kApp.networkHandler.delegate_agreeMakeFriends = self;
//    [kApp.networkHandler doRequest_agreeMakeFriends:params];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(friendList1NeedRefresh){
        friendList1NeedRefresh = NO;
        NSLog(@"需要刷新好友列表1");
        self.friends = [[NSMutableArray alloc]init];
        self.friendsIWant = [[NSMutableArray alloc]init];
        self.frinedsWantMe = [[NSMutableArray alloc]init];
        self.myGroups = [[NSMutableArray alloc]init];
        self.keys = [[NSMutableArray alloc]init];
        self.groupedMap = [[NSMutableDictionary alloc]init];
        //好友列表
        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
        NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
        [params setObject:uid forKey:@"uid"];
        kApp.networkHandler.delegate_friendsList = self;
        [kApp.networkHandler doRequest_friendsList:params];
        [self displayLoading];
        
    }else{
        NSLog(@"不需要刷新好友列表1");
    }
}
- (void)initKeys{
    NSMutableArray* array_keys = [[NSMutableArray alloc]init];
    for (FriendInfo* friend in self.friends)
    {
        NSString* name = friend.nameInYaoPao;
        char c = [GetFirstLetter  pinyinFirstLetter:([name characterAtIndex:0])];
        NSString* oneKey = [[NSString stringWithFormat:@"%c",c] uppercaseString];
        
        /*
         对 ”长“ 进行特殊处理
         直接归属为C
         */
//        if (nil != oneObjStreetInfo.str_imgname && ![oneObjStreetInfo.str_imgname isEqualToString:@""])
//        {
//            NSString* str_firstChar = [oneObjStreetInfo.str_imgname substringToIndex:1];
//            
//            if ([str_firstChar isEqualToString:@"长"])
//            {
//                oneKey = @"C";
//            }
//            if ([str_firstChar isEqualToString:@"重"])
//            {
//                oneKey = @"C";
//            }
//        }
        NSMutableArray* nameStartWithSameLetter = [self.groupedMap valueForKey:oneKey];
        if (nameStartWithSameLetter == nil)
        {
            [array_keys addObject:oneKey];
            nameStartWithSameLetter = [[NSMutableArray alloc]init];
        }
        [nameStartWithSameLetter addObject:friend];
        [self.groupedMap setValue:nameStartWithSameLetter forKey:oneKey];
    }
    //在dic里加上跑团的信息
    [self.groupedMap setValue:self.myGroups forKey:@"跑团"];
    
    self.keys = [[NSMutableArray alloc]init];
    [self.keys addObject:@"推荐好友"];
    [self.keys addObject:@"跑团"];
    [self.keys addObjectsFromArray:[array_keys sortedArrayUsingSelector:@selector(compare:)]];
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
    return [self.keys count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){//第一行
        return 1;
    }else{
        return [[self.groupedMap objectForKey:[self.keys objectAtIndex:section]] count];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){//第一行
        return @"好友推荐";
    }else{
        return [self.keys objectAtIndex:section];
    }
}
- (NSArray*) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(self.keys == nil||[self.keys count]<1){
        return nil;
    }
    NSMutableArray* array = [[NSMutableArray alloc]initWithArray:self.keys];
    [array replaceObjectAtIndex:0 withObject:@""];
    return array;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    if(section == 0){//第一行
        int condition = 2;
        NSInteger suggestFriendCount = [self.myContactUseAppButNotFriend count];//推荐的好友数（手机里使用app的人-其中已经是好友的人）
        if([self.frinedsWantMe count]>0){//有验证的好友
            condition = 1;
        }else{//没有验证的好友
            if(suggestFriendCount == 0){//没有推荐好友
                condition = 2;
            }else{//有推荐好友
                if(suggestFriendCount == 1){//只有一个
                    condition = 3;
                }else{
                    condition = 4;
                }
            }
        }
        int displayNum = [self.friendsNew count];
        switch (condition) {
            case 1:
            {
                IntroduceFriendsTableViewCellCondition1 *cell = [[[NSBundle mainBundle] loadNibNamed:@"IntroduceFriendsTableViewCellCondition1" owner:self options:nil] lastObject];
                FriendInfo* friend = [self.frinedsWantMe firstObject];
                cell.label_name.text = friend.nameInYaoPao;
                if(self.haveNewFriends){
                    cell.label_num.hidden = NO;
                    cell.label_num.text = [NSString stringWithFormat:@"%i",displayNum];
                }else{
                    cell.label_num.hidden = YES;
                }
                
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
                }
                return cell;
                break;
            }
            case 2:
            {
                UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.imageView.image = [UIImage imageNamed:@"avatar_default.png"];
                cell.textLabel.text = @"没有好友推荐";
                return cell;
                break;
            }
            case 3:
            {
                IntroduceFriendsTableViewCellCondition3 *cell = [[[NSBundle mainBundle] loadNibNamed:@"IntroduceFriendsTableViewCellCondition3" owner:self options:nil] lastObject];
                FriendInfo* friend = [self.myContactUseAppButNotFriend firstObject];
                cell.label_name.text = friend.nameInYaoPao;
                if(self.haveNewFriends){
                    cell.label_num.hidden = NO;
                    cell.label_num.text = [NSString stringWithFormat:@"%i",displayNum];
                }else{
                    cell.label_num.hidden = YES;
                }
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
                }
                return cell;
                break;
            }
            case 4:
            {
                IntroduceFriendsTableViewCellCondition4 *cell = [[[NSBundle mainBundle] loadNibNamed:@"IntroduceFriendsTableViewCellCondition4" owner:self options:nil] lastObject];
                NSArray* arraytemp = [[NSArray alloc]initWithObjects:cell.imageview1,cell.imageview2,cell.imageview3,cell.imageview4, nil];
                int i = 0;
                for(i=0;i<4;i++){
                    if(i == [self.myContactUseAppButNotFriend count]){
                        break;
                    }
                    FriendInfo* friend = [self.myContactUseAppButNotFriend objectAtIndex:i];
                    if(friend.avatarUrlInYaoPao != nil && ![friend.avatarUrlInYaoPao isEqualToString:@""]){//有头像url
                        NSString* fullurl = [NSString stringWithFormat:@"%@%@",kApp.imageurl,friend.avatarUrlInYaoPao];
                        __block UIImage* image = [kApp.avatarDic objectForKey:fullurl];
                        if(image != nil){//缓存中有
                            ((UIImageView*)[arraytemp objectAtIndex:i]).image = image;
                        }else{//下载
                            NSURL *url = [NSURL URLWithString:fullurl];
                            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                            [request setCompletionBlock :^{
                                image = [[UIImage alloc] initWithData:[request responseData]];
                                if(image != nil){
                                    ((UIImageView*)[arraytemp objectAtIndex:i]).image = image;
                                    [kApp.avatarDic setObject:image forKey:fullurl];
                                }
                            }];
                            [request startAsynchronous ];
                        }
                    }
                }
                if(self.haveNewFriends){
                    cell.label_num.hidden = NO;
                    cell.label_num.text = [NSString stringWithFormat:@"%i",displayNum];
                }else{
                    cell.label_num.hidden = YES;
                }
                return cell;
                break;
            }
                
            default:
                return nil;
        }
        
    }else if(section == 1){//跑团
        NSString* key = [self.keys objectAtIndex:section];
        static NSString *CellIdentifier = @"NewFriendsTableViewCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([NewFriendsTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        CNGroupInfo* group = [[groupedMap objectForKey:key]objectAtIndex:row];
        NewFriendsTableViewCell *cell = (NewFriendsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.label_username.text = group.groupName;
        cell.imageview_avatar.image = [UIImage imageNamed:@"avatar_default.png"];
        cell.button_action.hidden = YES;
        return cell;
    }else{
        NSString* key = [self.keys objectAtIndex:section];
        static NSString *CellIdentifier = @"NewFriendsTableViewCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([NewFriendsTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        FriendInfo* friend = [[groupedMap objectForKey:key]objectAtIndex:row];
        NewFriendsTableViewCell *cell = (NewFriendsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
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
        cell.button_action.hidden = YES;
        
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    NSString* key = [self.keys objectAtIndex:section];
    if(section == 0){//点击推荐好友
        NewFriendsViewController* nfVC = [[NewFriendsViewController alloc]init];
        nfVC.friendsNew = self.friendsNew;
        [self.navigationController pushViewController:nfVC animated:YES];
        [self writeNewFriendsStringToPlist];
    }else if(section == 1){//点击跑团
        CNGroupInfo* group = [self.myGroups objectAtIndex:row];
        ChatGroupViewController* chatController = [[ChatGroupViewController alloc] initWithChatter:group.groupId isGroup:YES];
        [self.navigationController pushViewController:chatController animated:YES];
    }else{
        FriendInfo* friend = [[groupedMap objectForKey:key]objectAtIndex:row];
        FriendDetailViewController* fdVC = [[FriendDetailViewController alloc]init];
        fdVC.friend = friend;
        [self.navigationController pushViewController:fdVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)friendsListDidFailed:(NSString *)mes{
    NSLog(@"请求好友列表失败，原因是%@",mes);
}
- (void)friendsListDidSuccess:(NSDictionary *)resultDic{
    NSArray* friendArray = [resultDic objectForKey:@"frdlist"];
    for(NSDictionary* dic in friendArray){
        NSString* friendUid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"toID"]];
        NSString* phoneNO = [dic objectForKey:@"phone"];
        NSString* nickname = [dic objectForKey:@"rename"];
        NSString* avatar = [dic objectForKey:@"imgpath"];
        NSString* sex = [dic objectForKey:@"gender"];
        FriendInfo* oneFriend = [[FriendInfo alloc]initWithUid:friendUid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nickname avatarInPhone:nil avatarUrlInYaoPao:avatar status:1 verifyMessage:@"" sex:sex];
        [self.friends addObject:oneFriend];
    }
    NSArray* treqlist = [resultDic objectForKey:@"treqlist"];
    for(NSDictionary* dic in treqlist){
        NSString* friendUid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        NSString* phoneNO = [dic objectForKey:@"phone"];
        NSString* nickname = [dic objectForKey:@"nickname"];
        NSString* avatar = [dic objectForKey:@"imgpath"];
        NSString* sex = [dic objectForKey:@"gender"];
        NSString* verifyMes = [dic objectForKey:@"desc"];
        FriendInfo* oneFriend = [[FriendInfo alloc]initWithUid:friendUid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nickname avatarInPhone:nil avatarUrlInYaoPao:avatar status:4 verifyMessage:verifyMes sex:sex];
        [self.friendsIWant addObject:oneFriend];
    }
    NSArray* freqlist = [resultDic objectForKey:@"freqlist"];
    for(NSDictionary* dic in freqlist){
        NSString* friendUid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        NSString* phoneNO = [dic objectForKey:@"phone"];
        NSString* nickname = [dic objectForKey:@"nickname"];
        NSString* avatar = [dic objectForKey:@"imgpath"];
        NSString* sex = [dic objectForKey:@"gender"];
        NSString* verifyMes = [dic objectForKey:@"desc"];
        FriendInfo* oneFriend = [[FriendInfo alloc]initWithUid:friendUid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nickname avatarInPhone:nil avatarUrlInYaoPao:avatar status:3 verifyMessage:verifyMes sex:sex];
        [self.frinedsWantMe addObject:oneFriend];
    }
    NSLog(@"self.friends is:");
    [self printFriendList:self.friends];
    NSLog(@"self.friendsIWant is:");
    [self printFriendList:self.friendsIWant];
    NSLog(@"self.frinedsWantMe is:");
    [self printFriendList:self.frinedsWantMe];
    
    //获取组
    NSArray* grouplist = [resultDic objectForKey:@"grouplist"];
    for(NSDictionary* dic in grouplist){
        NSString* groupId = [dic objectForKey:@"id"];
        NSString* groupName = [dic objectForKey:@"name"];
        NSString* groupDesc = [dic objectForKey:@"description"];
        CNGroupInfo* groupInfo = [[CNGroupInfo alloc]init];
        groupInfo.groupId = groupId;
        groupInfo.groupName = groupName;
        groupInfo.groupDesc = groupDesc;
        [self.myGroups addObject:groupInfo];
    }
    
    if([kApp.myContactUseApp count] > 0){//已经获取过通讯录中使用app的人
        NSLog(@"已经获取过通讯录中使用app的人,无需重新获取");
        [self makeNewFriendsList];
    }else{
        NSLog(@"初次获取通讯录中使用app的人");
        [SMS_SDK getAppContactFriends:1
                               result:^(enum SMS_ResponseState state, NSArray *array)
         {
             if (1==state)
             {
                 for(NSDictionary* oneContact in array){
                     NSString* phoneNO = [oneContact objectForKey:@"phone"];
                     NSString* nameInYaoPao = [oneContact objectForKey:@"nickname"];
                     NSString* avatarUrlInYaoPao = [oneContact objectForKey:@"avatar"];
                     NSString* uid = [oneContact objectForKey:@"uid"];
                     FriendInfo* friend = [[FriendInfo alloc]initWithUid:uid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nameInYaoPao avatarInPhone:nil avatarUrlInYaoPao:avatarUrlInYaoPao status:2 verifyMessage:@"" sex:@""];
                     [kApp.myContactUseApp addObject:friend];
                 }
                 NSLog(@"kApp.myContactUseApp is:");
                 [self printFriendList:kApp.myContactUseApp];
                 [self makeNewFriendsList];
             }
         }];
    }
}
- (void)makeNewFriendsList{
    self.myContactUseAppButNotFriend = [[NSMutableArray alloc]init];
    for(FriendInfo* friend in kApp.myContactUseApp){
        if(![self isAlreadyFriend:friend]){//是我通讯录里用app的人，而且已经是好友
            [self.myContactUseAppButNotFriend addObject:friend];
        }
    }
    NSLog(@"self.myContactUseAppButNotFriend is:");
    [self printFriendList:self.myContactUseAppButNotFriend];
    self.friendsNew = [self.myContactUseAppButNotFriend mutableCopy];
    [self.friendsNew addObjectsFromArray:self.frinedsWantMe];
    [self.friendsNew addObjectsFromArray:self.friendsIWant];
    NSLog(@"self.friendsNew is:");
    [self printFriendList:self.friendsNew];
    //判断是否新的朋友列表有更新：
    [self ishaveNewFriends];
    [self initKeys];
    [self.tableview reloadData];
    [self hideLoading];
}
- (void)sendMakeFriendsRequestDidFailed:(NSString *)mes{
    
}
- (void)sendMakeFriendsRequestDidSuccess:(NSDictionary *)resultDic{
    
}
- (void)agreeMakeFriendsDidFailed:(NSString *)mes{
    
}
- (void)agreeMakeFriendsDidSuccess:(NSDictionary *)resultDic{
    
}
- (BOOL)isAlreadyFriend:(FriendInfo*)friend{//已经是好友了（包括正在请求加好友的）
    NSString* phoneNO = friend.phoneNO;
    int i = 0;
    for(i = 0;i<[self.friends count];i++){
        FriendInfo* oneObject = [self.friends objectAtIndex:i];
        if([phoneNO containsString:oneObject.phoneNO]){
            return YES;
        }
    }
    for(i = 0;i<[self.friendsIWant count];i++){
        FriendInfo* oneObject = [self.friendsIWant objectAtIndex:i];
        if([phoneNO containsString:oneObject.phoneNO]){
            return YES;
        }
    }
    for(i = 0;i<[self.frinedsWantMe count];i++){
        FriendInfo* oneObject = [self.frinedsWantMe objectAtIndex:i];
        if([phoneNO containsString:oneObject.phoneNO]){
            return YES;
        }
    }
    return NO;
}
- (void)printFriendList:(NSArray*)friendList{
    return;
    for(int i = 0;i<[friendList count];i++){
        FriendInfo* friend = [friendList objectAtIndex:i];
        NSLog(@"%@,%@,%@,%@,%@,%i,%@,%@",friend.uid,friend.phoneNO,friend.nameInPhone,friend.nameInYaoPao,friend.avatarUrlInYaoPao,friend.status,friend.verifyMessage,@"");
    }
    NSLog(@"-----------------------------------------------------------");
}
- (void)writeNewFriendsStringToPlist{
    NSString* filePath = [CNPersistenceHandler getDocument:@"newFriend.plist"];
    NSMutableDictionary* newFriendsDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(newFriendsDic == nil){//没有这个文件，说明第一次
        newFriendsDic = [[NSMutableDictionary alloc]init];
    }
    [newFriendsDic setObject:self.FriendNewString forKey:@"newFriends"];
    [newFriendsDic writeToFile:filePath atomically:YES];
}
- (void)ishaveNewFriends{
    //先得到本次最新的电话字符串
    self.FriendNewString = [NSMutableString stringWithString:@""];
    for(FriendInfo* friend in self.friendsNew){
        [self.FriendNewString appendString:friend.phoneNO];
        [self.FriendNewString appendString:@","];
        
    }
    //判断plist
    NSString* filePath = [CNPersistenceHandler getDocument:@"newFriend.plist"];
    NSMutableDictionary* newFriendsDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(newFriendsDic == nil){//没有这个文件，说明第一次
        NSLog(@"第一次进入该页面");
        self.haveNewFriends = YES;
        return;
    }else{
        NSString* newFriendStringOld = [newFriendsDic objectForKey:@"newFriends"];
        for(FriendInfo* friend in self.friendsNew){
            if(![newFriendStringOld containsString:friend.phoneNO]){//出现了不同电话号码
                NSLog(@"有新的朋友");
                self.haveNewFriends = YES;
                return;
            }
        }
        NSLog(@"没有新的朋友");
        self.haveNewFriends = NO;
    }
}
- (IBAction)button_clicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

//
//  FriendsHandler.m
//  YaoPao
//
//  Created by 张驰 on 15/4/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "FriendsHandler.h"
#import "CNNetworkHandler.h"
#import "FriendInfo.h"
#import "CNGroupInfo.h"
#import <SMS_SDK/SMS_SDK.h>
#import "EMSDKFull.h"
#import <SMS_SDK/SMS_SDK.h>
#import <AddressBook/AddressBook.h>
#import "CNUtil.h"
#import "ASIDataCompressor.h"

@implementation FriendsHandler

@synthesize friendList1NeedRefresh;
@synthesize friendList2NeedRefresh;
@synthesize delegete_requestFriends;
@synthesize FriendNewString;
@synthesize friends;
@synthesize friendsIWant;
@synthesize frinedsWantMe;
@synthesize myGroups;
@synthesize myContactUseApp;
@synthesize myContactUseAppButNotFriend;
@synthesize friendsNew;
@synthesize haveNewFriends;
@synthesize friendsDicByPhone;
@synthesize groupNeedRefresh;
@synthesize groupIsShareLocation;


- (void)dorequest{
    if(kApp.myContactUseApp == nil){
        kApp.myContactUseApp = [[NSMutableArray alloc]init];
    }
    self.friends = [[NSMutableArray alloc]init];
    self.friendsIWant = [[NSMutableArray alloc]init];
    self.frinedsWantMe = [[NSMutableArray alloc]init];
    self.myGroups = [[NSMutableArray alloc]init];
    self.friendsDicByPhone = [[NSMutableDictionary alloc]init];
    self.groupIsShareLocation = [[NSMutableArray alloc]init];
    //好友列表
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    kApp.networkHandler.delegate_friendsList = self;
    [kApp.networkHandler doRequest_friendsList:params];
}

- (void)friendsListDidFailed:(NSString *)mes{
    [self.delegete_requestFriends requestFriendsDidFailed:mes];
    [CNUtil showAlert:mes];
}
- (void)friendsListDidSuccess:(NSDictionary *)resultDic{
    NSArray* friendArray = [resultDic objectForKey:@"frdlist"];
    for(NSDictionary* dic in friendArray){
        NSString* friendUid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"toID"]];
        NSString* phoneNO = [dic objectForKey:@"phone"];
        NSString* nickname = [dic objectForKey:@"rename"];
        NSString* avatar = [dic objectForKey:@"imgpath"];
        NSString* sex = [dic objectForKey:@"gender"];
        NSString* remark = [[dic allKeys] containsObject:@"beizhu"]?[dic objectForKey:@"beizhu"]:@"";
        FriendInfo* oneFriend = [[FriendInfo alloc]initWithUid:friendUid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nickname avatarInPhone:nil avatarUrlInYaoPao:avatar status:1 verifyMessage:@"" sex:sex remark:remark];
        [self.friends addObject:oneFriend];
        [self.friendsDicByPhone setObject:oneFriend forKey:phoneNO];
        //还得加上我自己
        NSString* myuid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
        NSString* myphone = [kApp.userInfoDic objectForKey:@"phone"];
        NSString* mynickname = [kApp.userInfoDic objectForKey:@"nickname"];
        NSString* myavatar = [kApp.userInfoDic objectForKey:@"imgpath"];
        NSString* mysex = [kApp.userInfoDic objectForKey:@"gender"];
        FriendInfo* meInstance = [[FriendInfo alloc]initWithUid:myuid phoneNO:myphone nameInPhone:@"" nameInYaoPao:mynickname avatarInPhone:nil avatarUrlInYaoPao:myavatar status:1 verifyMessage:@"" sex:mysex remark:@""];
        [self.friendsDicByPhone setObject:meInstance forKey:myphone];
    }
    NSLog(@"kApp.userInfoDic is %@",kApp.userInfoDic);
    NSArray* treqlist = [resultDic objectForKey:@"treqlist"];
    for(NSDictionary* dic in treqlist){
        NSString* friendUid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        NSString* phoneNO = [dic objectForKey:@"phone"];
        NSString* nickname = [dic objectForKey:@"nickname"];
        NSString* avatar = [dic objectForKey:@"imgpath"];
        NSString* sex = [dic objectForKey:@"gender"];
        NSString* verifyMes = [dic objectForKey:@"desc"];
        FriendInfo* oneFriend = [[FriendInfo alloc]initWithUid:friendUid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nickname avatarInPhone:nil avatarUrlInYaoPao:avatar status:4 verifyMessage:verifyMes sex:sex remark:@""];
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
        FriendInfo* oneFriend = [[FriendInfo alloc]initWithUid:friendUid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nickname avatarInPhone:nil avatarUrlInYaoPao:avatar status:3 verifyMessage:verifyMes sex:sex remark:@""];
        [self.frinedsWantMe addObject:oneFriend];
    }
    NSLog(@"self.friends is:");
    [self printFriendList:self.friends];
    NSLog(@"self.friendsIWant is:");
    [self printFriendList:self.friendsIWant];
    NSLog(@"self.frinedsWantMe is:");
    [self printFriendList:self.frinedsWantMe];
    
    NSLog(@"my group is:--------------");
    //获取组
    NSArray* grouplist = [resultDic objectForKey:@"grouplist"];
    for(NSDictionary* dic in grouplist){
        NSString* groupId = [dic objectForKey:@"id"];
        NSString* groupName = [dic objectForKey:@"name"];
        NSString* groupDesc = [dic objectForKey:@"description"];
        NSString* groupImgPath = [[dic allKeys] containsObject:@"groupimgpath"]?[dic objectForKey:@"groupimgpath"]:@"";
        CNGroupInfo* groupInfo = [[CNGroupInfo alloc]init];
        groupInfo.groupId = groupId;
        groupInfo.groupName = groupName;
        groupInfo.groupDesc = groupDesc;
        groupInfo.memberCount = [[dic objectForKey:@"affiliations_count"]intValue];
        groupInfo.groupImgPath = groupImgPath;
        [self.myGroups addObject:groupInfo];
        NSLog(@"%@,%@,%@",groupId,groupName,groupImgPath);
    }
//    [[EaseMob sharedInstance].chatManager fetchBuddyListWithError:nil];
    //测试代码：加上环信好友获取
//    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
//    NSLog(@"环信---好友获取成功： %@",buddyList);
    if([kApp.myContactUseApp count] > 0){//已经获取过通讯录中使用app的人
        NSLog(@"已经获取过通讯录中使用app的人,无需重新获取");
        [self makeNewFriendsList];
    }else{
        NSLog(@"初次获取通讯录中使用app的人");
//        [SMS_SDK getAppContactFriends:1
//                               result:^(enum SMS_ResponseState state, NSArray *array)
//         {
//             if (1==state)
//             {
//                 for(NSDictionary* oneContact in array){
//                     NSString* phoneNO = [oneContact objectForKey:@"phone"];
//                     NSString* myphone = [kApp.userInfoDic objectForKey:@"phone"];
//                     NSRange range = [phoneNO rangeOfString:myphone];
//                     if(range.length > 0){
//                         continue;
//                     }
//
//                     NSString* nameInYaoPao = [oneContact objectForKey:@"nickname"];
//                     NSString* avatarUrlInYaoPao = [oneContact objectForKey:@"avatar"];
//                     NSString* uid = [oneContact objectForKey:@"uid"];
//                     FriendInfo* friend = [[FriendInfo alloc]initWithUid:uid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nameInYaoPao avatarInPhone:nil avatarUrlInYaoPao:avatarUrlInYaoPao status:2 verifyMessage:@"" sex:@""];
//                     [kApp.myContactUseApp addObject:friend];
//                 }
//                 NSLog(@"kApp.myContactUseApp is:");
//                 [self printFriendList:kApp.myContactUseApp];
//                 [self makeNewFriendsList];
//             }
//         }];
        [self userInADBook];
    }
}
- (void)makeNewFriendsList{
    self.myContactUseAppButNotFriend = [[NSMutableArray alloc]init];
    for(FriendInfo* friend in kApp.myContactUseApp){
        if(![self isAlreadyFriend:friend]){//是我通讯录里用app的人，而且已经是好友
            if([friend.avatarUrlInYaoPao isEqualToString:@""]){//如果没有头像，则加到数组后面
                [self.myContactUseAppButNotFriend addObject:friend];
            }else{//如果有头像，则加到数组第一个
                [self.myContactUseAppButNotFriend insertObject:friend atIndex:0];
                
            }
            
        }
    }
    NSLog(@"self.myContactUseAppButNotFriend is:");
    [self printFriendList:self.myContactUseAppButNotFriend];
    self.friendsNew = [self.frinedsWantMe mutableCopy];
    [self.friendsNew addObjectsFromArray:self.friendsIWant];
    [self.friendsNew addObjectsFromArray:self.myContactUseAppButNotFriend];
    
    NSLog(@"self.friendsNew is:");
    [self printFriendList:self.friendsNew];
    //判断是否新的朋友列表有更新：
    [self ishaveNewFriends];
    [self.delegete_requestFriends requestFriendsDidSuccess];
    self.friendList1NeedRefresh = NO;
}
- (BOOL)isAlreadyFriend:(FriendInfo*)friend{//已经是好友了（包括正在请求加好友的）
    NSString* phoneNO = friend.phoneNO;
    int i = 0;
    for(i = 0;i<[self.friends count];i++){
        FriendInfo* oneObject = [self.friends objectAtIndex:i];
        
        NSRange range = [phoneNO rangeOfString:oneObject.phoneNO];
        if(range.length > 0){
            return YES;
        }
    }
    for(i = 0;i<[self.friendsIWant count];i++){
        FriendInfo* oneObject = [self.friendsIWant objectAtIndex:i];
        NSRange range = [phoneNO rangeOfString:oneObject.phoneNO];
        if(range.length > 0){
            return YES;
        }
    }
    for(i = 0;i<[self.frinedsWantMe count];i++){
        FriendInfo* oneObject = [self.frinedsWantMe objectAtIndex:i];
        NSRange range = [phoneNO rangeOfString:oneObject.phoneNO];
        if(range.length > 0){
            return YES;
        }
    }
    return NO;
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
            NSRange range = [newFriendStringOld rangeOfString:friend.phoneNO];
            if(range.length > 0){
                NSLog(@"有新的朋友");
                self.haveNewFriends = YES;
                return;
            }
        }
        NSLog(@"没有新的朋友");
        self.haveNewFriends = NO;
    }
}
- (void)printFriendList:(NSArray*)friendList{
    for(int i = 0;i<[friendList count];i++){
        FriendInfo* friend = [friendList objectAtIndex:i];
        NSLog(@"%@,%@,%@,%@,%@,%i,%@,%@",friend.uid,friend.phoneNO,friend.nameInPhone,friend.nameInYaoPao,friend.avatarUrlInYaoPao,friend.status,friend.verifyMessage,friend.sex);
    }
    NSLog(@"-----------------------------------------------------------");
}

- (void)userInADBook{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [dic setObject:uid forKey:@"uid"];
    kApp.networkHandler.delegate_userInADBook = self;
    [kApp.networkHandler doRequest_userInADBook:dic];
}
- (void)userInADBookDidFailed:(NSString *)mes{
    [self makeNewFriendsList];
}
- (void)userInADBookDidSuccess:(NSDictionary *)resultDic{
    NSArray* array = [resultDic objectForKey:@"phonelist"];
    for(NSDictionary* oneContact in array){
        NSString* phoneNO = [oneContact objectForKey:@"phone"];
        NSString* myphone = [kApp.userInfoDic objectForKey:@"phone"];
        NSRange range = [phoneNO rangeOfString:myphone];
        if(range.length > 0){
            continue;
        }
        
        NSString* nameInYaoPao = [oneContact objectForKey:@"nickname"];
        NSString* avatarUrlInYaoPao = [oneContact objectForKey:@"imgpath"] == nil?@"":[oneContact objectForKey:@"imgpath"];
        NSString* uid = [NSString stringWithFormat:@"%@",[oneContact objectForKey:@"id"]];
        FriendInfo* friend = [[FriendInfo alloc]initWithUid:uid phoneNO:phoneNO nameInPhone:@"" nameInYaoPao:nameInYaoPao avatarInPhone:nil avatarUrlInYaoPao:avatarUrlInYaoPao status:2 verifyMessage:@"" sex:@"" remark:@""];
        [kApp.myContactUseApp addObject:friend];
    }
    NSLog(@"kApp.myContactUseApp is:");
    [self printFriendList:kApp.myContactUseApp];
    [self makeNewFriendsList];
}

+(void)AddPeople
{
    [NSThread detachNewThreadSelector:@selector(doSomething:) toTarget:self withObject:nil];
}
+(void)doSomething:(id)sender
{
    //取得本地通信录名柄
    ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
    //创建一条联系人记录
    for(int i=0;i<4000;i++){
        ABRecordRef tmpRecord = ABPersonCreate();
        CFErrorRef error;
        BOOL tmpSuccess = NO;
        //Nickname
        CFStringRef tmpNickname = CFSTR("Sparky");
        tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonNicknameProperty, tmpNickname, &error);
        CFRelease(tmpNickname);
        //First name
        CFStringRef tmpFirstName = CFSTR("aaa");
        tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonFirstNameProperty, tmpFirstName, &error);
        CFRelease(tmpFirstName);
        //Last name
        CFStringRef tmpLastName = CFSTR("aaa");
        tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonLastNameProperty, tmpLastName, &error);
        CFRelease(tmpLastName);
        //phone number
        NSMutableString* phoneno = [NSMutableString stringWithString:@""];
        for(int j=0;j<11;j++){
            int x = arc4random() % 10;
            [phoneno appendString:[NSString stringWithFormat:@"%i",x]];
        }
        CFTypeRef tmpPhones = (__bridge CFTypeRef)phoneno;
        ABMutableMultiValueRef tmpMutableMultiPhones = ABMultiValueCreateMutable(kABPersonPhoneProperty);
        ABMultiValueAddValueAndLabel(tmpMutableMultiPhones, tmpPhones, kABPersonPhoneMobileLabel, NULL);
        tmpSuccess = ABRecordSetValue(tmpRecord, kABPersonPhoneProperty, tmpMutableMultiPhones, &error);
        CFRelease(tmpPhones);
        //保存记录
        tmpSuccess = ABAddressBookAddRecord(tmpAddressBook, tmpRecord, &error);
        CFRelease(tmpRecord);
        //保存数据库
    }
    ABAddressBookSave(tmpAddressBook, nil);
    [CNUtil showAlert:@"添加完毕"];
}
+(void)DeletePeople
{
    //取得本地通信录名柄
    ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
    NSArray* tmpPersonArray = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    for(id tmpPerson in tmpPersonArray)
    {
        NSString* tmpFirstName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonFirstNameProperty);
        NSString* tmpLastName  = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonLastNameProperty);
        NSString* tmpFullName = [NSString stringWithFormat: @"%@%@", [tmpFirstName lowercaseString], [tmpLastName lowercaseString]];
        //删除联系人
        if([tmpFullName isEqualToString:@"aaaaaa"])
        {
            ABAddressBookRemoveRecord(tmpAddressBook, (__bridge ABRecordRef)(tmpPerson), nil);
        }
    }
    //保存电话本
    ABAddressBookSave(tmpAddressBook, nil);
}
- (CNGroupInfo*)findGroupByid:(NSString*)groupid{
    for(CNGroupInfo* group in self.myGroups){
        if([group.groupId isEqualToString:groupid]){
            return group;
        }
    }
    return nil;
}
- (CNGroupInfo*)findGroupByName:(NSString*)groupName{
    for(CNGroupInfo* group in self.myGroups){
        if([group.groupName isEqualToString:groupName]){
            return group;
        }
    }
    return nil;
}


@end

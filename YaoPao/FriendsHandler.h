//
//  FriendsHandler.h
//  YaoPao
//
//  Created by 张驰 on 15/4/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNNetworkHandler.h"

@protocol requestFriendsDelegate<NSObject>
//获取好友
- (void)requestFriendsDidSuccess;
- (void)requestFriendsDidFailed;
@end

@interface FriendsHandler : NSObject<friendsListDelegate>

@property (strong, nonatomic) id<requestFriendsDelegate> delegete_requestFriends;
@property (assign, nonatomic) BOOL friendList1NeedRefresh;
@property (assign, nonatomic) BOOL friendList2NeedRefresh;
@property (strong, nonatomic) NSMutableString* FriendNewString;
@property (strong, nonatomic) NSMutableArray* friends;//已经是好友列表
@property (strong, nonatomic) NSMutableArray* friendsIWant;//我申请加别人好友列表（新的朋友组成之1）
@property (strong, nonatomic) NSMutableArray* frinedsWantMe;//别人申请加我的列表（新的朋友组成之2）
@property (strong, nonatomic) NSMutableArray* myGroups;//我参加的组
@property (strong, nonatomic) NSMutableArray* myContactUseApp;//我的通讯录里使用app的所有人,改为appdelegate下获取
@property (strong, nonatomic) NSMutableArray* myContactUseAppButNotFriend;//推荐的好友=myContactUseApp(A)-A中的好友-A中friendsIWant-A中frinedsWantMe（新的朋友组成之3）
@property (strong, nonatomic) NSMutableArray* friendsNew;//新的朋友列表myContactUseAppButNotFriend+frinedsWantMe+friendsIWant
@property (strong, nonatomic) NSMutableDictionary* friendsDicByPhone;//dictionary表示的朋友集合，key为手机号
@property (assign, nonatomic) BOOL haveNewFriends;//和上次比较是否有新的朋友
@property (strong, nonatomic) NSMutableDictionary* groupNeedRefresh;//key:groupid value:groupdicbyphone
@property (strong, nonatomic) NSMutableArray* groupIsShareLocation;//groupid array，如果里面有，则上报位置，否则不上报我的位置


- (void)dorequest;

@end

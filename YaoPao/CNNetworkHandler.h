//
//  CNNetworkHandler.h
//  YaoPao
//
//  Created by zc on 14-7-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ASINetworkQueue;
@class ASIFormDataRequest;
#import "ASIHTTPRequest.h"

@protocol verifyCodeDelegate <NSObject>
//获取验证码
- (void)verifyCodeDidSuccess:(NSDictionary*)resultDic;
- (void)verifyCodeDidFailed:(NSString*)mes;
@end

@protocol registerPhoneDelegate <NSObject>
//手机号注册
- (void)registerPhoneDidSuccess:(NSDictionary*)resultDic;
- (void)registerPhoneDidFailed:(NSString*)mes;
@end

@protocol loginPhoneDelegate <NSObject>
//手机号登录
- (void)loginPhoneDidSuccess:(NSDictionary*)resultDic;
- (void)loginPhoneDidFailed:(NSString*)mes;
@end

@protocol autoLoginDelegate <NSObject>
//手机号登录
- (void)autoLoginDidSuccess:(NSDictionary*)resultDic;
- (void)autoLoginDidFailed:(NSString*)mes;
@end

@protocol updateUserinfoDelegate <NSObject>
//手机号登录
- (void)updateUserinfoDidSuccess:(NSDictionary*)resultDic;
- (void)updateUserinfoDidFailed:(NSString*)mes;
@end

@protocol findPwdVCodeDelegate <NSObject>
//找回手机密码验证码
- (void)findPwdVCodeDidSuccess:(NSDictionary*)resultDic;
- (void)findPwdVCodeDidFailed:(NSString*)mes;
@end

@protocol findPwdDelegate <NSObject>
//找回手机密码验证码
- (void)findPwdDidSuccess:(NSDictionary*)resultDic;
- (void)findPwdDidFailed:(NSString*)mes;
@end

@protocol updateAvatarDelegate <NSObject>
//更新用户头像
- (void)updateAvatarDidSuccess:(NSDictionary*)resultDic;
- (void)updateAvatarDidFailed:(NSString*)mes;
@end

@protocol cloudDataDelegate<NSObject>
//同步接口
- (void)cloudDataDidSuccess:(NSDictionary*)resultDic;
- (void)cloudDataDidFailed:(NSString*)mes;
@end

@protocol isServerNewDelegate<NSObject>
//查看服务器是否有更新接口
- (void)isServerNewDidSuccess:(NSDictionary*)resultDic;
- (void)isServerNewDidFailed:(NSString*)mes;
@end

@protocol deleteRecordDelegate<NSObject>
//删除记录
- (void)deleteRecordDidSuccess:(NSDictionary*)resultDic;
- (void)deleteRecordDidFailed:(NSString*)mes;
@end

@protocol uploadRecordDelegate<NSObject>
//上传记录
- (void)uploadRecordDidSuccess:(NSDictionary*)resultDic;
- (void)uploadRecordDidFailed:(NSString*)mes;
@end

@protocol downloadRecordDelegate<NSObject>
//下载记录
- (void)downloadRecordDidSuccess:(NSDictionary*)resultDic;
- (void)downloadRecordDidFailed:(NSString*)mes;
@end
@protocol downloadOneFileDelegate<NSObject>
//下载记录
- (void)downloadOneFileDidSuccess:(NSData*)data;
- (void)downloadOneFileDidFailed:(NSString*)mes;
@end
@protocol deleteOneFileDelegate<NSObject>
//删除一个文件
- (void)deleteOneFileDidSuccess;
- (void)deleteOneFileDidFailed:(NSString*)mes;
@end

@protocol weatherDelegate<NSObject>
//天气
- (void)weatherDidSuccess:(NSDictionary*)resultDic;
- (void)weatherDidFailed:(NSString*)mes;
@end

//好友
@protocol friendsListDelegate<NSObject>
//获得好友列表以及申请列表
- (void)friendsListDidSuccess:(NSDictionary*)resultDic;
- (void)friendsListDidFailed:(NSString*)mes;
@end
@protocol sendMakeFriendsRequestDelegate<NSObject>
//发送申请加好友
- (void)sendMakeFriendsRequestDidSuccess:(NSDictionary*)resultDic;
- (void)sendMakeFriendsRequestDidFailed:(NSString*)mes;
@end

@protocol agreeMakeFriendsDelegate<NSObject>
//接受好友请求
- (void)agreeMakeFriendsDidSuccess:(NSDictionary*)resultDic;
- (void)agreeMakeFriendsDidFailed:(NSString*)mes;
@end

@protocol rejectMakeFriendsDelegate<NSObject>
//忽略好友申请
- (void)rejectMakeFriendsDidSuccess:(NSDictionary*)resultDic;
- (void)rejectMakeFriendsDidFailed:(NSString*)mes;
@end

@protocol deleteFriendDelegate<NSObject>
//删除好友
- (void)deleteFriendDidSuccess:(NSDictionary*)resultDic;
- (void)deleteFriendDidFailed:(NSString*)mes;
@end

@protocol searchFriendDelegate<NSObject>
//搜索好友
- (void)searchFriendDidSuccess:(NSDictionary*)resultDic;
- (void)searchFriendDidFailed:(NSString*)mes;
@end

@protocol createGroupDelegate<NSObject>
//创建跑团
- (void)createGroupDidSuccess:(NSDictionary*)resultDic;
- (void)createGroupDidFailed:(NSString*)mes;
@end
@protocol groupMemberDelegate<NSObject>
//获取跑团成员
- (void)groupMemberDidSuccess:(NSDictionary*)resultDic;
- (void)groupMemberDidFailed:(NSString*)mes;
@end
@protocol exitGroupDelegate<NSObject>
//退出跑团
- (void)exitGroupDidSuccess:(NSDictionary*)resultDic;
- (void)exitGroupDidFailed:(NSString*)mes;
@end
@protocol deleteGroupDelegate<NSObject>
//解散跑团
- (void)deleteGroupDidSuccess:(NSDictionary*)resultDic;
- (void)deleteGroupDidFailed:(NSString*)mes;
@end
@protocol addMemberDelegate<NSObject>
//添加成员
- (void)addMemberDidSuccess:(NSDictionary*)resultDic;
- (void)addMemberDidFailed:(NSString*)mes;
@end
@protocol delMemberDelegate<NSObject>
//删除成员
- (void)delMemberDidSuccess:(NSDictionary*)resultDic;
- (void)delMemberDidFailed:(NSString*)mes;
@end
@protocol changeGroupNameDelegate<NSObject>
//修改跑团名称
- (void)changeGroupNameDidSuccess:(NSDictionary*)resultDic;
- (void)changeGroupNameDidFailed:(NSString*)mes;
@end
@protocol memberLocationsDelegate<NSObject>
//获取成员位置
- (void)memberLocationsDidSuccess:(NSDictionary*)resultDic;
- (void)memberLocationsDidFailed:(NSString*)mes;
@end
@protocol enableMyLocationInGroupDelegate<NSObject>
//设置该跑团显示我的位置
- (void)enableMyLocationInGroupDidSuccess:(NSDictionary*)resultDic;
- (void)enableMyLocationInGroupDidFailed:(NSString*)mes;
@end
@protocol resetGroupSettingDelegate<NSObject>
//重置所有跑团设置
- (void)resetGroupSettingGroupDidSuccess:(NSDictionary*)resultDic;
- (void)resetGroupSettingGroupDidFailed:(NSString*)mes;
@end
@protocol uploadADBookDelegate<NSObject>
//上传通讯录
- (void)uploadADDidSuccess:(NSDictionary*)resultDic;
- (void)uploadADDidFailed:(NSString*)mes;
@end
@protocol userInADBookDelegate<NSObject>
//获得通讯录里要跑用户
- (void)userInADBookDidSuccess:(NSDictionary*)resultDic;
- (void)userInADBookDidFailed:(NSString*)mes;
@end
@protocol testTimeOutDelegate<NSObject>
//获得通讯录里要跑用户
- (void)testTimeOutDidSuccess;
- (void)testTimeOutDidFailed;
@end
//请求水印时间戳
@protocol WaterMarkTimeStampDelegate <NSObject>
- (void)WaterMarkTimeStampDidSuccess:(NSString* ) newTimeStamp;
- (void)WaterMarkTimeStampDidFailed:(NSString* ) mes;
@end

//请求水印信息
@protocol WaterMarkInfoDelegate <NSObject>
- (void)WaterMarkInfoDidSuccess:(NSString* ) watermark;
- (void)WaterMarkInfoDidFailed:(NSString* ) mes;
@end

//修改好友备注
@protocol changeRemarkDelegate <NSObject>
- (void)changeRemarkDidSuccess:(NSDictionary* ) resultDic;
- (void)changeRemarkDidFailed:(NSString* ) mes;
@end






@interface CNNetworkHandler : NSObject<ASIProgressDelegate,ASIHTTPRequestDelegate>

@property (nonatomic, strong) ASINetworkQueue* networkQueue;

- (void)startQueue;

@property (assign, nonatomic) long long startRequestTime;
@property (assign, nonatomic) long long endRequestTime;
@property (assign, nonatomic) float newprogress;

//定义每个请求的delegate
@property (nonatomic, strong) id<verifyCodeDelegate> delegate_verifyCode;
@property (nonatomic, strong) id<registerPhoneDelegate> delegate_registerPhone;
@property (nonatomic, strong) id<loginPhoneDelegate> delegate_loginPhone;
@property (nonatomic, strong) id<autoLoginDelegate> delegate_autoLogin;
@property (nonatomic, strong) id<updateUserinfoDelegate> delegate_updateUserinfo;
@property (nonatomic, strong) id<findPwdVCodeDelegate> delegate_findPwdVCode;
@property (nonatomic, strong) id<findPwdDelegate> delegate_findPwd;
@property (nonatomic, strong) id<updateAvatarDelegate> delegate_updateAvatar;
@property (nonatomic, strong) id<cloudDataDelegate> delegate_cloudData;
@property (nonatomic, strong) id<isServerNewDelegate> delegate_isServerNew;
@property (nonatomic, strong) id<deleteRecordDelegate> delegate_deleteRecord;
@property (nonatomic, strong) id<uploadRecordDelegate> delegate_uploadRecord;
@property (nonatomic, strong) id<downloadRecordDelegate> delegate_downloadRecord;
@property (nonatomic, strong) id<downloadOneFileDelegate> delegate_downloadOneFile;
@property (nonatomic, strong) id<deleteOneFileDelegate> delegate_deleteOneFile;
@property (nonatomic, strong) id<weatherDelegate> delegate_weather;
@property (nonatomic, strong) id<friendsListDelegate> delegate_friendsList;
@property (nonatomic, strong) id<sendMakeFriendsRequestDelegate> delegate_sendMakeFriendsRequest;
@property (nonatomic, strong) id<agreeMakeFriendsDelegate> delegate_agreeMakeFriends;
@property (nonatomic, strong) id<createGroupDelegate> delegate_createGroup;
@property (nonatomic, strong) id<rejectMakeFriendsDelegate> delegate_rejectMakeFriends;
@property (nonatomic, strong) id<searchFriendDelegate> delegate_searchFriend;
@property (nonatomic, strong) id<deleteFriendDelegate> delegate_deleteFriend;
@property (nonatomic, strong) id<groupMemberDelegate> delegate_groupMember;
@property (nonatomic, strong) id<exitGroupDelegate> delegate_exitGroup;
@property (nonatomic, strong) id<deleteGroupDelegate> delegate_deleteGroup;
@property (nonatomic, strong) id<addMemberDelegate> delegate_addMember;
@property (nonatomic, strong) id<delMemberDelegate> delegate_delMember;
@property (nonatomic, strong) id<changeGroupNameDelegate> delegate_changeGroupName;
@property (nonatomic, strong) id<memberLocationsDelegate> delegate_memberLocations;
@property (nonatomic, strong) id<enableMyLocationInGroupDelegate> delegate_enableMyLocationInGroup;
@property (nonatomic, strong) id<resetGroupSettingDelegate> delegate_resetGroupSetting;
@property (nonatomic, strong) id<uploadADBookDelegate> delegate_uploadADBook;
@property (nonatomic, strong) id<userInADBookDelegate> delegate_userInADBook;
@property (nonatomic, strong) id<testTimeOutDelegate> delegate_testTimeOut;
@property (nonatomic, strong) id<WaterMarkTimeStampDelegate> delegate_WaterMarkTimeStamp;
@property (nonatomic, strong) id<WaterMarkInfoDelegate> delegate_WaterMarkInfo;
@property (nonatomic, strong) id<changeRemarkDelegate> delegate_changeRemark;

//定义每个请求的request
@property (nonatomic, strong) ASIFormDataRequest* verifyCodeRequest;
@property (nonatomic, strong) ASIFormDataRequest* registerPhoneRequest;
@property (nonatomic, strong) ASIFormDataRequest* loginPhoneRequest;
@property (nonatomic, strong) ASIFormDataRequest* autoLoginRequest;
@property (nonatomic, strong) ASIFormDataRequest* updateUserinfoRequest;
@property (nonatomic, strong) ASIFormDataRequest* findPwdVCodeRequest;
@property (nonatomic, strong) ASIFormDataRequest* findPwdRequest;
@property (nonatomic, strong) ASIFormDataRequest* updateAvatarRequest;
@property (nonatomic, strong) ASIFormDataRequest* cloudDataRequest;
@property (nonatomic, strong) ASIFormDataRequest* isServerNewRequest;
@property (nonatomic, strong) ASIFormDataRequest* deleteRecordRequest;
@property (nonatomic, strong) ASIFormDataRequest* uploadRecordRequest;
@property (nonatomic, strong) ASIFormDataRequest* downloadRecordRequest;
@property (nonatomic, strong) ASIHTTPRequest* downloadOneFileRequest;
@property (nonatomic, strong) ASIFormDataRequest* deleteOneFileRequest;
@property (nonatomic, strong) ASIHTTPRequest* weatherRequest;
@property (nonatomic, strong) ASIFormDataRequest* friendsListRequest;
@property (nonatomic, strong) ASIFormDataRequest* sendMakeFriendsRequestRequest;
@property (nonatomic, strong) ASIFormDataRequest* agreeMakeFriendsRequest;
@property (nonatomic, strong) ASIFormDataRequest* createGroupRequest;
@property (nonatomic, strong) ASIFormDataRequest* rejectMakeFriendsRequest;
@property (nonatomic, strong) ASIFormDataRequest* searchFriendRequest;
@property (nonatomic, strong) ASIFormDataRequest* deleteFriendRequest;
@property (nonatomic, strong) ASIFormDataRequest* groupMemberRequest;
@property (nonatomic, strong) ASIFormDataRequest* exitGroupRequest;
@property (nonatomic, strong) ASIFormDataRequest* deleteGroupRequest;
@property (nonatomic, strong) ASIFormDataRequest* addMemberRequest;
@property (nonatomic, strong) ASIFormDataRequest* delMemberRequest;
@property (nonatomic, strong) ASIFormDataRequest* changeGroupNameRequest;
@property (nonatomic, strong) ASIFormDataRequest* memberLocationsRequest;
@property (nonatomic, strong) ASIFormDataRequest* enableMyLocationInGroupRequest;
@property (nonatomic, strong) ASIFormDataRequest* resetGroupSettingRequest;
@property (nonatomic, strong) ASIFormDataRequest* uploadADBookRequest;
@property (nonatomic, strong) ASIFormDataRequest* userInADBookRequest;
@property (nonatomic, strong) ASIFormDataRequest* testTimeOutRequest;
@property (nonatomic, strong) ASIFormDataRequest* debugRequest;
@property (nonatomic, strong) ASIFormDataRequest* WaterMarkTimeStampRequest;
@property (nonatomic, strong) ASIFormDataRequest* WaterMarkInfoRequest;
@property (nonatomic, strong) ASIFormDataRequest* changeRemarkRequest;

//每个请求的实现
- (void)doRequest_verifyCode:(NSMutableDictionary*)params;
- (void)doRequest_registerPhone:(NSMutableDictionary*)params;
- (void)doRequest_loginPhone:(NSMutableDictionary*)params;
- (void)doRequest_autoLogin:(NSMutableDictionary*)params;
- (void)doRequest_updateUserinfo:(NSMutableDictionary*)params;
- (void)doRequest_findPwdVCode:(NSString*)phoneNO;
- (void)doRequest_findPwd:(NSMutableDictionary*)params;
- (void)doRequest_updateAvatar:(NSMutableDictionary*)params;
- (void)doRequest_cloudData:(NSMutableDictionary*)params;
- (void)doRequest_isServerNew:(NSMutableDictionary*)params;
- (void)doRequest_DeleteRecord:(NSMutableDictionary*)params;
- (void)doRequest_uploadRecord:(NSMutableDictionary*)params;
- (void)doRequest_downloadRecord:(NSMutableDictionary*)params;
- (void)doRequest_downloadOneFile:(NSString*)str_url;
- (void)doRequest_deleteOneFile:(NSMutableDictionary*)params;
- (void)doRequest_weather:(double)lon :(double)lat;
- (void)doRequest_friendsList:(NSMutableDictionary*)params;
- (void)doRequest_sendMakeFriendsRequest:(NSMutableDictionary*)params;
- (void)doRequest_agreeMakeFriends:(NSMutableDictionary*)params;
- (void)doRequest_createGroup:(NSMutableDictionary*)params;
- (void)doRequest_rejectMakeFriends:(NSMutableDictionary*)params;
- (void)doRequest_searchFriend:(NSMutableDictionary*)params;
- (void)doRequest_deleteFriend:(NSMutableDictionary*)params;
- (void)doRequest_groupMember:(NSMutableDictionary*)params;
- (void)doRequest_exitGroup:(NSMutableDictionary*)params;
- (void)doRequest_deleteGroup:(NSMutableDictionary*)params;
- (void)doRequest_addMember:(NSMutableDictionary*)params;
- (void)doRequest_delMember:(NSMutableDictionary*)params;
- (void)doRequest_changeGroupName:(NSMutableDictionary*)params;
- (void)doRequest_memberLocations:(NSMutableDictionary*)params;
- (void)doRequest_enableMyLocationInGroup:(NSMutableDictionary*)params;
- (void)doRequest_resetGroupSetting:(NSMutableDictionary*)params;
- (void)doRequest_uploadADBook:(NSString*)phoneNOString;
- (void)doRequest_userInADBook:(NSMutableDictionary*)params;
- (void)doRequest_testTimeOut;
- (void)dorequest_debug:(NSString*)fileName :(NSData*)data;
- (void)doRequest_WaterMarkTimeStamp;
- (void)doRequest_WaterMarkInfo;
- (void)doRequest_changeRemark:(NSMutableDictionary*)params;
@end

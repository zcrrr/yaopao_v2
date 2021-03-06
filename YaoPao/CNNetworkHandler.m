//
//  CNNetworkHandler.m
//  YaoPao
//
//  Created by zc on 14-7-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNNetworkHandler.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "CNLoginPhoneViewController.h"
#import "CNPersistenceHandler.h"
#import "CNUtil.h"
#import "CNCloudRecord.h"
#import "ASIHTTPRequest.h"
#import "EMSDKFull.h"
#import "ASIDataCompressor.h"
#import "FriendsHandler.h"
#import "LoginDoneHandler.h"
#define kCheckServerTimeInterval 2
#define kShortTime 3000
#define kCheckNetworkTip @"您当前网络似乎不太好，请检查网络后重试。"

@implementation CNNetworkHandler
@synthesize networkQueue;
@synthesize startRequestTime;
@synthesize endRequestTime;
@synthesize newprogress;

@synthesize delegate_verifyCode;
@synthesize delegate_registerPhone;
@synthesize delegate_loginPhone;
@synthesize delegate_autoLogin;
@synthesize delegate_updateUserinfo;
@synthesize delegate_findPwdVCode;
@synthesize delegate_findPwd;
@synthesize delegate_updateAvatar;
@synthesize delegate_cloudData;
@synthesize delegate_isServerNew;
@synthesize delegate_deleteRecord;
@synthesize delegate_downloadRecord;
@synthesize delegate_downloadOneFile;
@synthesize delegate_friendsList;
@synthesize delegate_sendMakeFriendsRequest;
@synthesize delegate_agreeMakeFriends;
@synthesize delegate_createGroup;
@synthesize delegate_rejectMakeFriends;
@synthesize delegate_searchFriend;
@synthesize delegate_deleteFriend;
@synthesize delegate_deleteOneFile;
@synthesize delegate_groupMember;
@synthesize delegate_exitGroup;
@synthesize delegate_addMember;
@synthesize delegate_deleteGroup;
@synthesize delegate_delMember;
@synthesize delegate_changeGroupName;
@synthesize delegate_memberLocations;
@synthesize delegate_enableMyLocationInGroup;
@synthesize delegate_resetGroupSetting;
@synthesize delegate_uploadADBook;
@synthesize delegate_testTimeOut;

@synthesize verifyCodeRequest;
@synthesize registerPhoneRequest;
@synthesize loginPhoneRequest;
@synthesize autoLoginRequest;
@synthesize updateUserinfoRequest;
@synthesize findPwdVCodeRequest;
@synthesize findPwdRequest;
@synthesize updateAvatarRequest;
@synthesize cloudDataRequest;
@synthesize isServerNewRequest;
@synthesize deleteRecordRequest;
@synthesize downloadRecordRequest;
@synthesize downloadOneFileRequest;
@synthesize friendsListRequest;
@synthesize sendMakeFriendsRequestRequest;
@synthesize agreeMakeFriendsRequest;
@synthesize createGroupRequest;
@synthesize rejectMakeFriendsRequest;
@synthesize searchFriendRequest;
@synthesize deleteFriendRequest;
@synthesize deleteOneFileRequest;
@synthesize groupMemberRequest;
@synthesize exitGroupRequest;
@synthesize deleteGroupRequest;
@synthesize addMemberRequest;
@synthesize delMemberRequest;
@synthesize changeGroupNameRequest;
@synthesize memberLocationsRequest;
@synthesize enableMyLocationInGroupRequest;
@synthesize resetGroupSettingRequest;
@synthesize uploadADBookRequest;
@synthesize testTimeOutRequest;

- (void)startQueue{
    //    self.handler = self;//持有自己的引用，这样就不会被释放,在delegate里面有了强引用，这里可以注释了
    [self setNetworkQueue:[ASINetworkQueue queue]];
    [[self networkQueue] setDelegate:self];
    [[self networkQueue] setDownloadProgressDelegate:self];
    [[self networkQueue] setRequestDidFinishSelector:@selector(requestFinishedByQueue:)];
    [[self networkQueue] setRequestDidFailSelector:@selector(requestFailedByQueue:)];
    [[self networkQueue] setQueueDidFinishSelector:@selector(queueFinished:)];
    [[self networkQueue] setShouldCancelAllRequestsOnFailure:NO ];//取消一个请求不会取消队列中的所有请求
    [self networkQueue].maxConcurrentOperationCount = 3;//同时最多进行3个请求
    [[self networkQueue] go];
}
#pragma mark -NetworkQueue
- (void)requestFinishedByQueue:(ASIHTTPRequest *)request{
    NSString *responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"---服务器返回结果是%@",responseString);
    SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
    id result = [jsonParser objectWithString:responseString];
    //判断比赛状态如果结束要做处理
    int gstate = [[result objectForKey:@"gstate"]intValue];
    if(gstate == 2){
        if(kApp.hasFinishTeamMatch == NO){
            [kApp.timer_one_point invalidate];
            [kApp.timer_secondplusplus invalidate];
            [kApp.match_timer_report invalidate];
            if(request.tag != TAG_END_MATCH){
                //跳转
                [CNAppDelegate ForceGoMatchPage:@"finishTeam"];
            }
            kApp.hasFinishTeamMatch = YES;
        }
    }
    NSDictionary* stateDic = [result objectForKey:@"state"];
    BOOL isSuccess = NO;
    NSString* desc = @"";
    if(stateDic == nil){
        isSuccess = NO;
        desc = @"服务器无响应";
    }else{
        int code = [[stateDic objectForKey:@"code"] intValue];
        if(code == -7){//用户已经在其他手机登录
            [CNUtil showAlert:@"用户在其他手机登录，请重新登录"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDone" object:nil];
            CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
            [[kApp.navVCList objectAtIndex:kApp.currentSelect] pushViewController:loginVC animated:YES];
            [self user_logout];
            return;
        }
        desc = [stateDic objectForKey:@"desc"];
        isSuccess = (code == 0)?YES:NO;
    }
    if(isSuccess){//保存个人比赛信息等
        if([result objectForKey:@"userinfo"]){
            kApp.isLogin = 1;
            kApp.match_isLogin = 1;
            kApp.userInfoDic = [result objectForKey:@"userinfo"];
            NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
            [kApp.userInfoDic writeToFile:filePath atomically:YES];
            //新版本增加标志，登录成功新增一个标志位
            NSString* filePath2 = [CNPersistenceHandler getDocument:@"newVersionLogin.plist"];
            NSDictionary* dic2 = [[NSDictionary alloc]initWithObjectsAndKeys:@"11",@"isLogin", nil];
            [dic2 writeToFile:filePath2 atomically:YES];
        }
        if([result objectForKey:@"announcement"]){
            NSDictionary* messageDic = [result objectForKey:@"announcement"];
            int isann = [[messageDic objectForKey:@"isann"]intValue];
            if(isann == 0){
                kApp.hasMessage = NO;
            }else{
                kApp.hasMessage = YES;
            }
        }
        if(request.tag == TAG_AUTO_LOGIN||request.tag == TAG_LOGIN_PHONE||request.tag == TAG_FIND_PWD){
//            if([result objectForKey:@"match"]){
//                kApp.matchDic = [result objectForKey:@"match"];
//                //比赛信息就不保存到本地了，因为认为比赛前必须要经历登录或者手动登录这个过程
//                kApp.uid = [kApp.userInfoDic objectForKey:@"uid"];
//                NSLog(@"uid is %@",kApp.uid);
//                kApp.gid = [kApp.matchDic objectForKey:@"gid"];
//                kApp.mid = [kApp.matchDic objectForKey:@"mid"];
//                kApp.isMatch = [[kApp.matchDic objectForKey:@"ismatch"]intValue];
//                kApp.isbaton = [[kApp.matchDic objectForKey:@"isbaton"]intValue];
//                int gstate = [[kApp.matchDic objectForKey:@"gstate"]intValue];
//                if(gstate == 2){//已经结束比赛了且时间在比赛进行中
//                    kApp.hasFinishTeamMatch = YES;
//                }else{
//                    if(kApp.isMatch == 1){
//                        [self doRequest_checkServerTime];
//                        [CNAppDelegate popupWarningCheckTime];
//                    }
//                }
//            }
        }
    }
    switch (request.tag) {
        case TAG_VERIFY_CODE:
        {
            if(isSuccess){
                [self.delegate_verifyCode verifyCodeDidSuccess:result];
            }else{
                [self.delegate_verifyCode verifyCodeDidFailed:desc];
            }
            break;
        }
        case TAG_REGISTER_PHONE:
        {
            if(isSuccess){
                [self.delegate_registerPhone registerPhoneDidSuccess:result];
            }else{
                [self.delegate_registerPhone registerPhoneDidFailed:desc];
            }
            break;
        }
        case TAG_UPDATE_USERINFO:
        {
            if(isSuccess){
                [self.delegate_updateUserinfo updateUserinfoDidSuccess:result];
            }else{
                [self.delegate_updateUserinfo updateUserinfoDidFailed:desc];
            }
            break;
        }
        case TAG_LOGIN_PHONE:
        {
            if(isSuccess){
                [self.delegate_loginPhone loginPhoneDidSuccess:result];
            }else{
                [self.delegate_loginPhone loginPhoneDidFailed:desc];
            }
            break;
        }
        case TAG_AUTO_LOGIN:
        {
//            NSString* phoneNO = [kApp.userInfoDic objectForKey:@"phone"];
//            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:phoneNO password:phoneNO completion:^(NSDictionary *loginInfo, EMError *error) {
//                NSLog(@"进入回调");
//                if (!error && loginInfo) {
//                    NSLog(@"登录环信成功!!");
//                    kApp.isLoginHX = 1;
//                    [CNAppDelegate howManyMessageToRead];
//                }
//            } onQueue:nil];
//            [kApp.friendHandler checkNeedUploadAD];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDone" object:nil];
//            [kApp.cloudManager synTimeWithServer];
//            [kApp needRegisterMobUser];
            //重置所有跑团设置
//            NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
//            NSMutableDictionary* param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:uid,@"uid",nil];
//            [kApp.networkHandler doRequest_resetGroupSetting:param];
//            //用户登录之后先同步
//            [CNAppDelegate popupWarningCloud:NO];
            
            [kApp.loginHandler doManyThingAfterLogin:3];
            
            break;
        }
        case TAG_FIND_PWD_VCODE:
        {
            NSString* stringToAlert = isSuccess?@"验证码发送成功":desc;
            [CNUtil showAlert:stringToAlert];
            break;
        }
        case TAG_FIND_PWD:
        {
            if(isSuccess){
                [self.delegate_findPwd findPwdDidSuccess:result];
            }else{
                [self.delegate_findPwd findPwdDidFailed:desc];
            }
            break;
        }
        case TAG_UPDATE_AVATAR:
        {
            if(isSuccess){
                [self.delegate_updateAvatar updateAvatarDidSuccess:result];
            }else{
                [self.delegate_updateAvatar updateAvatarDidFailed:desc];
            }
            break;
        }
        case TAG_IS_SERVER_NEW:
        {
            if(isSuccess){
                [self.delegate_isServerNew isServerNewDidSuccess:result];
            }else{
                [self.delegate_isServerNew isServerNewDidFailed:desc];
            }
            break;
        }
        case TAG_WEATHER:
        {
            if(isSuccess){
                [self.delegate_weather weatherDidSuccess:result];
            }else{
                [self.delegate_weather weatherDidFailed:desc];
            }
            break;
        }
        case TAG_FRIEND_LIST:
        {
            if(isSuccess){
                [self.delegate_friendsList friendsListDidSuccess:result];
            }else{
                [self.delegate_friendsList friendsListDidFailed:desc];
            }
            break;
        }
        case TAG_SEND_MAKE_FRIENDS_REQUEST:
        {
            if(isSuccess){
                [self.delegate_sendMakeFriendsRequest sendMakeFriendsRequestDidSuccess:result];
            }else{
                [self.delegate_sendMakeFriendsRequest sendMakeFriendsRequestDidFailed:desc];
            }
            break;
        }
        case TAG_AGREE_MAKE_FRIENDS:
        {
            if(isSuccess){
                [self.delegate_agreeMakeFriends agreeMakeFriendsDidSuccess:result];
            }else{
                [self.delegate_agreeMakeFriends agreeMakeFriendsDidFailed:desc];
            }
            break;
        }
        case TAG_CREATE_GROUP:
        {
            if(isSuccess){
                [self.delegate_createGroup createGroupDidSuccess:result];
            }else{
                [self.delegate_createGroup createGroupDidFailed:desc];
            }
            break;
        }
        case TAG_REJECT_MAKE_FRIENDS:
        {
            if(isSuccess){
                [self.delegate_rejectMakeFriends rejectMakeFriendsDidSuccess:result];
            }else{
                [self.delegate_rejectMakeFriends rejectMakeFriendsDidFailed:desc];
            }
            break;
        }
        case TAG_SEARCH_FRIEND:
        {
            if(isSuccess){
                [self.delegate_searchFriend searchFriendDidSuccess:result];
            }else{
                [self.delegate_searchFriend searchFriendDidFailed:desc];
            }
            break;
        }
        case TAG_DELETE_FRIEND:
        {
            if(isSuccess){
                [self.delegate_deleteFriend deleteFriendDidSuccess:result];
            }else{
                [self.delegate_deleteFriend deleteFriendDidFailed:desc];
            }
            break;
        }
        case TAG_GROUP_MEMBER:
        {
            if(isSuccess){
                [self.delegate_groupMember groupMemberDidSuccess:result];
            }else{
                [self.delegate_groupMember groupMemberDidFailed:desc];
            }
            break;
        }
        case TAG_EXIT_GROUP:
        {
            if(isSuccess){
                [self.delegate_exitGroup exitGroupDidSuccess:result];
            }else{
                [self.delegate_exitGroup exitGroupDidFailed:desc];
            }
            break;
        }
        case TAG_DELETE_GROUP:
        {
            if(isSuccess){
                [self.delegate_deleteGroup deleteGroupDidSuccess:result];
            }else{
                [self.delegate_deleteGroup deleteGroupDidFailed:desc];
            }
            break;
        }
        case TAG_ADD_MEMBER:
        {
            if(isSuccess){
                [self.delegate_addMember addMemberDidSuccess:result];
            }else{
                [self.delegate_addMember addMemberDidFailed:desc];
            }
            break;
        }
        case TAG_DEL_MEMBER:
        {
            if(isSuccess){
                [self.delegate_delMember delMemberDidSuccess:result];
            }else{
                [self.delegate_delMember delMemberDidFailed:desc];
            }
            break;
        }
        case TAG_CHANGE_GROUP_NAME:
        {
            if(isSuccess){
                [self.delegate_changeGroupName changeGroupNameDidSuccess:result];
            }else{
                [self.delegate_changeGroupName changeGroupNameDidFailed:desc];
            }
            break;
        }
        case TAG_MEMBER_LOCATIONS:
        {
            if(isSuccess){
                [self.delegate_memberLocations memberLocationsDidSuccess:result];
            }else{
                [self.delegate_memberLocations memberLocationsDidFailed:desc];
            }
            break;
        }
        case TAG_ENABLE_MY_LOCATION_IN_GROUP:
        {
            if(isSuccess){
                [self.delegate_enableMyLocationInGroup enableMyLocationInGroupDidSuccess:result];
            }else{
                [self.delegate_enableMyLocationInGroup enableMyLocationInGroupDidFailed:desc];
            }
            break;
        }
        case TAG_RESET_GROUP_SETTING:
        {
            if(isSuccess){
                [self.delegate_resetGroupSetting resetGroupSettingGroupDidSuccess:result];
            }else{
                [self.delegate_resetGroupSetting resetGroupSettingGroupDidFailed:desc];
            }
            break;
        }
        case TAG_UPLOAD_ADBOOK:
        {
            if(isSuccess){
                [self.delegate_uploadADBook uploadADDidSuccess:result];
            }else{
                [self.delegate_uploadADBook uploadADDidFailed:desc];
            }
            break;
        }
        case TAG_USER_IN_ADBOOK:
        {
            if(isSuccess){
                [self.delegate_userInADBook userInADBookDidSuccess:result];
            }else{
                [self.delegate_userInADBook userInADBookDidFailed:desc];
            }
            break;
        }
        case TAG_TEST_TIME_OUT:
        {
            if(isSuccess){
                [self.delegate_testTimeOut testTimeOutDidSuccess];
            }else{
                [self.delegate_testTimeOut testTimeOutDidFailed];
            }
            break;
        }
        case TAG_DEBUG:
        {
            if(isSuccess){
               //清除记录字符串
                [CNUtil showAlert:@"已经发送给序员"];
                kApp.userOperation = [NSMutableString stringWithString:@""];
                NSString* filePath = [CNPersistenceHandler getDocument:@"debug.plist"];
                [CNPersistenceHandler DeleteSingleFile:filePath];
            }
            break;
        }
        case TAG_WATER_DOWNLOAD:
        {
            if(isSuccess){
                NSString *description = [result objectForKey:@"description"];
                [self.delegate_WaterMarkInfo WaterMarkInfoDidSuccess:description];
            }else{
                [self.delegate_WaterMarkTimeStamp WaterMarkTimeStampDidFailed:@""];
            }
            break;
        }
        case TAG_WATER_TIME:
        {
            if(isSuccess){
                NSString *timeStamp = [result objectForKey:@"timestamp"];
                [self.delegate_WaterMarkTimeStamp WaterMarkTimeStampDidSuccess:timeStamp];
            }else{
                [self.delegate_WaterMarkInfo WaterMarkInfoDidFailed:@""];
            }
            break;
        }
        case TAG_CHANGE_REMARK:
        {
            if(isSuccess){
                [self.delegate_changeRemark changeRemarkDidSuccess:result];
            }else{
                [self.delegate_changeRemark changeRemarkDidFailed:desc];
            }
            break;
        }
        default:
            break;
    }
}
- (void)notificationCloseCheckTime{
    NSString* NOTIFICATION_CHECK_TIME = @"check_time";
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_TIME object:nil];
    NSLog(@"通知关闭");
    [self performSelector:@selector(startCheckWhatToDo) withObject:nil afterDelay:0.5];
}
- (void)startCheckWhatToDo{
    [CNAppDelegate whatShouldIdo];
}
- (void)requestFailedByQueue:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    NSLog(@"错误信息：%@",error.localizedDescription);
    NSLog(@"错误码:%i",(int)(error.code));
    
    
    switch (request.tag) {
        case TAG_VERIFY_CODE:
        {
            [self.delegate_verifyCode verifyCodeDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_REGISTER_PHONE:
        {
            [self.delegate_registerPhone registerPhoneDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_UPDATE_USERINFO:
        {
            [self.delegate_updateUserinfo updateUserinfoDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_LOGIN_PHONE:
        {
            [self.delegate_loginPhone loginPhoneDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_AUTO_LOGIN:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDone" object:nil];
            kApp.isLogin = 0;
            [kApp.cloudManager synTimeWithServer];
            [CNUtil showAlert:kCheckNetworkTip];
            break;
        }
        case TAG_FIND_PWD:
        {
            [self.delegate_findPwd findPwdDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_UPDATE_AVATAR:
        {
            [self.delegate_updateAvatar updateAvatarDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_IS_SERVER_NEW:
        {
            [self.delegate_isServerNew isServerNewDidFailed:@""];
            break;
        }
        case TAG_WEATHER:
        {
            [self.delegate_weather weatherDidFailed:@""];
            break;
        }
        case TAG_FRIEND_LIST:
        {
            [self.delegate_friendsList friendsListDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_SEND_MAKE_FRIENDS_REQUEST:
        {
            [self.delegate_sendMakeFriendsRequest sendMakeFriendsRequestDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_AGREE_MAKE_FRIENDS:
        {
            [self.delegate_agreeMakeFriends agreeMakeFriendsDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_CREATE_GROUP:
        {
            [self.delegate_createGroup createGroupDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_REJECT_MAKE_FRIENDS:
        {
            [self.delegate_rejectMakeFriends rejectMakeFriendsDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_SEARCH_FRIEND:
        {
            [self.delegate_searchFriend searchFriendDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_DELETE_FRIEND:
        {
            [self.delegate_deleteFriend deleteFriendDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_GROUP_MEMBER:
        {
            [self.delegate_groupMember groupMemberDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_EXIT_GROUP:
        {
            [self.delegate_exitGroup exitGroupDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_DELETE_GROUP:
        {
            [self.delegate_deleteGroup deleteGroupDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_ADD_MEMBER:
        {
            [self.delegate_addMember addMemberDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_DEL_MEMBER:
        {
            [self.delegate_delMember delMemberDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_CHANGE_GROUP_NAME:
        {
            [self.delegate_changeGroupName changeGroupNameDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_MEMBER_LOCATIONS:
        {
            [self.delegate_memberLocations memberLocationsDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_ENABLE_MY_LOCATION_IN_GROUP:
        {
            [self.delegate_enableMyLocationInGroup enableMyLocationInGroupDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_RESET_GROUP_SETTING:
        {
            [self.delegate_resetGroupSetting resetGroupSettingGroupDidFailed:@""];
            break;
        }
        case TAG_UPLOAD_ADBOOK:
        {
            [self.delegate_uploadADBook uploadADDidFailed:@""];
            break;
        }
        case TAG_USER_IN_ADBOOK:
        {
            [self.delegate_userInADBook userInADBookDidFailed:@""];
            break;
        }
        case TAG_TEST_TIME_OUT:
        {
            NSLog(@"超时请求失败");
            [CNUtil showAlert:@"您当前网络似乎不是很好，请检查网络后重试~"];
            [self.delegate_testTimeOut testTimeOutDidFailed];
            break;
        }
        case TAG_WATER_TIME:
        {
            [self.delegate_WaterMarkTimeStamp WaterMarkTimeStampDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_WATER_DOWNLOAD:
        {
            [self.delegate_WaterMarkInfo WaterMarkInfoDidFailed:kCheckNetworkTip];
            break;
        }
        case TAG_CHANGE_REMARK:
        {
            [self.delegate_changeRemark changeRemarkDidFailed:kCheckNetworkTip];
            break;
        }
        default:
            break;
    }
}
- (void)queueFinished:(ASIHTTPRequest *)request{
    NSLog(@"queueFinished");
}
- (void)doRequest_verifyCode:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/sendvcode.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.verifyCodeRequest =  [ASIFormDataRequest requestWithURL:url];
    self.verifyCodeRequest.tag = TAG_VERIFY_CODE;
    [self.verifyCodeRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.verifyCodeRequest setTimeOutSeconds:15];
    [self.verifyCodeRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.verifyCodeRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.verifyCodeRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"获取验证码url:%@",str_url);
    NSLog(@"获取验证码参数:%@",params);
    [[self networkQueue]addOperation:self.verifyCodeRequest];
}
- (void)doRequest_registerPhone:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/userreg.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.registerPhoneRequest =  [ASIFormDataRequest requestWithURL:url];
    self.registerPhoneRequest.tag = TAG_REGISTER_PHONE;
    [self.registerPhoneRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.registerPhoneRequest setTimeOutSeconds:15];
    [self.registerPhoneRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.registerPhoneRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.registerPhoneRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"手机注册url:%@",str_url);
    NSLog(@"手机注册参数:%@",params);
    [[self networkQueue]addOperation:self.registerPhoneRequest];
}
- (void)doRequest_loginPhone:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/loginbyphone.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.loginPhoneRequest =  [ASIFormDataRequest requestWithURL:url];
    self.loginPhoneRequest.tag = TAG_LOGIN_PHONE;
    [self.loginPhoneRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.loginPhoneRequest setTimeOutSeconds:15];
    [self.loginPhoneRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.loginPhoneRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.loginPhoneRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"手机登录url:%@",str_url);
    NSLog(@"手机登录参数:%@",params);
    [[self networkQueue]addOperation:self.loginPhoneRequest];
}
- (void)doRequest_autoLogin:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/autologin.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.autoLoginRequest =  [ASIFormDataRequest requestWithURL:url];
    self.autoLoginRequest.tag = TAG_AUTO_LOGIN;
    [self.autoLoginRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.autoLoginRequest setTimeOutSeconds:3];
    [self.autoLoginRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.autoLoginRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.autoLoginRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"自动登录url:%@",str_url);
    NSLog(@"自动登录参数:%@",params);
    [[self networkQueue]addOperation:self.autoLoginRequest];
}
- (void)doRequest_updateUserinfo:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/entryregister.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.updateUserinfoRequest =  [ASIFormDataRequest requestWithURL:url];
    self.updateUserinfoRequest.tag = TAG_UPDATE_USERINFO;
    [self.updateUserinfoRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.updateUserinfoRequest setTimeOutSeconds:15];
    [self.updateUserinfoRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.updateUserinfoRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.updateUserinfoRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"更新用户信息url:%@",str_url);
    NSLog(@"更新用户信息参数:%@,%@",params,kApp.pid);
    [[self networkQueue]addOperation:self.updateUserinfoRequest];
}
- (void)doRequest_findPwdVCode:(NSString*)phoneNO{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/mopasscode.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.findPwdVCodeRequest =  [ASIFormDataRequest requestWithURL:url];
    self.findPwdVCodeRequest.tag = TAG_FIND_PWD_VCODE;
    [self.findPwdVCodeRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.findPwdVCodeRequest setTimeOutSeconds:15];
    [self.findPwdVCodeRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.findPwdVCodeRequest addRequestHeader:@"ua" value:kApp.ua];
    [self.findPwdVCodeRequest setPostValue:phoneNO forKey:@"phone"];
    NSLog(@"找回密码获取验证码url:%@",str_url);
    NSLog(@"找回密码获取获取验证码参数:phone:%@",phoneNO);
    [[self networkQueue]addOperation:self.findPwdVCodeRequest];
}
- (void)doRequest_findPwd:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/mdpass.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.findPwdRequest =  [ASIFormDataRequest requestWithURL:url];
    self.findPwdRequest.tag = TAG_FIND_PWD;
    [self.findPwdRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.findPwdRequest setTimeOutSeconds:15];
    [self.findPwdRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.findPwdRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.findPwdRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"找回密码url:%@",str_url);
    NSLog(@"找回密码参数:%@",params);
    [[self networkQueue]addOperation:self.findPwdRequest];
}
- (void)doRequest_updateAvatar:(NSMutableDictionary*)params{
    
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/sys/upimage.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.updateAvatarRequest =  [ASIFormDataRequest requestWithURL:url];
    self.updateAvatarRequest.tag = TAG_UPDATE_AVATAR;
    [self.updateAvatarRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.updateAvatarRequest setTimeOutSeconds:15];
    [self.updateAvatarRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.updateAvatarRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        if([oneKey isEqualToString:@"avatar"]){
            [self.updateAvatarRequest addData:[params objectForKey:@"avatar"] forKey:@"avatar"];
        }else{
            [self.updateAvatarRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
        }
    }
    NSLog(@"更新头像url:%@",str_url);
    [params removeObjectForKey:@"avatar"];
    NSLog(@"更新头像参数:%@",params);
    [[self networkQueue]addOperation:self.updateAvatarRequest];
}

- (void)doRequest_cloudData:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/sys/upfile.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.cloudDataRequest =  [ASIFormDataRequest requestWithURL:url];
    self.cloudDataRequest.tag = TAG_CLOUD_DATA;
    [self.cloudDataRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.cloudDataRequest setTimeOutSeconds:15];
    [self.cloudDataRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.cloudDataRequest addRequestHeader:@"ua" value:kApp.ua];
    self.cloudDataRequest.delegate = self;
    self.cloudDataRequest.showAccurateProgress = YES;
    [self.cloudDataRequest setUploadProgressDelegate:self];
    for (id oneKey in [params allKeys]){
        if([oneKey isEqualToString:@"avatar"]){
            [self.cloudDataRequest addData:[params objectForKey:@"avatar"] forKey:@"avatar"];
        }else{
            [self.cloudDataRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
        }
    }
    NSLog(@"上传文件url:%@",str_url);
    [params removeObjectForKey:@"avatar"];
    NSLog(@"上传文件参数:%@",params);
    [self.cloudDataRequest startAsynchronous];
}
- (void)doRequest_isServerNew:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/run/updaterecordnumber.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.isServerNewRequest =  [ASIFormDataRequest requestWithURL:url];
    self.isServerNewRequest.tag = TAG_IS_SERVER_NEW;
    [self.isServerNewRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.isServerNewRequest setTimeOutSeconds:15];
    [self.isServerNewRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.isServerNewRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.isServerNewRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"服务器数据新吗url:%@",str_url);
    NSLog(@"服务器数据新吗参数:%@",params);
    [[self networkQueue]addOperation:self.isServerNewRequest];
}
- (void)doRequest_DeleteRecord:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/run/delrecord.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.deleteRecordRequest =  [ASIFormDataRequest requestWithURL:url];
    self.deleteRecordRequest.tag = TAG_DELETE_RECORD;
    [self.deleteRecordRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.deleteRecordRequest setTimeOutSeconds:15];
    [self.deleteRecordRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.deleteRecordRequest addRequestHeader:@"ua" value:kApp.ua];
    self.deleteRecordRequest.delegate = self;
    for (id oneKey in [params allKeys]){
        [self.deleteRecordRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"删除记录url:%@",str_url);
    NSLog(@"删除记录参数:%@",params);
    self.newprogress = 0.5;
    [self.deleteRecordRequest startAsynchronous];
}
- (void)doRequest_uploadRecord:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/run/runupdata.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.uploadRecordRequest =  [ASIFormDataRequest requestWithURL:url];
    self.uploadRecordRequest.tag = TAG_UPLOAD_RECORD;
    [self.uploadRecordRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.uploadRecordRequest setTimeOutSeconds:15];
    [self.uploadRecordRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.uploadRecordRequest addRequestHeader:@"ua" value:kApp.ua];
    self.uploadRecordRequest.delegate = self;
    for (id oneKey in [params allKeys]){
        [self.uploadRecordRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"上传记录url:%@",str_url);
    NSLog(@"上传记录参数:%@",params);
    self.newprogress = 0.5;
    [self.uploadRecordRequest startAsynchronous];
}
- (void)doRequest_downloadRecord:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/run/rundowndata.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.downloadRecordRequest =  [ASIFormDataRequest requestWithURL:url];
    self.downloadRecordRequest.tag = TAG_DOWNLAOD_RECORD;
    [self.downloadRecordRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.downloadRecordRequest setTimeOutSeconds:15];
    [self.downloadRecordRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.downloadRecordRequest addRequestHeader:@"ua" value:kApp.ua];
    self.downloadRecordRequest.delegate = self;
    for (id oneKey in [params allKeys]){
        [self.downloadRecordRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"下载记录url:%@",str_url);
    NSLog(@"下载记录参数:%@",params);
    self.newprogress = 0.5;
    [self.downloadRecordRequest startAsynchronous];
}
- (void)doRequest_downloadOneFile:(NSString*)str_url{
    NSURL* url = [NSURL URLWithString:str_url];
    self.downloadOneFileRequest = [ASIHTTPRequest requestWithURL:url];
    self.downloadOneFileRequest.tag = TAG_DOWNLOAD_ONE_FILE;
    [self.downloadOneFileRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.downloadOneFileRequest setTimeOutSeconds:15];
    [self.downloadOneFileRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.downloadOneFileRequest addRequestHeader:@"ua" value:kApp.ua];
    self.downloadOneFileRequest.delegate = self;
    self.downloadOneFileRequest.showAccurateProgress = YES;
    [self.downloadOneFileRequest setDownloadProgressDelegate:self];
    NSLog(@"下载文件url:%@",str_url);
    [self.downloadOneFileRequest startAsynchronous];
}
- (void)doRequest_deleteOneFile:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/run/delrunimgs.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.deleteOneFileRequest =  [ASIFormDataRequest requestWithURL:url];
    self.deleteOneFileRequest.tag = TAG_DELETE_ONE_FILE;
    [self.deleteOneFileRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.deleteOneFileRequest setTimeOutSeconds:15];
    [self.deleteOneFileRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.deleteOneFileRequest addRequestHeader:@"ua" value:kApp.ua];
    self.deleteOneFileRequest.delegate = self;
    for (id oneKey in [params allKeys]){
        [self.deleteOneFileRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"删除单个文件url:%@",str_url);
    NSLog(@"删除单个文件参数:%@",params);
    self.newprogress = 0.5;
    [self.deleteOneFileRequest startAsynchronous];
}

- (void)doRequest_weather:(double)lon :(double)lat{
    NSString* str_url = [NSString stringWithFormat:@"%@WeatherService/getWeather?lat=%f&lon=%f",ENDPOINTS,lat,lon];
    NSURL* url = [NSURL URLWithString:str_url];
    self.weatherRequest =  [ASIHTTPRequest requestWithURL:url];
    self.weatherRequest.tag = TAG_WEATHER;
    [self.weatherRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.weatherRequest setTimeOutSeconds:15];
    [self.weatherRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.weatherRequest addRequestHeader:@"ua" value:kApp.ua];
    NSLog(@"天气url:%@",str_url);
    NSLog(@"天气:参数lon:%f,lat:%f",lon,lat);
    [[self networkQueue]addOperation:self.weatherRequest];
}
- (void)doRequest_friendsList:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/friend/getrelatefriends.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.friendsListRequest =  [ASIFormDataRequest requestWithURL:url];
    self.friendsListRequest.tag = TAG_FRIEND_LIST;
    [self.friendsListRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.friendsListRequest setTimeOutSeconds:15];
    [self.friendsListRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.friendsListRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.friendsListRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"获取朋友列表url:%@",str_url);
    NSLog(@"获取朋友列表参数:%@",params);
    [[self networkQueue]addOperation:self.friendsListRequest];
}
- (void)doRequest_sendMakeFriendsRequest:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/friend/reqaddfriend.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.sendMakeFriendsRequestRequest =  [ASIFormDataRequest requestWithURL:url];
    self.sendMakeFriendsRequestRequest.tag = TAG_SEND_MAKE_FRIENDS_REQUEST;
    [self.sendMakeFriendsRequestRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.sendMakeFriendsRequestRequest setTimeOutSeconds:15];
    [self.sendMakeFriendsRequestRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.sendMakeFriendsRequestRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.sendMakeFriendsRequestRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"发送加好友请求url:%@",str_url);
    NSLog(@"发送加好友请求参数:%@",params);
    [[self networkQueue]addOperation:self.sendMakeFriendsRequestRequest];
}
- (void)doRequest_agreeMakeFriends:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/friend/acceptaddfriend.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.agreeMakeFriendsRequest =  [ASIFormDataRequest requestWithURL:url];
    self.agreeMakeFriendsRequest.tag = TAG_AGREE_MAKE_FRIENDS;
    [self.agreeMakeFriendsRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.agreeMakeFriendsRequest setTimeOutSeconds:15];
    [self.agreeMakeFriendsRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.agreeMakeFriendsRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.agreeMakeFriendsRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"同意添加好友url:%@",str_url);
    NSLog(@"同意添加好友参数:%@",params);
    [[self networkQueue]addOperation:self.agreeMakeFriendsRequest];
}
- (void)doRequest_rejectMakeFriends:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/friend/delcache.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.rejectMakeFriendsRequest =  [ASIFormDataRequest requestWithURL:url];
    self.rejectMakeFriendsRequest.tag = TAG_REJECT_MAKE_FRIENDS;
    [self.rejectMakeFriendsRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.rejectMakeFriendsRequest setTimeOutSeconds:15];
    [self.rejectMakeFriendsRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.rejectMakeFriendsRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.rejectMakeFriendsRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"忽略好友请求url:%@",str_url);
    NSLog(@"忽略好友请求参数:%@",params);
    [[self networkQueue]addOperation:self.rejectMakeFriendsRequest];
}
- (void)doRequest_deleteFriend:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/friend/removefriend.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.deleteFriendRequest =  [ASIFormDataRequest requestWithURL:url];
    self.deleteFriendRequest.tag = TAG_DELETE_FRIEND;
    [self.deleteFriendRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.deleteFriendRequest setTimeOutSeconds:15];
    [self.deleteFriendRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.deleteFriendRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.deleteFriendRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"删除好友url:%@",str_url);
    NSLog(@"删除好友参数:%@",params);
    [[self networkQueue]addOperation:self.deleteFriendRequest];
}
- (void)doRequest_searchFriend:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/friend/searchfriend.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.searchFriendRequest =  [ASIFormDataRequest requestWithURL:url];
    self.searchFriendRequest.tag = TAG_SEARCH_FRIEND;
    [self.searchFriendRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.searchFriendRequest setTimeOutSeconds:15];
    [self.searchFriendRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.searchFriendRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.searchFriendRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"搜索好友url:%@",str_url);
    NSLog(@"搜索好友参数:%@",params);
    [[self networkQueue]addOperation:self.searchFriendRequest];
}
- (void)doRequest_createGroup:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/addgroup.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.createGroupRequest =  [ASIFormDataRequest requestWithURL:url];
    self.createGroupRequest.tag = TAG_CREATE_GROUP;
    [self.createGroupRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.createGroupRequest setTimeOutSeconds:15];
    [self.createGroupRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.createGroupRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.createGroupRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"创建跑团url:%@",str_url);
    NSLog(@"创建跑团参数:%@",params);
    [[self networkQueue]addOperation:self.createGroupRequest];
}
- (void)doRequest_groupMember:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/getgroupusers.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.groupMemberRequest =  [ASIFormDataRequest requestWithURL:url];
    self.groupMemberRequest.tag = TAG_GROUP_MEMBER;
    [self.groupMemberRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.groupMemberRequest setTimeOutSeconds:15];
    [self.groupMemberRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.groupMemberRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.groupMemberRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"跑团成员url:%@",str_url);
    NSLog(@"跑团成员参数:%@",params);
    [[self networkQueue]addOperation:self.groupMemberRequest];
}
- (void)doRequest_exitGroup:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/deleteusertogroup.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.exitGroupRequest =  [ASIFormDataRequest requestWithURL:url];
    self.exitGroupRequest.tag = TAG_EXIT_GROUP;
    [self.exitGroupRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.exitGroupRequest setTimeOutSeconds:15];
    [self.exitGroupRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.exitGroupRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.exitGroupRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"退出跑团url:%@",str_url);
    NSLog(@"退出跑团参数:%@",params);
    [[self networkQueue]addOperation:self.exitGroupRequest];
}
- (void)doRequest_addMember:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/adduserstogroup.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.addMemberRequest =  [ASIFormDataRequest requestWithURL:url];
    self.addMemberRequest.tag = TAG_ADD_MEMBER;
    [self.addMemberRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.addMemberRequest setTimeOutSeconds:15];
    [self.addMemberRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.addMemberRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.addMemberRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"添加成员url:%@",str_url);
    NSLog(@"添加成员参数:%@",params);
    [[self networkQueue]addOperation:self.addMemberRequest];
}
- (void)doRequest_deleteGroup:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/deletegroup.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.deleteGroupRequest =  [ASIFormDataRequest requestWithURL:url];
    self.deleteGroupRequest.tag = TAG_DELETE_GROUP;
    [self.deleteGroupRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.deleteGroupRequest setTimeOutSeconds:15];
    [self.deleteGroupRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.deleteGroupRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.deleteGroupRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"解散跑团url:%@",str_url);
    NSLog(@"解散跑团参数:%@",params);
    [[self networkQueue]addOperation:self.deleteGroupRequest];
}
- (void)doRequest_delMember:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/deleteusertogroup.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.delMemberRequest =  [ASIFormDataRequest requestWithURL:url];
    self.delMemberRequest.tag = TAG_DEL_MEMBER;
    [self.delMemberRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.delMemberRequest setTimeOutSeconds:15];
    [self.delMemberRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.delMemberRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.delMemberRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"删除跑团成员url:%@",str_url);
    NSLog(@"删除跑团成员参数:%@",params);
    [[self networkQueue]addOperation:self.delMemberRequest];
}
- (void)doRequest_changeGroupName:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/updategroup.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.changeGroupNameRequest =  [ASIFormDataRequest requestWithURL:url];
    self.changeGroupNameRequest.tag = TAG_CHANGE_GROUP_NAME;
    [self.changeGroupNameRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.changeGroupNameRequest setTimeOutSeconds:15];
    [self.changeGroupNameRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.changeGroupNameRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.changeGroupNameRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"修改跑团名称url:%@",str_url);
    NSLog(@"修改跑团名称参数:%@",params);
    [[self networkQueue]addOperation:self.changeGroupNameRequest];
}
- (void)doRequest_memberLocations:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/locations.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.memberLocationsRequest =  [ASIFormDataRequest requestWithURL:url];
    self.memberLocationsRequest.tag = TAG_MEMBER_LOCATIONS;
    [self.memberLocationsRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.memberLocationsRequest setTimeOutSeconds:15];
    [self.memberLocationsRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.memberLocationsRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.memberLocationsRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"成员位置url:%@",str_url);
    NSLog(@"成员位置参数:%@",params);
    [[self networkQueue]addOperation:self.memberLocationsRequest];
}
- (void)doRequest_enableMyLocationInGroup:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/uploadlocation.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.enableMyLocationInGroupRequest =  [ASIFormDataRequest requestWithURL:url];
    self.enableMyLocationInGroupRequest.tag = TAG_ENABLE_MY_LOCATION_IN_GROUP;
    [self.enableMyLocationInGroupRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.enableMyLocationInGroupRequest setTimeOutSeconds:15];
    [self.enableMyLocationInGroupRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.enableMyLocationInGroupRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.enableMyLocationInGroupRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"显示我的位置url:%@",str_url);
    NSLog(@"显示我的位置参数:%@",params);
    [[self networkQueue]addOperation:self.enableMyLocationInGroupRequest];
}
- (void)doRequest_resetGroupSetting:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/group/inituploadlocation.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.resetGroupSettingRequest =  [ASIFormDataRequest requestWithURL:url];
    self.resetGroupSettingRequest.tag = TAG_RESET_GROUP_SETTING;
    [self.resetGroupSettingRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.resetGroupSettingRequest setTimeOutSeconds:15];
    [self.resetGroupSettingRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.resetGroupSettingRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.resetGroupSettingRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"重置跑团设置url:%@",str_url);
    NSLog(@"重置跑团设置参数:%@",params);
    [[self networkQueue]addOperation:self.resetGroupSettingRequest];
}
- (void)doRequest_uploadADBook:(NSString*)phoneNOString{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/uploadphonelist.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.uploadADBookRequest =  [ASIFormDataRequest requestWithURL:url];
    self.uploadADBookRequest.tag = TAG_UPLOAD_ADBOOK;
    [self.uploadADBookRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.uploadADBookRequest setTimeOutSeconds:15];
    [self.uploadADBookRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.uploadADBookRequest addRequestHeader:@"ua" value:kApp.ua];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [self.uploadADBookRequest addRequestHeader:@"uid" value:uid];
    NSData* unzipData = [phoneNOString dataUsingEncoding:NSUTF8StringEncoding];
    NSData* zippedData = [ASIDataCompressor compressData:unzipData error:nil];
    [self.uploadADBookRequest appendPostData:zippedData];
    NSLog(@"上传通讯录url:%@",str_url);
    [[self networkQueue]addOperation:self.uploadADBookRequest];
}
- (void)doRequest_userInADBook:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/getphonelist.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.userInADBookRequest =  [ASIFormDataRequest requestWithURL:url];
    self.userInADBookRequest.tag = TAG_USER_IN_ADBOOK;
    [self.userInADBookRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.userInADBookRequest setTimeOutSeconds:15];
    [self.userInADBookRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.userInADBookRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.userInADBookRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"获取通讯录中要跑用户url:%@",str_url);
    NSLog(@"获取通讯录中要跑用户参数:%@",params);
    [[self networkQueue]addOperation:self.userInADBookRequest];
}
- (void)doRequest_testTimeOut{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/testtimeout.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.testTimeOutRequest =  [ASIFormDataRequest requestWithURL:url];
    self.testTimeOutRequest.tag = TAG_TEST_TIME_OUT;
    [self.testTimeOutRequest setTimeOutSeconds:5];
//    [self.testTimeOutRequest addRequestHeader:@"X-PID" value:kApp.pid];
//    [self.testTimeOutRequest addRequestHeader:@"ua" value:kApp.ua];
    NSLog(@"测试超时url:%@",str_url);
    [[self networkQueue]addOperation:self.testTimeOutRequest];
}
- (void)dorequest_debug:(NSString*)fileName :(NSData*)data{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/sys/upfile.htm",@"http://182.92.97.144:8888/"];
    NSURL* url = [NSURL URLWithString:str_url];
    self.debugRequest =  [ASIFormDataRequest requestWithURL:url];
    self.debugRequest.tag = TAG_DEBUG;
    [self.debugRequest setTimeOutSeconds:15];
    [self.debugRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.debugRequest addRequestHeader:@"ua" value:kApp.ua];
    [self.debugRequest setPostValue:fileName forKey:@"stepfilename"];
    [self.debugRequest setPostValue:@"0" forKey:@"uid"];
    [self.debugRequest setPostValue:@"0" forKey:@"type"];
    [self.debugRequest addData:data forKey:@"stepfile"];
    [[self networkQueue]addOperation:self.debugRequest];
}
- (void)doRequest_WaterMarkTimeStamp{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/sys/getsytime.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.WaterMarkTimeStampRequest =  [ASIFormDataRequest requestWithURL:url];
    self.WaterMarkTimeStampRequest.tag = TAG_WATER_TIME;
    [self.WaterMarkTimeStampRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.WaterMarkTimeStampRequest setTimeOutSeconds:15];
    [self.WaterMarkTimeStampRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.WaterMarkTimeStampRequest addRequestHeader:@"ua" value:kApp.ua];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [self.WaterMarkTimeStampRequest setPostValue:uid forKey:@"uid"];
    NSLog(@"获取水印时间戳url:%@",str_url);
    NSLog(@"获取水印时间戳参数:%@",uid);
    [[self networkQueue]addOperation:self.WaterMarkTimeStampRequest];

}

- (void)doRequest_WaterMarkInfo{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/sys/getsydesc.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.WaterMarkInfoRequest =  [ASIFormDataRequest requestWithURL:url];
    self.WaterMarkInfoRequest.tag = TAG_WATER_DOWNLOAD;
    [self.WaterMarkInfoRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.WaterMarkInfoRequest setTimeOutSeconds:15];
    [self.WaterMarkInfoRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.WaterMarkInfoRequest addRequestHeader:@"ua" value:kApp.ua];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [self.WaterMarkInfoRequest setPostValue:uid forKey:@"uid"];
    NSLog(@"下载水印url:%@",str_url);
    NSLog(@"下载水印参数:%@",uid);
    [[self networkQueue]addOperation:self.WaterMarkInfoRequest];
}
- (void)doRequest_changeRemark:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/friend/modifyrename.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.changeRemarkRequest =  [ASIFormDataRequest requestWithURL:url];
    self.changeRemarkRequest.tag = TAG_CHANGE_REMARK;
    [self.changeRemarkRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.changeRemarkRequest setTimeOutSeconds:15];
    [self.changeRemarkRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.changeRemarkRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.changeRemarkRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"修改好友备注url:%@",str_url);
    NSLog(@"修改好友备注参数:%@",params);
    [[self networkQueue]addOperation:self.changeRemarkRequest];
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)user_logout{
    kApp.isLogin = 0;
    kApp.userInfoDic = nil;
    NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
}
- (void)setProgress:(float)newProgress{
    NSLog(@"-------------new progress is %f",newProgress);
    self.newprogress = newProgress;
}
- (void)didReceiveResponseHeaders:(ASIHTTPRequest *)request
{
    NSLog(@"didReceiveResponseHeaders %@",[request.responseHeaders valueForKey:@"Content-Length"]);
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    self.newprogress = 0;
    switch ([request tag]) {
        case TAG_DELETE_RECORD:
        {
            [self.delegate_deleteRecord deleteRecordDidFailed:@""];
            break;
        }
        case TAG_CLOUD_DATA:
        {
            [self.delegate_cloudData cloudDataDidFailed:@""];
            break;
        }
        case TAG_UPLOAD_RECORD:
        {
            [self.delegate_uploadRecord uploadRecordDidFailed:@""];
            break;
        }
        case TAG_DOWNLAOD_RECORD:
        {
            [self.delegate_downloadRecord downloadRecordDidFailed:@""];
            break;
        }
        case TAG_DOWNLOAD_ONE_FILE:
        {
            [self.delegate_downloadOneFile downloadOneFileDidFailed:@""];
            break;
        }
        case TAG_DELETE_ONE_FILE:
        {
            [self.delegate_deleteOneFile deleteOneFileDidFailed:@""];
            break;
        }
        default:
            break;
    }

}
- (void)requestFinished:(ASIHTTPRequest *)request{
    self.newprogress = 1;
    if([request tag] == TAG_DOWNLOAD_ONE_FILE){
        [self.delegate_downloadOneFile downloadOneFileDidSuccess:[request responseData]];
        return;
    }
    NSString *responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"---服务器返回结果是%@",responseString);
    SBJsonParser *jsonParser = [[SBJsonParser alloc]init];
    id result = [jsonParser objectWithString:responseString];
    NSDictionary* stateDic = [result objectForKey:@"state"];
    if(stateDic == nil)return;
    int code = [[stateDic objectForKey:@"code"] intValue];
    if(code == -7){//用户已经在其他手机登录
        [CNUtil showAlert:@"用户在其他手机登录，请重新登录"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDone" object:nil];
        CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
        [[kApp.navVCList objectAtIndex:kApp.currentSelect] pushViewController:loginVC animated:YES];
        kApp.cloudManager.stepDes = @"用户在其他手机登录，请重新登录";
        [self user_logout];
//        return;
    }
    NSString* desc = [stateDic objectForKey:@"desc"];
    BOOL isSuccess = (code == 0)?YES:NO;
    switch ([request tag]) {
        case TAG_CLOUD_DATA:
        {
            if(isSuccess){
                [self.delegate_cloudData cloudDataDidSuccess:result];
            }else{
                [self.delegate_cloudData cloudDataDidFailed:desc];
            }
            break;
        }
        case TAG_DELETE_RECORD:
        {
            if(isSuccess){
                [self.delegate_deleteRecord deleteRecordDidSuccess:result];
            }else{
                [self.delegate_deleteRecord deleteRecordDidFailed:desc];
            }
            break;
        }
        case TAG_UPLOAD_RECORD:
        {
            if(isSuccess){
                [self.delegate_uploadRecord uploadRecordDidSuccess:result];
            }else{
                [self.delegate_uploadRecord uploadRecordDidFailed:desc];
            }
            break;
        }
        case TAG_DOWNLAOD_RECORD:
        {
            if(isSuccess){
                [self.delegate_downloadRecord downloadRecordDidSuccess:result];
            }else{
                [self.delegate_downloadRecord downloadRecordDidFailed:desc];
            }
            break;
        }
        case TAG_DELETE_ONE_FILE:
        {
            if(isSuccess){
                [self.delegate_deleteOneFile deleteOneFileDidSuccess];
            }else{
                [self.delegate_deleteOneFile deleteOneFileDidFailed:desc];
            }
            break;
        }
        default:break;
    }
}
@end

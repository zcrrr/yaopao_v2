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
#define kCheckServerTimeInterval 2
#define kShortTime 3000

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
@synthesize delegate_matchReport;
@synthesize delegate_matchOnekm;
@synthesize delegate_teamSimpleInfo;
@synthesize delegate_matchState;
@synthesize delegate_transmitRelay;
@synthesize delegate_matchListInfo;
@synthesize delegate_endMatch;
@synthesize delegate_confirmTransmit;
@synthesize delegate_listPersonal;
@synthesize delegate_cancelTransmit;
@synthesize delegate_checkServerTime;
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

@synthesize verifyCodeRequest;
@synthesize registerPhoneRequest;
@synthesize loginPhoneRequest;
@synthesize autoLoginRequest;
@synthesize updateUserinfoRequest;
@synthesize findPwdVCodeRequest;
@synthesize findPwdRequest;
@synthesize updateAvatarRequest;
@synthesize matchReportRequest;
@synthesize matchOnekmRequest;
@synthesize teamSimpleInfoRequest;
@synthesize matchStateInfoRequest;
@synthesize transmitRelayRequest;
@synthesize matchListInfoRequest;
@synthesize endMatchRequest;
@synthesize confirmTransmitRequest;
@synthesize listPersonalRequest;
@synthesize cancelTransmitRequest;
@synthesize checkServerTimeRequest;
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
    if(stateDic == nil)return;
    int code = [[stateDic objectForKey:@"code"] intValue];
    if(code == -7){//用户已经在其他手机登录
        [self showAlert:@"用户在其他手机登录，请重新登录"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDone" object:nil];
        CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
        [[kApp.navVCList objectAtIndex:kApp.currentSelect] pushViewController:loginVC animated:YES];
        [self user_logout];
        return;
    }
    NSString* desc = [stateDic objectForKey:@"desc"];
    BOOL isSuccess = (code == 0)?YES:NO;
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
            if([result objectForKey:@"match"]){
                kApp.matchDic = [result objectForKey:@"match"];
                //比赛信息就不保存到本地了，因为认为比赛前必须要经历登录或者手动登录这个过程
                kApp.uid = [kApp.userInfoDic objectForKey:@"uid"];
                NSLog(@"uid is %@",kApp.uid);
                kApp.gid = [kApp.matchDic objectForKey:@"gid"];
                kApp.mid = [kApp.matchDic objectForKey:@"mid"];
                kApp.isMatch = [[kApp.matchDic objectForKey:@"ismatch"]intValue];
                kApp.isbaton = [[kApp.matchDic objectForKey:@"isbaton"]intValue];
                int gstate = [[kApp.matchDic objectForKey:@"gstate"]intValue];
                if(gstate == 2){//已经结束比赛了且时间在比赛进行中
                    kApp.hasFinishTeamMatch = YES;
                }else{
                    if(kApp.isMatch == 1){
                        [self doRequest_checkServerTime];
                        [CNAppDelegate popupWarningCheckTime];
                    }
                }
            }
        }
    }
    switch (request.tag) {
        case TAG_VERIFY_CODE:
        {
            NSString* stringToAlert = isSuccess?@"验证码发送成功":desc;
            [self showAlert:stringToAlert];
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
                [self showAlert:desc];
            }
            break;
        }
        case TAG_LOGIN_PHONE:
        {
            if(isSuccess){
                [self.delegate_loginPhone loginPhoneDidSuccess:result];
            }else{
                [self.delegate_loginPhone loginPhoneDidFailed:desc];
                [self showAlert:desc];
            }
            break;
        }
        case TAG_AUTO_LOGIN:
        {
            NSString* phoneNO = [kApp.userInfoDic objectForKey:@"phone"];
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:phoneNO password:phoneNO completion:^(NSDictionary *loginInfo, EMError *error) {
                if (!error && loginInfo) {
                    NSLog(@"登录环信成功!!");
                    kApp.isLoginHX = 1;
                }
            } onQueue:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDone" object:nil];
//            [kApp.cloudManager synTimeWithServer];
            [kApp needRegisterMobUser];
            //用户登录之后先同步
            [CNAppDelegate popupWarningCloud:NO];
            break;
        }
        case TAG_FIND_PWD_VCODE:
        {
            NSString* stringToAlert = isSuccess?@"验证码发送成功":desc;
            [self showAlert:stringToAlert];
            break;
        }
        case TAG_FIND_PWD:
        {
            if(isSuccess){
                [self.delegate_findPwd findPwdDidSuccess:result];
            }else{
                [self.delegate_findPwd findPwdDidFailed:desc];
                [self showAlert:desc];
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
            NSString* stringToAlert = isSuccess?@"更新头像成功":desc;
            [self showAlert:stringToAlert];
            break;
        }
        case TAG_MATCH_UPLOAD:
        {
            if(isSuccess){
                [self.delegate_matchReport matchReportDidSuccess:result];
            }else{
                [self.delegate_matchReport matchReportDidFailed:desc];
            }
            break;
        }
        case TAG_MATCH_ONEKM:
        {
            if(isSuccess){
                [self.delegate_matchOnekm matchOnekmDidSuccess:result];
            }else{
                [self.delegate_matchOnekm matchOnekmDidFailed:desc];
            }
            break;
        }
        case TAG_SIMPLE_TEAM_INFO:
        {
            if(isSuccess){
                [self.delegate_teamSimpleInfo teamSimpleInfoDidSuccess:result];
            }else{
                [self.delegate_teamSimpleInfo teamSimpleInfoDidFailed:desc];
            }
            break;
        }
        case TAG_MATCH_STATE:
        {
            if(isSuccess){
                [self.delegate_matchState matchStateDidSuccess:result];
            }else{
                [self.delegate_matchState matchStateDidFailed:desc];
            }
            break;
        }
        case TAG_TRANSMIT_RELAY:
        {
            if(isSuccess){
                [self.delegate_transmitRelay transmitRelayDidSuccess:result];
            }else{
                [self.delegate_transmitRelay transmitRelayDidFailed:desc];
            }
            break;
        }
        case TAG_MATCH_LIST_INFO:
        {
            if(isSuccess){
                [self.delegate_matchListInfo matchListInfoDidSuccess:result];
            }else{
                [self.delegate_matchListInfo matchListInfoDidFailed:desc];
            }
            break;
        }
        case TAG_END_MATCH:
        {
            if(isSuccess){
                [self.delegate_endMatch endMatchInfoDidSuccess:result];
            }else{
                [self.delegate_endMatch endMatchInfoDidFailed:desc];
            }
            break;
        }
        case TAG_CONFIRM_TRANSMIT:
        {
            if(isSuccess){
                [self.delegate_confirmTransmit confirmTransmitDidSuccess:result];
            }else{
                [self.delegate_confirmTransmit confirmTransmitDidFailed:desc];
            }
            break;
        }
        case TAG_LIST_PERSONAL:
        {
            if(isSuccess){
                [self.delegate_listPersonal listPersonalDidSuccess:result];
            }else{
                [self.delegate_listPersonal listPersonalDidFailed:desc];
            }
            break;
        }
        case TAG_CANCELTRANSMIT:
        {
            if(isSuccess){
                [self.delegate_cancelTransmit cancelTransmitDidSuccess:result];
            }else{
                [self.delegate_cancelTransmit cancelTransmitDidFailed:desc];
            }
            break;
        }
        case TAG_CHECK_SERVER_TIME:
        {
            if(isSuccess){
                long long serverTime = [[result objectForKey:@"systime"]longLongValue];
                self.endRequestTime = [CNUtil getNowTime1000];
                if(self.endRequestTime-self.startRequestTime < kShortTime){
                    //如果时间满足条件，则delataTime取值确定
                    int deltaTime1000 = (int)(serverTime-(self.startRequestTime+self.endRequestTime)/2);//取得毫秒数
                    kApp.deltaTime = (deltaTime1000+500)/1000;
                    NSLog(@"kApp.deltaTime is %i",kApp.deltaTime);
                    kApp.hasCheckTimeFromServer = YES;
                    [self performSelector:@selector(notificationCloseCheckTime) withObject:nil afterDelay:1];
                }else{
                    [self performSelector:@selector(doRequest_checkServerTime) withObject:nil afterDelay:kCheckServerTimeInterval];
                }
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
    if(request.tag != TAG_MATCH_UPLOAD || request.tag != TAG_MATCH_ONEKM || request.tag != TAG_SIMPLE_TEAM_INFO){
        [self showAlert:@"请检查网络"];
    }
    switch (request.tag) {
        case TAG_REGISTER_PHONE:
        {
            [self.delegate_registerPhone registerPhoneDidFailed:@""];
            break;
        }
        case TAG_UPDATE_USERINFO:
        {
            [self.delegate_updateUserinfo updateUserinfoDidFailed:@""];
            break;
        }
        case TAG_LOGIN_PHONE:
        {
            [self.delegate_loginPhone loginPhoneDidFailed:@""];
            break;
        }
        case TAG_AUTO_LOGIN:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginDone" object:nil];
            kApp.isLogin = 0;
            [kApp.cloudManager synTimeWithServer];
            break;
        }
        case TAG_FIND_PWD:
        {
            [self.delegate_findPwd findPwdDidFailed:@""];
            break;
        }
        case TAG_UPDATE_AVATAR:
        {
            [self.delegate_updateAvatar updateAvatarDidFailed:@""];
            break;
        }
        case TAG_MATCH_UPLOAD:
        {
            [self.delegate_matchReport matchReportDidFailed:@""];
            break;
        }
        case TAG_MATCH_ONEKM:
        {
            [self.delegate_matchOnekm matchOnekmDidFailed:@""];
            break;
        }
        case TAG_SIMPLE_TEAM_INFO:
        {
            [self.delegate_teamSimpleInfo teamSimpleInfoDidFailed:@""];
            break;
        }
        case TAG_MATCH_STATE:
        {
            [self.delegate_matchState matchStateDidFailed:@""];
            break;
        }
        case TAG_TRANSMIT_RELAY:
        {
            [self.delegate_transmitRelay transmitRelayDidFailed:@""];
            break;
        }
        case TAG_MATCH_LIST_INFO:
        {
            [self.delegate_matchListInfo matchListInfoDidFailed:@""];
            break;
        }
        case TAG_END_MATCH:
        {
            [self.delegate_endMatch endMatchInfoDidFailed:@""];
            break;
        }
        case TAG_CONFIRM_TRANSMIT:
        {
            [self.delegate_confirmTransmit confirmTransmitDidFailed:@""];
            break;
        }
        case TAG_LIST_PERSONAL:
        {
            [self.delegate_listPersonal listPersonalDidFailed:@""];
            break;
        }
        case TAG_CANCELTRANSMIT:
        {
            [self.delegate_cancelTransmit cancelTransmitDidFailed:@""];
            break;
        }
        case TAG_CHECK_SERVER_TIME:
        {
            [self performSelector:@selector(doRequest_checkServerTime) withObject:nil afterDelay:kCheckServerTimeInterval];
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
            [self.delegate_friendsList friendsListDidFailed:@""];
            break;
        }
        case TAG_SEND_MAKE_FRIENDS_REQUEST:
        {
            [self.delegate_sendMakeFriendsRequest sendMakeFriendsRequestDidFailed:@""];
            break;
        }
        case TAG_AGREE_MAKE_FRIENDS:
        {
            [self.delegate_agreeMakeFriends agreeMakeFriendsDidFailed:@""];
            break;
        }
        case TAG_CREATE_GROUP:
        {
            [self.delegate_createGroup createGroupDidFailed:@""];
            break;
        }
        case TAG_REJECT_MAKE_FRIENDS:
        {
            [self.delegate_rejectMakeFriends rejectMakeFriendsDidFailed:@""];
            break;
        }
        case TAG_SEARCH_FRIEND:
        {
            [self.delegate_searchFriend searchFriendDidFailed:@""];
            break;
        }
        case TAG_DELETE_FRIEND:
        {
            [self.delegate_deleteFriend deleteFriendDidFailed:@""];
            break;
        }
        case TAG_GROUP_MEMBER:
        {
            [self.delegate_groupMember groupMemberDidFailed:@""];
            break;
        }
        
            
        default:
            break;
    }
}
- (void)queueFinished:(ASIHTTPRequest *)request{
    NSLog(@"queueFinished");
}
- (void)doRequest_verifyCode:(NSString*)phoneNO{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/getvcode.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.verifyCodeRequest =  [ASIFormDataRequest requestWithURL:url];
    self.verifyCodeRequest.tag = TAG_VERIFY_CODE;
    [self.verifyCodeRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.verifyCodeRequest setTimeOutSeconds:15];
    [self.verifyCodeRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.verifyCodeRequest addRequestHeader:@"ua" value:kApp.ua];
    [self.verifyCodeRequest setPostValue:phoneNO forKey:@"phone"];
    NSLog(@"获取验证码url:%@",str_url);
    NSLog(@"获取验证码参数:phone:%@",phoneNO);
    [[self networkQueue]addOperation:self.verifyCodeRequest];
}
- (void)doRequest_registerPhone:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/useregister.htm",ENDPOINTS];
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
    [self.autoLoginRequest setTimeOutSeconds:15];
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
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/login/modifypass.htm",ENDPOINTS];
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
- (void)doRequest_matchReport:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/gpsreport.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.matchReportRequest =  [ASIFormDataRequest requestWithURL:url];
    self.matchReportRequest.tag = TAG_MATCH_UPLOAD;
    [self.matchReportRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.matchReportRequest setTimeOutSeconds:15];
    [self.matchReportRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.matchReportRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.matchReportRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"比赛上报url:%@",str_url);
    NSLog(@"比赛上报参数:%@",params);
    [[self networkQueue]addOperation:self.matchReportRequest];
}
- (void)doRequest_matchOnekm:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/kilometrereport.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.matchOnekmRequest =  [ASIFormDataRequest requestWithURL:url];
    self.matchOnekmRequest.tag = TAG_MATCH_ONEKM;
    [self.matchOnekmRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.matchOnekmRequest setTimeOutSeconds:15];
    [self.matchOnekmRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.matchOnekmRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.matchOnekmRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"整公里上报url:%@",str_url);
    NSLog(@"整公里上报参数:%@",params);
    [[self networkQueue]addOperation:self.matchOnekmRequest];
}
- (void)doRequest_smallMapPage:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/showmapgps.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.teamSimpleInfoRequest =  [ASIFormDataRequest requestWithURL:url];
    self.teamSimpleInfoRequest.tag = TAG_SIMPLE_TEAM_INFO;
    [self.teamSimpleInfoRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.teamSimpleInfoRequest setTimeOutSeconds:15];
    [self.teamSimpleInfoRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.teamSimpleInfoRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.teamSimpleInfoRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"跑队大概成绩url:%@",str_url);
    NSLog(@"跑队大概成绩参数:%@",params);
    [[self networkQueue]addOperation:self.teamSimpleInfoRequest];
}
- (void)doRequest_matchState:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/vavimatchstate.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.matchStateInfoRequest =  [ASIFormDataRequest requestWithURL:url];
    self.matchStateInfoRequest.tag = TAG_MATCH_STATE;
    [self.matchStateInfoRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.matchStateInfoRequest setTimeOutSeconds:15];
    [self.matchStateInfoRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.matchStateInfoRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.matchStateInfoRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"比赛状态url:%@",str_url);
    NSLog(@"比赛状态参数:%@",params);
    [[self networkQueue]addOperation:self.matchStateInfoRequest];
}
- (void)doRequest_transmitRelay:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/applysuccession.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.transmitRelayRequest =  [ASIFormDataRequest requestWithURL:url];
    self.transmitRelayRequest.tag = TAG_TRANSMIT_RELAY;
    [self.transmitRelayRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.transmitRelayRequest setTimeOutSeconds:15];
    [self.transmitRelayRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.transmitRelayRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.transmitRelayRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"交接棒扫描url:%@",str_url);
    NSLog(@"交接棒扫描参数:%@",params);
    [[self networkQueue]addOperation:self.transmitRelayRequest];
}
- (void)doRequest_listKM:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/matchendkilometre.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.matchListInfoRequest =  [ASIFormDataRequest requestWithURL:url];
    self.matchListInfoRequest.tag = TAG_MATCH_LIST_INFO;
    [self.matchListInfoRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.matchListInfoRequest setTimeOutSeconds:15];
    [self.matchListInfoRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.matchListInfoRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.matchListInfoRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"比赛成绩列表url:%@",str_url);
    NSLog(@"比赛成绩列表:%@",params);
    [[self networkQueue]addOperation:self.matchListInfoRequest];
}
- (void)doRequest_endMatch:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/advancefinish.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.endMatchRequest =  [ASIFormDataRequest requestWithURL:url];
    self.endMatchRequest.tag = TAG_END_MATCH;
    [self.endMatchRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.endMatchRequest setTimeOutSeconds:15];
    [self.endMatchRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.endMatchRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.endMatchRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"结束比赛url:%@",str_url);
    NSLog(@"结束比赛参数:%@",params);
    [[self networkQueue]addOperation:self.endMatchRequest];
}
- (void)doRequest_confirmTransmit:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/confirmsuccession.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.confirmTransmitRequest =  [ASIFormDataRequest requestWithURL:url];
    self.confirmTransmitRequest.tag = TAG_CONFIRM_TRANSMIT;
    [self.confirmTransmitRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.confirmTransmitRequest setTimeOutSeconds:15];
    [self.confirmTransmitRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.confirmTransmitRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.confirmTransmitRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"确认交棒url:%@",str_url);
    NSLog(@"确认交棒参数:%@",params);
    [[self networkQueue]addOperation:self.confirmTransmitRequest];
}
- (void)doRequest_listPersonal:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/matchendshow.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.listPersonalRequest =  [ASIFormDataRequest requestWithURL:url];
    self.listPersonalRequest.tag = TAG_LIST_PERSONAL;
    [self.listPersonalRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.listPersonalRequest setTimeOutSeconds:15];
    [self.listPersonalRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.listPersonalRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.listPersonalRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"个人成绩列表url:%@",str_url);
    NSLog(@"个人成绩列表参数:%@",params);
    [[self networkQueue]addOperation:self.listPersonalRequest];
}
- (void)doRequest_cancelTransmit:(NSMutableDictionary*)params{
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/cancelsuccession.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.cancelTransmitRequest =  [ASIFormDataRequest requestWithURL:url];
    self.cancelTransmitRequest.tag = TAG_CANCELTRANSMIT;
    [self.cancelTransmitRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.cancelTransmitRequest setTimeOutSeconds:15];
    [self.cancelTransmitRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.cancelTransmitRequest addRequestHeader:@"ua" value:kApp.ua];
    for (id oneKey in [params allKeys]){
        [self.cancelTransmitRequest setPostValue:[params objectForKey:oneKey] forKey:oneKey];
    }
    NSLog(@"取消交接棒url:%@",str_url);
    NSLog(@"取消交接棒参数:%@",params);
    [[self networkQueue]addOperation:self.cancelTransmitRequest];
}
- (void)doRequest_checkServerTime{
    self.startRequestTime = [CNUtil getNowTime1000];
    NSString* str_url = [NSString stringWithFormat:@"%@chSports/matchstart/returntime.htm",ENDPOINTS];
    NSURL* url = [NSURL URLWithString:str_url];
    self.checkServerTimeRequest =  [ASIFormDataRequest requestWithURL:url];
    self.checkServerTimeRequest.tag = TAG_CHECK_SERVER_TIME;
    [self.checkServerTimeRequest setNumberOfTimesToRetryOnTimeout:3];
    [self.checkServerTimeRequest setTimeOutSeconds:15];
    [self.checkServerTimeRequest addRequestHeader:@"X-PID" value:kApp.pid];
    [self.checkServerTimeRequest addRequestHeader:@"ua" value:kApp.ua];
    NSLog(@"获取服务器时间url:%@",str_url);
    [[self networkQueue]addOperation:self.checkServerTimeRequest];
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
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)user_logout{
    kApp.isLogin = 0;
    kApp.userInfoDic = nil;
    kApp.imageData = nil;
    NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
}
- (void)setProgress:(float)newProgress{
    NSLog(@"new progress is %f",newProgress);
    self.newprogress = newProgress;
}
- (void)didReceiveResponseHeaders:(ASIHTTPRequest *)request
{
    NSLog(@"didReceiveResponseHeaders %@",[request.responseHeaders valueForKey:@"Content-Length"]);
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    self.newprogress = 1;
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
        [self showAlert:@"用户在其他手机登录，请重新登录"];
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

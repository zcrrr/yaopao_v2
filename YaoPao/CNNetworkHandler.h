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
#import "ASIHTTPRequest.h";

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

@protocol matchReportDelegate <NSObject>
//比赛上报数据
- (void)matchReportDidSuccess:(NSDictionary*)resultDic;
- (void)matchReportDidFailed:(NSString*)mes;
@end

@protocol matchOnekmDelegate <NSObject>
//整公里上报数据
- (void)matchOnekmDidSuccess:(NSDictionary*)resultDic;
- (void)matchOnekmDidFailed:(NSString*)mes;
@end

@protocol teamSimpleInfoDelegate <NSObject>
//跑队大概信息
- (void)teamSimpleInfoDidSuccess:(NSDictionary*)resultDic;
- (void)teamSimpleInfoDidFailed:(NSString*)mes;
@end

@protocol matchStateDelegate <NSObject>
//获取我的比赛状态
- (void)matchStateDidSuccess:(NSDictionary*)resultDic;
- (void)matchStateDidFailed:(NSString*)mes;
@end

@protocol transmitRelayDelegate <NSObject>
//交接棒扫描
- (void)transmitRelayDidSuccess:(NSDictionary*)resultDic;
- (void)transmitRelayDidFailed:(NSString*)mes;
@end

@protocol matchListInfoDelegate <NSObject>
//比赛成绩列表
- (void)matchListInfoDidSuccess:(NSDictionary*)resultDic;
- (void)matchListInfoDidFailed:(NSString*)mes;
@end

@protocol endMatchDelegate <NSObject>
//结束比赛
- (void)endMatchInfoDidSuccess:(NSDictionary*)resultDic;
- (void)endMatchInfoDidFailed:(NSString*)mes;
@end

@protocol confirmTransmitDelegate<NSObject>
//确认交棒
- (void)confirmTransmitDidSuccess:(NSDictionary*)resultDic;
- (void)confirmTransmitDidFailed:(NSString*)mes;
@end

@protocol listPersonalDelegate<NSObject>
//队员列表
- (void)listPersonalDidSuccess:(NSDictionary*)resultDic;
- (void)listPersonalDidFailed:(NSString*)mes;
@end

@protocol cancelTransmitDelegate<NSObject>
//取消交接
- (void)cancelTransmitDidSuccess:(NSDictionary*)resultDic;
- (void)cancelTransmitDidFailed:(NSString*)mes;
@end

@protocol checkServerTimeDelegate<NSObject>
//取服务器时间
- (void)checkServerTimeDidSuccess:(NSDictionary*)resultDic;
- (void)checkServerTimeDidFailed:(NSString*)mes;
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
@property (nonatomic, strong) id<matchReportDelegate> delegate_matchReport;
@property (nonatomic, strong) id<matchOnekmDelegate> delegate_matchOnekm;
@property (nonatomic, strong) id<teamSimpleInfoDelegate> delegate_teamSimpleInfo;
@property (nonatomic, strong) id<matchStateDelegate> delegate_matchState;
@property (nonatomic, strong) id<transmitRelayDelegate> delegate_transmitRelay;
@property (nonatomic, strong) id<matchListInfoDelegate> delegate_matchListInfo;
@property (nonatomic, strong) id<endMatchDelegate> delegate_endMatch;
@property (nonatomic, strong) id<confirmTransmitDelegate> delegate_confirmTransmit;
@property (nonatomic, strong) id<listPersonalDelegate> delegate_listPersonal;
@property (nonatomic, strong) id<cancelTransmitDelegate> delegate_cancelTransmit;
@property (nonatomic, strong) id<checkServerTimeDelegate> delegate_checkServerTime;
@property (nonatomic, strong) id<cloudDataDelegate> delegate_cloudData;
@property (nonatomic, strong) id<isServerNewDelegate> delegate_isServerNew;
@property (nonatomic, strong) id<deleteRecordDelegate> delegate_deleteRecord;
@property (nonatomic, strong) id<uploadRecordDelegate> delegate_uploadRecord;
@property (nonatomic, strong) id<downloadRecordDelegate> delegate_downloadRecord;
@property (nonatomic, strong) id<downloadOneFileDelegate> delegate_downloadOneFile;

//定义每个请求的request
@property (nonatomic, strong) ASIFormDataRequest* verifyCodeRequest;
@property (nonatomic, strong) ASIFormDataRequest* registerPhoneRequest;
@property (nonatomic, strong) ASIFormDataRequest* loginPhoneRequest;
@property (nonatomic, strong) ASIFormDataRequest* autoLoginRequest;
@property (nonatomic, strong) ASIFormDataRequest* updateUserinfoRequest;
@property (nonatomic, strong) ASIFormDataRequest* findPwdVCodeRequest;
@property (nonatomic, strong) ASIFormDataRequest* findPwdRequest;
@property (nonatomic, strong) ASIFormDataRequest* updateAvatarRequest;
@property (nonatomic, strong) ASIFormDataRequest* matchReportRequest;
@property (nonatomic, strong) ASIFormDataRequest* matchOnekmRequest;
@property (nonatomic, strong) ASIFormDataRequest* teamSimpleInfoRequest;
@property (nonatomic, strong) ASIFormDataRequest* matchStateInfoRequest;
@property (nonatomic, strong) ASIFormDataRequest* transmitRelayRequest;
@property (nonatomic, strong) ASIFormDataRequest* matchListInfoRequest;
@property (nonatomic, strong) ASIFormDataRequest* endMatchRequest;
@property (nonatomic, strong) ASIFormDataRequest* confirmTransmitRequest;
@property (nonatomic, strong) ASIFormDataRequest* listPersonalRequest;
@property (nonatomic, strong) ASIFormDataRequest* cancelTransmitRequest;
@property (nonatomic, strong) ASIFormDataRequest* checkServerTimeRequest;
@property (nonatomic, strong) ASIFormDataRequest* cloudDataRequest;
@property (nonatomic, strong) ASIFormDataRequest* isServerNewRequest;
@property (nonatomic, strong) ASIFormDataRequest* deleteRecordRequest;
@property (nonatomic, strong) ASIFormDataRequest* uploadRecordRequest;
@property (nonatomic, strong) ASIFormDataRequest* downloadRecordRequest;
@property (nonatomic, strong) ASIHTTPRequest* downloadOneFileRequest;
//每个请求的实现
- (void)doRequest_verifyCode:(NSString*)phoneNO;
- (void)doRequest_registerPhone:(NSMutableDictionary*)params;
- (void)doRequest_loginPhone:(NSMutableDictionary*)params;
- (void)doRequest_autoLogin:(NSMutableDictionary*)params;
- (void)doRequest_updateUserinfo:(NSMutableDictionary*)params;
- (void)doRequest_findPwdVCode:(NSString*)phoneNO;
- (void)doRequest_findPwd:(NSMutableDictionary*)params;
- (void)doRequest_updateAvatar:(NSMutableDictionary*)params;
- (void)doRequest_matchReport:(NSMutableDictionary*)params;
- (void)doRequest_matchOnekm:(NSMutableDictionary*)params;
- (void)doRequest_smallMapPage:(NSMutableDictionary*)params;
- (void)doRequest_matchState:(NSMutableDictionary*)params;
- (void)doRequest_transmitRelay:(NSMutableDictionary*)params;
- (void)doRequest_listKM:(NSMutableDictionary*)params;
- (void)doRequest_endMatch:(NSMutableDictionary*)params;
- (void)doRequest_confirmTransmit:(NSMutableDictionary*)params;
- (void)doRequest_listPersonal:(NSMutableDictionary*)params;
- (void)doRequest_cancelTransmit:(NSMutableDictionary*)params;
- (void)doRequest_checkServerTime;
- (void)doRequest_cloudData:(NSMutableDictionary*)params;
- (void)doRequest_isServerNew:(NSMutableDictionary*)params;
- (void)doRequest_DeleteRecord:(NSMutableDictionary*)params;
- (void)doRequest_uploadRecord:(NSMutableDictionary*)params;
- (void)doRequest_downloadRecord:(NSMutableDictionary*)params;
- (void)doRequest_downloadOneFile:(NSString*)str_url;

@end

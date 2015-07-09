//
//  CNAppDelegate.m
//  YaoPao
//
//  Created by zc on 14-7-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNAppDelegate.h"
#import "CNNetworkHandler.h"
#import <AdSupport/AdSupport.h>
#import "CNLocationHandler.h"
#import <MAMapKit/MAMapKit.h>
#import "RunClass.h"
#import "CNGPSPoint.h"
#import "MobClick.h"
#import "CNWarningGPSOpenViewController.h"
#import "CNWarningGPSWeakViewController.h"
#import "CNWarningBackGroundViewController.h"
#import "CNWarningCloudingViewController.h"
#import "CNGPSPoint4Match.h"
#import "CNUtil.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "CNVoiceHandler.h"
#import "CNEncryption.h"
#import "Toast+UIView.h"
#import "CNWarningNotInStartZoneViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import <GoogleMaps/GoogleMaps.h>
#import "CNCloudRecord.h"
#import "Reachability.h"
#import "HomeViewController.h"
#import "RecordViewController.h"
#import "MatchViewController.h"
#import "CNSettingViewController.h"
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>
#import <AdobeCreativeSDKFoundation/AdobeCreativeSDKFoundation.h>
#import "EMSDKFull.h"
#import "ChatListViewController.h"
#import "FriendsHandler.h"
#import "LoginDoneHandler.h"
#import "GCDAsyncUdpSocket.h"

@implementation CNAppDelegate
@synthesize navVCList;
@synthesize currentSelect;
@synthesize networkHandler;
@synthesize voiceHandler;
@synthesize runManager;
@synthesize cloudManager;
@synthesize friendHandler;
@synthesize isLogin;
@synthesize isLoginHX;
@synthesize pid;
@synthesize userInfoDic;
@synthesize imageData;
@synthesize vcodeSecond;
@synthesize vcodeTimer;
@synthesize locationHandler;
@synthesize loginHandler;
@synthesize oneRunPointList;
@synthesize isRunning;
@synthesize gpsLevel;
@synthesize timer_one_point;
@synthesize timer_secondplusplus;
@synthesize run_second;
@synthesize isGroup;
@synthesize isMatch;
@synthesize isbaton;
@synthesize match_startdis;
@synthesize match_currentLapDis;
@synthesize match_countPass;
@synthesize geosHandler;
@synthesize match_historydis;
@synthesize match_historySecond;
@synthesize gpsSignal;
@synthesize score;
@synthesize mainurl;
@synthesize imageurl;
@synthesize showad;
@synthesize showgame;
@synthesize array4Test;
@synthesize hasMessage;
@synthesize match_time_last_in_track;
//@synthesize match_pointsString;
@synthesize match_pointList;
@synthesize match_timer_report;
@synthesize uid;
@synthesize gid;
@synthesize mid;
@synthesize testIndex;
@synthesize match_totaldis;
@synthesize matchDic;
@synthesize match_targetkm;
@synthesize match_totalDisTeam;
@synthesize avatarDic;
@synthesize match_score;
@synthesize match_km_target_personal;
@synthesize match_km_start_time;
@synthesize matchtestdatalength;
@synthesize deltaTime;
@synthesize match_stringTrackZone;

@synthesize match_start_time;
@synthesize match_start_timestamp;
@synthesize match_end_timestamp;
@synthesize match_before5min_timestamp;
@synthesize match_isLogin;
@synthesize match_timer_check_countdown;
@synthesize canStartButNotInStartZone;
@synthesize hasFinishTeamMatch;
@synthesize match_inMatch;
@synthesize match_takeover_zone;
@synthesize match_stringStartZone;
@synthesize match_track_line;
@synthesize voiceOn;
@synthesize hasCheckTimeFromServer;
@synthesize isInChina;
@synthesize isKnowCountry;
@synthesize timer_playVoice;
@synthesize myContactUseApp;
@synthesize unreadMessageCount;
@synthesize udpSocket;
@synthesize timer_udp_running;
@synthesize eventTimeString;
@synthesize isInEvent;
@synthesize isOpenShareLocation;
@synthesize userOperation;

@synthesize managedObjectModel=_managedObjectModel;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.gpsLevel = 1;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //如果是第一次升级安装，删除所有的记录
    [CNCloudRecord deleteAllRecordWhenFirstInstall];
    //环信
    //注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    //net.yaopao.yaopao开发：yaopao_push_dev
    //net.yaopao.yaopao生产：dis_push_yaopao
    //net.yaopao.enterprise生产：yaopao_inhouse_push
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"yaopao#yaopao" apnsCertName:@"dis_push_yaopao" otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:NO]}];
    [[EaseMob sharedInstance].chatManager setIsUseIp:YES];
    [self registerEaseMobNotification];
    //注册推送
    application.applicationIconBadgeNumber = 0;
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    //注册
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
//    [[EaseMob sharedInstance] registerSDKWithAppKey:@"yaopao#yaopao" apnsCertName:@""];
//    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    //google map
    [GMSServices provideAPIKey:@"AIzaSyCyYR5Ih3xP0rpYMaF1qAsInxFyqvaCJIY"];
    //高德地图
#ifdef kInhouse
    [MAMapServices sharedServices].apiKey =@"e46925db02f9c24a1323a8b900e56346";
#else
    [MAMapServices sharedServices].apiKey =@"0f3dad31deac3acd29ce27c3c2a265f2";
# endif
    //adobe creative
    NSString* const CreativeSDKClientId = @"b8ae54f2e0084b789790003fda5127e1";
    NSString* const CreativeSDKClientSecret = @"581b3dc8-5946-491e-88e4-ce258e94c5f4";
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId withClientSecret:CreativeSDKClientSecret];
    //设置时区
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    
    
#ifdef kTestFlight
    //如果是inhouse则使用自己的crash处理
    self.userOperation = [NSMutableString stringWithString:@"开启要跑"];
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
#else
    //否则使用友盟
    [MobClick startWithAppkey:@"53fd6e13fd98c561b903e002" reportPolicy:BATCH   channelId:@""];
    [MobClick updateOnlineConfig];
    [MobClick setLogEnabled:YES];
# endif
    self.mainurl = [MobClick getConfigParams:@"mainurl"];
    NSLog(@"self.mainurl is %@",self.mainurl);
    if (self.mainurl == nil || ([NSNull null] == (NSNull *)self.mainurl)) {
        self.mainurl = @"http://appservice.yaopao.net/";
    }
    self.imageurl = [MobClick getConfigParams:@"imgurl"];
    NSLog(@"self.imageurl is %@",self.imageurl);
    if (self.imageurl == nil || ([NSNull null] == (NSNull *)self.imageurl)) {
        self.imageurl = @"http://image.yaopao.net/";
    }
//    self.imageurl = @"http://yaopaotest.oss-cn-beijing.aliyuncs.com/";
    self.showad = [MobClick getConfigParams:@"showad"];
    NSLog(@"self.showad is %@",self.showad);
    if (self.showad == nil || ([NSNull null] == (NSNull *)self.showad)) {
        self.showad = @"2.3.1,1";
    }
    self.eventTimeString = [MobClick getConfigParams:@"event"];
    NSLog(@"self.eventTimeString is %@",self.eventTimeString);
    if (self.eventTimeString == nil || ([NSNull null] == (NSNull *)self.eventTimeString)) {
        self.eventTimeString = @"2015-05-30 00:00,2015-05-30 23:59,http://image.yaopao.net/event/icon.png";
    }
    
//#ifdef SIMULATORTEST
//
//#else
//    self.match_start_time = [MobClick getConfigParams:@"gamestarttime"];
//# endif
//    NSLog(@"self.match_start_time is %@",self.match_start_time);
//    if (self.match_start_time == nil || ([NSNull null] == (NSNull *)self.match_start_time)) {
//        self.match_start_time = kStartTime;
//    }
    //mob
    [SMS_SDK registerApp:@"3289fdd0ca3b" withSecret:@"78b2977ac2193fe84a48b76595e1267d"];
    
    self.match_start_time = kStartTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* startDate = [dateFormatter dateFromString:self.match_start_time];
    self.match_start_timestamp = [startDate timeIntervalSince1970];
    self.match_before5min_timestamp = match_start_timestamp-5*60;
    self.match_end_timestamp = match_start_timestamp+kDuringMinute*60;
    
    //sharesdk
    [ShareSDK registerApp:@"3289fdd0ca3b"];
    [ShareSDK  connectSinaWeiboWithAppKey:@"3132648285"
                                appSecret:@"85c67e84287899794cb7d907b2fc78ce"
                              redirectUri:@"http://www.sharesdk.cn"
                              weiboSDKCls:[WeiboSDK class]];
    [ShareSDK connectQZoneWithAppKey:@"1102577590"
                           appSecret:@"rZVEpQ7RuF28PtJf"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectQQWithQZoneAppKey:@"1102577590"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectWeChatWithAppId:@"wxf1f5d09f974c50b7"
                           wechatCls:[WXApi class]];
    [ShareSDK importWeChatClass:[WXApi class]];
    [ShareSDK importQQClass:[QQApiInterface class]
            tencentOAuthCls:[TencentOAuth class]];
    [self initVar];
    //自动登录一下
    NSString* filePath = [CNPersistenceHandler getDocument:@"userinfo.plist"];
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(userInfo){//需要自动登录
        NSString* filePath2 = [CNPersistenceHandler getDocument:@"newVersionLogin.plist"];
        NSMutableDictionary* dic2 = [NSMutableDictionary dictionaryWithContentsOfFile:filePath2];
        if(dic2){
            NSString* code = [dic2 objectForKey:@"isLogin"];
            if([code isEqualToString:@"11"]){//新版本的登陆
                NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
                [params setObject:[userInfo objectForKey:@"uid"] forKey:@"uid"];
                [kApp.networkHandler doRequest_autoLogin:params];
                kApp.isLogin = 2;
            }
        }else{//旧版本的自动登陆
            kApp.isLogin = 11;
        }
    }else{//不自动登录
        if([CNUtil canNetWork]){
            [kApp.cloudManager synTimeWithServer];
        }
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController* nav1 = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
    UINavigationController* nav2 = [[UINavigationController alloc]initWithRootViewController:[[RecordViewController alloc]init]];
//    UINavigationController* nav3 = [[UINavigationController alloc]initWithRootViewController:[[MatchViewController alloc]init]];
    UINavigationController* nav3 = [[UINavigationController alloc]initWithRootViewController:[[ChatListViewController alloc]init]];
    UINavigationController* nav4 = [[UINavigationController alloc]initWithRootViewController:[[CNSettingViewController alloc]init]];
    self.navVCList = [[NSMutableArray alloc]initWithObjects:nav1,nav2,nav3,nav4,nil];
    self.window.rootViewController = [self.navVCList objectAtIndex:0];
    [self.window makeKeyAndVisible];
    //屏幕长亮
//    [[ UIApplication sharedApplication] setIdleTimerDisabled:YES ];
    return YES;
}
// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    NSLog(@"error -- %@",error);
}
- (void)showTab:(int)index{
    self.window.rootViewController = [self.navVCList objectAtIndex:index];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"退到后台");
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
    if(kApp.isRunning == 0){
        if(kApp.locationHandler.isStart == 1){
            [self.locationHandler stopLocation];
        }
    }

    [CNUtil appendUserOperation:@"进入后台"];
#ifdef kTestFlight
    //把字符串记录到plist中
    NSString* filePath = [CNPersistenceHandler getDocument:@"debug.plist"];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSString* strHistory;
    if(dic == nil){
        dic = [[NSMutableDictionary alloc]init];
        strHistory = @"";
    }else{
        strHistory = [dic objectForKey:@"userOperation"];
    }
    strHistory = [NSString stringWithFormat:@"%@\n%@",strHistory,self.userOperation];
    [dic setObject:strHistory forKey:@"userOperation"];
    [dic writeToFile:filePath atomically:YES];
    self.userOperation = [NSMutableString stringWithString:@""];
#else
    
# endif
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"回到前台");
    if(kApp.locationHandler.isStart == 0){
        [self.locationHandler startGetLocation];
    }
    [CNUtil appendUserOperation:[NSString stringWithFormat:@"回到前台，时间：%@",[CNUtil getTimeFromTimestamp_ymdhm:[CNUtil getNowTime]]]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}
//托管对象
-(NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel!=nil) {
        return _managedObjectModel;
    }
    NSURL* modelURL=[[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel=[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _managedObjectModel=[NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}
//托管对象上下文
-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext!=nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator=[self persistentStoreCoordinator];
    if (coordinator!=nil) {
        _managedObjectContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
//持久化存储协调器
// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error = nil;
    
    //升级数据库版本
    NSDictionary *options =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
     [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
     nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         */
        abort();
    }
    return _persistentStoreCoordinator;
}
#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)initVar{
    self.networkHandler = [[CNNetworkHandler alloc]init];
    [self.networkHandler startQueue];//开启队列
    self.locationHandler = [[CNLocationHandler alloc]init];
    self.voiceHandler = [[CNVoiceHandler alloc]init];
    [self.voiceHandler initPlayer];
    self.cloudManager = [[CNCloudRecord alloc]init];
    self.friendHandler = [[FriendsHandler alloc]init];
    self.loginHandler = [[LoginDoneHandler alloc]init];
    self.friendHandler.friendList1NeedRefresh = YES;
    self.friendHandler.friendList2NeedRefresh = YES;
    self.pid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSLog(@"pid is %@",pid);
    self.ua = [NSString stringWithFormat:@"I_%@,i_%@",[[UIDevice currentDevice] systemVersion],ClIENT_VERSION];
    NSLog(@"ua is %@",self.ua);
//    kApp.geosHandler = [[CNTestGEOS alloc]init];
//    [kApp.geosHandler initFromFile:kTrackName];
    self.avatarDic = [[NSMutableDictionary alloc]init];
    //初始化udp
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    
    if (![self.udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![self.udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    NSLog(@"这里也新建了一个udp实例");
}
+ (CNAppDelegate*)getApplicationDelegate{
    return (CNAppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (void)match_save2plist{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSString stringWithFormat:@"%f",kApp.match_historydis] forKey:@"match_historydis"];
    [dic setObject:[NSString stringWithFormat:@"%f",kApp.match_totalDisTeam] forKey:@"match_totalDisTeam"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_targetkm] forKey:@"match_targetkm"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_historySecond] forKey:@"match_historySecond"];
    [dic setObject:[NSString stringWithFormat:@"%f",kApp.match_startdis] forKey:@"match_startdis"];
    [dic setObject:[NSString stringWithFormat:@"%f",kApp.match_currentLapDis] forKey:@"match_currentLapDis"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_countPass] forKey:@"match_countPass"];
    if(kApp.match_time_last_in_track < 1){
        kApp.match_time_last_in_track = [CNUtil getNowTimeDelta];
    }
    [dic setObject:[NSString stringWithFormat:@"%llu",kApp.match_time_last_in_track] forKey:@"match_time_last_in_track"];
//    [dic setObject:kApp.match_pointsString forKey:@"match_pointsString"];
    
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_score] forKey:@"match_score"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_km_target_personal] forKey:@"match_km_target_personal"];
    [dic setObject:[NSString stringWithFormat:@"%i",kApp.match_km_start_time] forKey:@"match_km_start_time"];
    NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
    [dic writeToFile:filePath atomically:YES];
}



+ (void)makeMatchTest{
//    NSString* testString = @"116.390053 39.968191, 116.390114 39.96743, 116.390148 39.966718, 116.390167 39.966443, 116.390167 39.966385, 116.390171 39.966344, 116.390171 39.966321, 116.390167 39.966306, 116.390163 39.966298, 116.390156 39.966288, 116.390148 39.966281, 116.390141 39.966276, 116.390129 39.966273, 116.390118 39.96627, 116.390038 39.96626, 116.389919 39.966245, 116.389721 39.966227, 116.389687 39.966222, 116.389656 39.966217, 116.38961 39.966207, 116.389553 39.966192, 116.389462 39.966164, 116.389221 39.966085, 116.388733 39.965965, 116.388462 39.965925, 116.388195 39.965899, 116.388195 39.965899, 116.388268 39.966054, 116.388275 39.96727, 116.388271 39.968147, 116.389381 39.968168, 116.389481 39.968173, 116.390053 39.968191";
    NSString* testString = @"116.390053 39.968191, 116.390114 39.96743, 116.390148 39.966718, 116.390167 39.966443, 116.390167 39.966385, 116.390171 39.966344, 116.390171 39.966321, 116.390167 39.966306, 116.390163 39.966298, 116.390156 39.966288, 116.390148 39.966281, 116.390141 39.966276, 0 0, 116.389687 39.966222, 116.389656 39.966217, 116.38961 39.966207, 116.389553 39.966192, 116.389462 39.966164, 116.389221 39.966085, 116.388733 39.965965, 116.388462 39.965925, 0 0, 116.388275 39.96727, 116.388271 39.968147, 116.389381 39.968168";
    kApp.match_pointList = [[NSMutableArray alloc]init];
    NSArray* pointlist = [testString componentsSeparatedByString:@", "];
    int i=0;
    for(i=0;i<[pointlist count];i++){
        CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
        NSArray* lonlats = [[pointlist objectAtIndex:i] componentsSeparatedByString:@" "];
        point.lon = [[lonlats objectAtIndex:0]doubleValue];
        point.lat = [[lonlats objectAtIndex:1]doubleValue];
        [kApp.match_pointList addObject:point];
    }
}
+ (void)finishThisRun{
    kApp.isbaton = 0;
    [CNAppDelegate saveMatchToRecord];
    [kApp.timer_one_point invalidate];
    [kApp.timer_secondplusplus invalidate];
    [kApp.match_timer_report invalidate];
    NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
    [CNPersistenceHandler DeleteSingleFile:filePath];
}
+ (void)popupWarningGPSOpen{
    CNWarningGPSOpenViewController* warningVC = [[CNWarningGPSOpenViewController alloc]init];
    UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navVC.modalPresentationStyle = UIModalPresentationCustom;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:navVC animated:YES completion:^(void){NSLog(@"pop");}];
}
+ (void)popupWarningGPSWeak{
    CNWarningGPSWeakViewController* warningVC = [[CNWarningGPSWeakViewController alloc]init];
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    warningVC.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:warningVC animated:YES completion:^(void){NSLog(@"pop");}];
}
+ (void)popupWarningBackground{
    CNWarningBackGroundViewController* warningVC = [[CNWarningBackGroundViewController alloc]init];
    UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navVC.modalPresentationStyle = UIModalPresentationCustom;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:navVC animated:YES completion:^(void){NSLog(@"pop");}];
}
+ (void)popupWarningNotInStartZone{
    CNWarningNotInStartZoneViewController* warningVC = [[CNWarningNotInStartZoneViewController alloc]init];
    UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
    navVC.modalPresentationStyle = UIModalPresentationCustom;
    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootViewController presentViewController:navVC animated:YES completion:^(void){NSLog(@"pop");}];
}
//+ (void)popupWarningCheckTime{
//    CNWarningCheckTimeViewController* warningVC = [[CNWarningCheckTimeViewController alloc]init];
//    UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
//    navVC.modalPresentationStyle = UIModalPresentationCustom;
//    warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
//    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    [rootViewController presentViewController:navVC animated:NO completion:^(void){NSLog(@"pop");}];
//}
+ (void)popupWarningCloud:(BOOL)visible{
    [CNUtil appendUserOperation:@"开始同步"];
    if(visible){
        CNWarningCloudingViewController* warningVC = [[CNWarningCloudingViewController alloc]init];
        UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:warningVC];
        navVC.modalPresentationStyle = UIModalPresentationCustom;
        warningVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [rootViewController presentViewController:navVC animated:NO completion:^(void){NSLog(@"pop");}];
    }else{
        [kApp.cloudManager startCloud];
    }
}

+ (CNGPSPoint4Match*)test_getOnePoint{
    NSMutableArray* testlist = [[NSMutableArray alloc]init];
    NSArray* pointlist = [kApp.match_track_line componentsSeparatedByString:@", "];
    kApp.matchtestdatalength = (int)[pointlist count];
    int i=0;
    for(i=0;i<[pointlist count];i++){
        CNGPSPoint4Match* point = [[CNGPSPoint4Match alloc]init];
        NSArray* lonlats = [[pointlist objectAtIndex:i] componentsSeparatedByString:@" "];
        point.lon = [[lonlats objectAtIndex:0]doubleValue];
        point.lat = [[lonlats objectAtIndex:1]doubleValue];
        point.time = [CNUtil getNowTimeDelta];
        [testlist addObject:point];
    }
    CNGPSPoint4Match* testpoint = [testlist objectAtIndex:kApp.testIndex];
    return testpoint;
}
+ (void)whatShouldIdo{
    kApp.voiceOn = 1;//开启语音
    //先判断时间
    NSString* matchstage = [CNUtil getMatchStage];
    if([matchstage isEqualToString:@"beforeMatch"]){//赛前5分钟还要之前
        kApp.match_timer_check_countdown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(check_start_match) userInfo:nil repeats:YES];
    }else if([matchstage isEqualToString:@"closeToMatch"]){//赛前5分钟到比赛正式开始
        if(kApp.isbaton == 1){//第一棒
            [CNAppDelegate ForceGoMatchPage:@"countdown"];
        }else{//不是第一棒
            [CNAppDelegate ForceGoMatchPage:@"matchWatch"];
        }
    }else if([matchstage isEqualToString:@"isMatching"]){//正式比赛时间
        if(kApp.isbaton == 1){//正在跑
            //通过plist文件判断是否是崩溃重进
            NSString* filePath = [CNPersistenceHandler getDocument:@"match_historydis.plist"];
            NSDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
            if(dic == nil){//没有这个文件，则说明上次不是比赛中闪退的
                if(kApp.isbaton == 1 && kApp.match_totalDisTeam < 1){//如果是第一棒有个特殊条件才能启动，就是必须在出发区
                    if([CNAppDelegate isInStartZone]){
                        [CNAppDelegate ForceGoMatchPage:@"matchRun_normal"];
                    }else{
                        kApp.canStartButNotInStartZone = YES;
                        [CNAppDelegate popupWarningNotInStartZone];
                    }
                }else{
                    [CNAppDelegate ForceGoMatchPage:@"matchRun_normal"];
                }
            }else{
                [CNAppDelegate ForceGoMatchPage:@"matchRun_crash"];
            }
        }else{//没再跑
            [CNAppDelegate ForceGoMatchPage:@"matchWatch"];
        }
    }else{//赛后
        
    }
}
+ (BOOL)isInStartZone{
//    CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(kApp.locationHandler.userLocation_lat, kApp.locationHandler.userLocation_lon);
//    CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
//#ifdef SIMULATORTEST
//    return YES;
////    return [kApp.geosHandler isInTheStartZone:kApp.locationHandler.userLocation_lon :kApp.locationHandler.userLocation_lat];
//#else
//    return [kApp.geosHandler isInTheStartZone:encryptionPoint.longitude :encryptionPoint.latitude];
//# endif
    return YES;
}
+ (void)check_start_match{
    if([CNUtil getNowTimeDelta] >= kApp.match_before5min_timestamp){//进入了赛前5分钟
        [kApp.match_timer_check_countdown invalidate];
        if(kApp.isbaton == 1){//第一棒
            [CNAppDelegate ForceGoMatchPage:@"countdown"];
        }else{//不是第一棒
            [CNAppDelegate ForceGoMatchPage:@"matchWatch"];
        }
    }
}
+ (void)ForceGoMatchPage:(NSString*)target{
//    if([target isEqualToString:@"countdown"]){//倒计时
//        CNMatchCountDownViewController* matchCountdownVC = [[CNMatchCountDownViewController alloc]init];
//        long long nowTimeSecond = [CNUtil getNowTimeDelta];
//        matchCountdownVC.startSecond = (int)(kApp.match_start_timestamp - nowTimeSecond);
//        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:matchCountdownVC];
//        kApp.window.rootViewController = kApp.navigationController;
//    }else if([target isEqualToString:@"matchWatch"]){//看比赛
//        CNGroupInfoViewController* groupInfoVC = [[CNGroupInfoViewController alloc]init];
//        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:groupInfoVC];
//        kApp.window.rootViewController = kApp.navigationController;
//    }else if([target isEqualToString:@"matchRun_normal"]){//比赛跑步，正常进
//        CNMatchMainViewController* matchMainVC = [[CNMatchMainViewController alloc]init];
//        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:matchMainVC];
//        kApp.window.rootViewController = kApp.navigationController;
//    }else if([target isEqualToString:@"matchRun_crash"]){//比赛跑步，崩溃进入
//        CNMatchMainRecomeViewController* matchMainVC = [[CNMatchMainRecomeViewController alloc]init];
//        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:matchMainVC];
//        kApp.window.rootViewController = kApp.navigationController;
//    }else if([target isEqualToString:@"finish"]){//结束比赛
//        CNFinishViewController* finishVC = [[CNFinishViewController alloc]init];
//        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:finishVC];
//        kApp.window.rootViewController = kApp.navigationController;
//    }else if([target isEqualToString:@"finishTeam"]){//结束整队比赛
//        kApp.isbaton = 0;
//        CNFinishTeamMatchViewController* finishVC = [[CNFinishTeamMatchViewController alloc]init];
//        kApp.navigationController = [[UINavigationController alloc] initWithRootViewController:finishVC];
//        kApp.window.rootViewController = kApp.navigationController;
//    }
}
+ (void)saveMatchToRecord{
    //计算一下获得的积分：
    if(kApp.match_totaldis < 1000){
        kApp.match_score = 2;
    }else{
        int meter = (int)kApp.match_totaldis % 1000;
        if(meter > 500){
            kApp.match_score += 4;
        }
    }
    //计算点序列
    NSMutableString* pointString = [[NSMutableString alloc]initWithString:@""];
    for(int i=0;i<[kApp.match_pointList count];i++){
        CNGPSPoint4Match* point = [kApp.match_pointList objectAtIndex:i];
        [pointString appendString:[NSString stringWithFormat:@"%f %f,",point.lon,point.lat]];
    }
    if([pointString hasSuffix:@","]){
        [pointString setString:[pointString substringToIndex:([pointString length]-1)]];
    }
    RunClass * runClass  = [NSEntityDescription insertNewObjectForEntityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    runClass.rid = [NSString stringWithFormat:@"%lli",[CNUtil getNowTime]];
    runClass.targetType = [NSNumber numberWithInt:0];//自由
    runClass.howToMove = [NSNumber numberWithInt:1];//跑步
    runClass.gpsString = pointString;
    runClass.feeling = [NSNumber numberWithInt:0];
    runClass.runway = [NSNumber numberWithInt:0];
    runClass.distance = [NSNumber numberWithFloat:kApp.match_totaldis];
    runClass.duration = [NSNumber numberWithInt:kApp.match_historySecond];
    int speed_second = 1000*(kApp.match_historySecond/kApp.match_totaldis);
    runClass.secondPerKm = [NSNumber numberWithFloat:speed_second];
    runClass.isMatch = [NSNumber numberWithInt:1];
    CNGPSPoint4Match* firstPoint = [kApp.match_pointList objectAtIndex:0];
    long long stamp = firstPoint.time;
    runClass.startTime = [NSNumber numberWithLongLong:stamp];
    runClass.score = [NSNumber numberWithInt:kApp.match_score];
    
    NSError *error = nil;
    if (![kApp.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@", error);
        abort();
    }
    NSLog(@"add success");
    
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
        [record_dic setObject:@"0" forKey:@"total_score"];
    }
    double total_distance = [[record_dic objectForKey:@"total_distance"]doubleValue];
    int total_count = [[record_dic objectForKey:@"total_count"]intValue];
    int total_time = [[record_dic objectForKey:@"total_time"]intValue];
    int total_score = [[record_dic objectForKey:@"total_score"]intValue];
    total_distance += kApp.match_totaldis;
    total_count++;
    total_time += kApp.match_historySecond;
    total_score += kApp.match_score;
    [record_dic setObject:[NSString stringWithFormat:@"%f",total_distance] forKey:@"total_distance"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_count] forKey:@"total_count"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_time] forKey:@"total_time"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_score] forKey:@"total_score"];
    [record_dic writeToFile:filePath_record atomically:YES];
}

+ (void)saveRun{
    //存储到数据库
    
}
- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}
//- (void)needRegisterMobUser{
//    NSString* filePath = [CNPersistenceHandler getDocument:@"registerMob.plist"];
//    NSMutableDictionary* registerMobDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
//    if(registerMobDic == nil){//没注册过
//        [self registerMobUser];
//    }
//}
//- (void)registerMobUser{
//    SMS_UserInfo* user = [[SMS_UserInfo alloc]init];
//    user.phone = [self.userInfoDic objectForKey:@"phone"];
//    user.nickname = [self.userInfoDic objectForKey:@"nickname"];
//    user.uid = [NSString stringWithFormat:@"%@",[self.userInfoDic objectForKey:@"uid"]];
//    if([[self.userInfoDic allKeys] containsObject:@"imgpath"]){
//        user.avatar = [NSString stringWithFormat:@"%@%@",kApp.imageurl,[self.userInfoDic objectForKey:@"imgpath"]];
//    }else{
//        user.avatar = @"";
//    }
//    
//    NSLog(@"phone is %@",user.phone);
//    NSLog(@"nickname is %@",user.nickname);
//    NSLog(@"uid is %@",user.uid);
//    NSLog(@"avatar is %@",user.avatar);
//    [SMS_SDK submitUserInfo:user
//                     result:^(enum SMS_ResponseState state) {
//                         if (state == SMS_ResponseStateSuccess)
//                         {
//                             NSLog(@"mob提交成功--------");
////                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提交成功"
////                                                                             message:nil
////                                                                            delegate:self
////                                                                   cancelButtonTitle:@"OK"
////                                                                   otherButtonTitles:nil, nil];
////                             [alert show];
//                             NSString* filePath = [CNPersistenceHandler getDocument:@"registerMob.plist"];
//                             NSMutableDictionary* registerMobDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
//                             if(registerMobDic == nil){
//                                 [registerMobDic setObject:@"1" forKey:@"isRegister"];
//                                 [registerMobDic writeToFile:filePath atomically:YES];
//                             }
//                         }
//                         else if (state == SMS_ResponseStateFail)
//                         {
//                             NSLog(@"mob提交失败--------");
////                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提交失败"
////                                                                             message:nil
////                                                                            delegate:self
////                                                                   cancelButtonTitle:@"OK"
////                                                                   otherButtonTitles:nil, nil];
////                             [alert show];
//                         }
//                     }];
//}

- (void)didUnreadMessagesCountChanged{
    [CNAppDelegate howManyMessageToRead];
}
+ (void)howManyMessageToRead{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
    NSLog(@"unreadCount is %i",(int)unreadCount);
    kApp.unreadMessageCount = (int)unreadCount;
}
//udp回调
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        NSLog(@"接收服务器响应:%@",msg);
    }
}
#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}
// 已经同意并且加入群组后的回调
- (void)didAcceptInvitationFromGroup:(EMGroup *)group
                               error:(EMError *)error
{
    if(error)
    {
        return;
    }
    
    NSString *groupTag = group.groupSubject;
    if ([groupTag length] == 0) {
        groupTag = group.groupId;
    }
    
    NSLog(@"您已加入跑团:%@",groupTag);
    friendHandler.friendList1NeedRefresh = YES;
}
// 离开群组回调
- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    NSString *tmpStr = group.groupSubject;
    if (!tmpStr || tmpStr.length == 0) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *obj in groupArray) {
            if ([obj.groupId isEqualToString:group.groupId]) {
                tmpStr = obj.groupSubject;
                break;
            }
        }
    }
    if (reason == eGroupLeaveReason_BeRemoved) {
        NSLog(@"您已被跑团:%@移出！",tmpStr);
    }else if (reason == eGroupLeaveReason_Destroyed) {
        NSLog(@"跑团%@已经被解散",tmpStr);
    }
    friendHandler.friendList1NeedRefresh = YES;
}
#pragma mark - IChatManagerDelegate 好友变化

- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
    NSLog(@"%@请求加您为好友！",username);
    friendHandler.friendList1NeedRefresh = YES;
    friendHandler.friendList2NeedRefresh = YES;
}

- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd
{
    NSLog(@"好友数量发生变化");
    //这个对删除好友起作用
    friendHandler.friendList1NeedRefresh = YES;
}
//由于测试中这个为其作用不用
//- (void)didRemovedByBuddy:(NSString *)username
//{
//    NSLog(@"%@将您从好友列表里删除",username);
//    friendHandler.friendList1NeedRefresh = YES;
//}

//经测试发现会收到请求加您为好友回调
//- (void)didAcceptedByBuddy:(NSString *)username
//{
//    NSLog(@"%@接受了您的好友请求",username);
//    friendHandler.friendList1NeedRefresh = YES;
//}

- (void)didRejectedByBuddy:(NSString *)username
{
    NSLog(@"%@忽略了您的好友请求",username);
    friendHandler.friendList1NeedRefresh = YES;
    friendHandler.friendList2NeedRefresh = YES;
}

//- (void)didAcceptBuddySucceed:(NSString *)username
//{
//    NSLog(@"您接受了%@的好友请求",username);
//    friendHandler.friendList1NeedRefresh = YES;
//}

void UncaughtExceptionHandler(NSException *exception) {
    /**
     *  获取异常崩溃信息
     */
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
    [CNUtil appendUserOperation:content];
//    /**
//     *  把异常崩溃信息发送至开发者邮件
//     */
//    NSMutableString *mailUrl = [NSMutableString string];
//    [mailUrl appendString:@"mailto:test@qq.com"];
//    [mailUrl appendString:@"?subject=程序异常崩溃，请配合发送异常报告，谢谢合作！"];
//    [mailUrl appendFormat:@"&body=%@", content];
//    // 打开地址
//    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
    //把字符串记录到plist中
    NSString* filePath = [CNPersistenceHandler getDocument:@"debug.plist"];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSString* strHistory;
    if(dic == nil){
        dic = [[NSMutableDictionary alloc]init];
        strHistory = @"";
    }else{
        strHistory = [dic objectForKey:@"userOperation"];
    }
    strHistory = [NSString stringWithFormat:@"%@\n%@",strHistory,kApp.userOperation];
    [dic setObject:strHistory forKey:@"userOperation"];
    [dic writeToFile:filePath atomically:YES];
    kApp.userOperation = [NSMutableString stringWithString:@""];
}
@end

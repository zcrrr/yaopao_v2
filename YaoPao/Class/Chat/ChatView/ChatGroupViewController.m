/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "ChatGroupViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "SRRefreshView.h"
#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
#import "DXFaceView.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "ChatSendHelper.h"
#import "MessageReadManager.h"
#import "MessageModelManager.h"
#import "LocationViewController.h"
#import "ChatGroupDetailViewController.h"
#import "UIViewController+HUD.h"
#import "WCAlertView.h"
#import "NSDate+Category.h"
#import "DXMessageToolBar.h"
#import "DXChatBarMoreView.h"
#import "ChatGroupViewController+Category.h"
#import "ZCGroupSettingViewController.h"
#import "FriendInfo.h"
#import "FriendsHandler.h"
#import "ChatDemoUIDefine.h"
#import "CNEncryption.h"
#import "GroupLocationAnnotationView.h"
#import "CNUtil.h"
#import "FriendsHandler.h"
#import "Toast+UIView.h"
#define KPageCount 20

@interface ChatGroupViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SRRefreshDelegate, IChatManagerDelegate, DXChatBarMoreViewDelegate, DXMessageToolBarDelegate, LocationViewDelegate, IDeviceManagerDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
    
    NSInteger _recordingCount;
    
    dispatch_queue_t _messageQueue;
    
    NSMutableArray *_messages;
    BOOL _isScrollToBottom;
}

@property (nonatomic) BOOL isChatGroup;
@property (strong, nonatomic) NSString *chatter;



@property (strong, nonatomic) NSMutableArray *dataSource;//tableView数据源
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (strong, nonatomic) NSDate *chatTagDate;

@property (strong, nonatomic) NSMutableArray *messages;
@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;

@end

@implementation ChatGroupViewController
@synthesize from;
@synthesize groupname;
@synthesize selectTab;
@synthesize button_myGroup;
@synthesize button_otherGroup;
@synthesize view_line_select1;
@synthesize view_line_select2;
@synthesize mapView;
@synthesize timer_update;
@synthesize annoArray;
@synthesize locations;
@synthesize isSetRegion;
@synthesize groupMemberDic;
@synthesize isFromRunning;
@synthesize mapContainer;
@synthesize switchButton;
@synthesize isRequestingLocation;
@synthesize annotation_me;
- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isPlayingAudio = NO;
        _chatter = chatter;
        _isChatGroup = isGroup;
        _messages = [NSMutableArray array];
        
        //根据接收者的username获取当前会话的管理者
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter isGroup:_isChatGroup];
        [_conversation markAllMessagesAsRead:YES];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerBecomeActive];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:247.0/255.0 alpha:1]];
    self.annoArray = [[NSMutableArray alloc]init];
    //zc
    UIView* topbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 63)];
    topbar.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:166.0/255.0 blue:1 alpha:1];
    [self.view addSubview:topbar];
    UILabel* label_title = [[UILabel alloc]initWithFrame:CGRectMake(87, 23, 146, 35)];
    [label_title setTextAlignment:NSTextAlignmentCenter];
    label_title.text = self.groupname;
    label_title.font = [UIFont systemFontOfSize:16];
    label_title.textColor = [UIColor whiteColor];
    [topbar addSubview:label_title];
    UIButton * button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    button_back.frame = CGRectMake(6, 26, 21, 29);
    [button_back setBackgroundImage:[UIImage imageNamed:@"back_v2.png"] forState:UIControlStateNormal];
    button_back.tag = 0;
    [button_back addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topbar addSubview:button_back];
    
    UIButton * button_detail = [UIButton buttonWithType:UIButtonTypeCustom];
    button_detail.frame = CGRectMake(270, 26, 50, 30);
    [button_detail setTitle:@"详情" forState:UIControlStateNormal];
    button_detail.tag = 1;
    [button_detail addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if(!self.isFromRunning){
        [topbar addSubview:button_detail];
    }
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
#warning 以下三行代码必须写，注册为SDK的ChatManager的delegate
    [[[EaseMob sharedInstance] deviceManager] addDelegate:self onQueue:nil];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    _isScrollToBottom = YES;
    
//    [self setupBarButtonItem];
    
    //添加tab按钮
    UIView* tabBar = [[UIView alloc]initWithFrame:CGRectMake(0, 63, 320, 43)];
    tabBar.backgroundColor = [UIColor whiteColor];
    
    self.button_myGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button_myGroup.frame = CGRectMake(0, 0, 160, 43);
    [self.button_myGroup setTitle:@"会话" forState:UIControlStateNormal];
    [self.button_myGroup setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.button_myGroup.titleLabel.font = [UIFont systemFontOfSize:13];
    self.button_myGroup.tag = 2;
    [self.button_myGroup addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view_line_select1 = [[UIView alloc]initWithFrame:CGRectMake(0, 42, 160, 1)];
    self.view_line_select1.backgroundColor = RGBACOLOR(58, 165, 255, 1);
    
    self.button_otherGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button_otherGroup.frame = CGRectMake(160, 0, 160, 43);
    [self.button_otherGroup setTitle:@"地图" forState:UIControlStateNormal];
    [self.button_otherGroup setTitleColor:RGBACOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
    self.button_otherGroup.titleLabel.font = [UIFont systemFontOfSize:13];
    self.button_otherGroup.tag = 3;
    [self.button_otherGroup addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view_line_select2 = [[UIView alloc]initWithFrame:CGRectMake(160, 42, 160, 1)];
    self.view_line_select2.backgroundColor = RGBACOLOR(58, 165, 255, 1);
    self.view_line_select2.hidden = YES;
    
    UIView* view_line_tab = [[UIView alloc]initWithFrame:CGRectMake(160, 0, 0.5, 43)];
    view_line_tab.backgroundColor = RGBACOLOR(246, 246, 247, 1);
    
    
    
    [tabBar addSubview:self.button_myGroup];
    [tabBar addSubview:self.view_line_select1];
    [tabBar addSubview:self.button_otherGroup];
    [tabBar addSubview:self.view_line_select2];
    [tabBar addSubview:view_line_tab];
    
    [self.view addSubview:tabBar];
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self.view addSubview:self.chatToolBar];
    
    
    self.mapContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 63+43, self.view.frame.size.width, self.view.frame.size.height-43-63)];
    self.mapContainer.backgroundColor = [UIColor whiteColor];
    self.mapView=[[MAMapView alloc] initWithFrame:CGRectMake(0, 0, self.mapContainer.frame.size.width, self.mapContainer.frame.size.height-55)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.showsUserLocation = YES;
    [self.mapContainer addSubview:self.mapView];
    
    UILabel* label_switch_des = [[UILabel alloc]initWithFrame:CGRectMake(10, self.mapContainer.frame.size.height-55, 250, 55)];
    label_switch_des.text = @"向跑团上报我的位置";
    label_switch_des.font = [UIFont systemFontOfSize:14];
    label_switch_des.textColor = [UIColor blackColor];
    [self.mapContainer addSubview:label_switch_des];
    
    self.switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(260, self.mapContainer.frame.size.height-55+13, 20, 10)];
    [self.switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.mapContainer addSubview:self.switchButton];
    
    
    [self.view addSubview:self.mapContainer];
    self.mapContainer.hidden = YES;
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    //请求组信息
    if(kApp.friendHandler.groupNeedRefresh == nil){
        kApp.friendHandler.groupNeedRefresh = [[NSMutableDictionary alloc]init];
        [self requestGroupMember];
    }else{//判断是否有该组信息
        self.groupMemberDic = [kApp.friendHandler.groupNeedRefresh objectForKey:_chatter];
        if(self.groupMemberDic == nil){//没有该组信息同样需要刷新
            [self requestGroupMember];
        }
    }
    //通过会话管理者获取已收发消息
    [self loadMoreMessages];
}
- (void)switchAction:(id)sender{
    if(self.switchButton.on == YES){
        NSLog(@"打开位置");
        [self setShareLocation:YES];
    }else{
        NSLog(@"关闭位置");
        [self setShareLocation:NO];
    }
}
- (void)setShareLocation:(BOOL)isShare{
    NSString* des = isShare?@"true":@"false";
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    [params setObject:_chatter forKey:@"groupid"];
    [params setObject:des forKey:@"enable"];
    kApp.networkHandler.delegate_enableMyLocationInGroup = self;
    [kApp.networkHandler doRequest_enableMyLocationInGroup:params];
    [self showHudInView:self.view hint:@"请稍后..."];
}
- (void)enableMyLocationInGroupDidFailed:(NSString *)mes{
    __weak ChatGroupViewController *weakSelf = self;
    [weakSelf hideHud];
    if(self.switchButton.on){
        self.switchButton.on = NO;
    }else{
        self.switchButton.on = YES;
    }
    [kApp.window makeToast:@"设置失败，请稍后重试！"];
}
- (void)enableMyLocationInGroupDidSuccess:(NSDictionary *)resultDic{
    __weak ChatGroupViewController *weakSelf = self;
    [weakSelf hideHud];
    [kApp.window makeToast:@"设置成功！"];
    //本地记录最新的设置：
    if(self.switchButton.on){
        if(!kApp.isOpenShareLocation){
            kApp.isOpenShareLocation = YES;
        }
        if(![kApp.friendHandler.groupIsShareLocation containsObject:_chatter]){
            [kApp.friendHandler.groupIsShareLocation addObject:_chatter];
        }
        [self.mapView addAnnotation:self.annotation_me];
    }else{
        if([kApp.friendHandler.groupIsShareLocation containsObject:_chatter]){
            [kApp.friendHandler.groupIsShareLocation removeObject:_chatter];
            if([kApp.friendHandler.groupIsShareLocation count] == 0){//如果一个也么有了，就不用上报了
                if(kApp.isOpenShareLocation){
                    kApp.isOpenShareLocation = NO;
                }
            }
        }
        [self.mapView removeAnnotation:self.annotation_me];
    }
}
- (void)requestGroupMember{
    //获取所有成员
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    [params setObject:_chatter forKey:@"groupid"];
    kApp.networkHandler.delegate_groupMember = self;
    [kApp.networkHandler doRequest_groupMember:params];
    [self showHudInView:self.view hint:@"请稍后..."];
}
- (void)groupMemberDidFailed:(NSString *)mes{
    __weak ChatGroupViewController *weakSelf = self;
    [weakSelf hideHud];
}
- (void)groupMemberDidSuccess:(NSDictionary *)resultDic{
    self.groupMemberDic = [[NSMutableDictionary alloc]init];
    NSArray* array = [resultDic objectForKey:@"users"];
    for(NSDictionary* dic in array){
        NSString* phone = [dic objectForKey:@"phone"];
        [self.groupMemberDic setObject:dic forKey:phone];
    }
    NSString* isShareLocation = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"enable"]];
    NSLog(@"isShareLocation is %@",isShareLocation);
    [kApp.friendHandler.groupNeedRefresh setObject:self.groupMemberDic forKey:_chatter];
    if([isShareLocation isEqualToString:@"1"]){//上报
        if(![kApp.friendHandler.groupIsShareLocation containsObject:_chatter]){
            [kApp.friendHandler.groupIsShareLocation addObject:_chatter];
        }
    }
    [self.tableView reloadData];
    __weak ChatGroupViewController *weakSelf = self;
    [weakSelf hideHud];
    
}
- (void)buttonClicked:(id)sender{
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"返回");
            if([self.from isEqualToString:@"creatGroup"]){
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        case 1:
        {
            NSLog(@"详情");
            [self.view endEditing:YES];
            if (_isChatGroup) {
                ZCGroupSettingViewController *detailController = [[ZCGroupSettingViewController alloc] init];
                detailController.chatGroupId = _chatter;
                [self.navigationController pushViewController:detailController animated:YES];
            }
            break;
        }
        case 2:
        {
            NSLog(@"会话");
            [self.view endEditing:YES];
            if(self.selectTab == 0){
                return;
            }else{
                [self.button_myGroup setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [self.button_otherGroup setTitleColor:RGBACOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
                self.view_line_select1.hidden = NO;
                self.view_line_select2.hidden = YES;
                self.tableView.hidden = NO;
                self.mapContainer.hidden = YES;
                self.selectTab = 0;
                [self.timer_update invalidate];
            }
            break;
        }
        case 3:
        {
            NSLog(@"地图");
            [self.view endEditing:YES];
            if(self.selectTab == 1){
                return;
            }else{
                if(self.annotation_me == nil && self.mapView.userLocation.coordinate.latitude > 0){
                    self.annotation_me = [[MAPointAnnotation alloc] init];
                    self.annotation_me.coordinate = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
                    self.annotation_me.title = @"1000";
                }
                [self.button_myGroup setTitleColor:RGBACOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
                [self.button_otherGroup setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                self.view_line_select1.hidden = YES;
                self.view_line_select2.hidden = NO;
                self.tableView.hidden = YES;
                self.mapContainer.hidden = NO;
                [self setShareLocationSwitch];
                self.selectTab = 1;
                [self updataMemberLocations];
                self.timer_update = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updataMemberLocations) userInfo:nil repeats:YES];
            }
            break;
        }
        default:
            break;
    }
}
- (void)setShareLocationSwitch{
    if([kApp.friendHandler.groupIsShareLocation containsObject:_chatter]){
        self.switchButton.on = YES;
        [self.mapView addAnnotation:annotation_me];
    }else{
        self.switchButton.on = NO;
    }
}
- (void)updataMemberLocations{
    if(self.isRequestingLocation){//正在请求。。。就不用请求了
        return;
    }
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    [params setObject:_chatter forKey:@"groupid"];
    [params setObject:@"1.0" forKey:@"version"];
    kApp.networkHandler.delegate_memberLocations = self;
    [kApp.networkHandler doRequest_memberLocations:params];
    [self showHudInView:self.view hint:@"请稍后..."];
    self.view.userInteractionEnabled = NO;
    self.isRequestingLocation = YES;
}
- (void)memberLocationsDidFailed:(NSString *)mes{
    self.isRequestingLocation = NO;
    self.view.userInteractionEnabled = YES;
    __weak ChatGroupViewController *weakSelf = self;
    [weakSelf hideHud];
}
- (void)memberLocationsDidSuccess:(NSDictionary *)resultDic{
    self.isRequestingLocation = NO;
    self.view.userInteractionEnabled = YES;
    __weak ChatGroupViewController *weakSelf = self;
    [weakSelf hideHud];
    [self.mapView removeAnnotations:self.annoArray];
    [self.annoArray removeAllObjects];
    self.locations = [resultDic objectForKey:@"locations"];
    double min_lon = 0;
    double min_lat = 0;
    double max_lon = 0;
    double max_lat = 0;
    
    for(int i = 0 ; i<[self.locations count];i++){
        NSDictionary* dic = [self.locations objectAtIndex:i];
        //剔除自己
        NSString* uid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        NSString* myuid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
        if([uid isEqualToString:myuid])continue;
        double lon = [[dic objectForKey:@"lon"]doubleValue];
        double lat = [[dic objectForKey:@"lat"]doubleValue];
        if(i == 0){
            min_lon = lon;
            min_lat = lat;
            max_lon = lon;
            max_lat = lat;
        }
        MAPointAnnotation* annotation = [[MAPointAnnotation alloc] init];
        CLLocationCoordinate2D wgs84Point = CLLocationCoordinate2DMake(lat, lon);
        CLLocationCoordinate2D encryptionPoint = [CNEncryption encrypt:wgs84Point];
        annotation.coordinate = CLLocationCoordinate2DMake(encryptionPoint.latitude, encryptionPoint.longitude);
        annotation.title = [NSString stringWithFormat:@"%i",i];
        [self.mapView addAnnotation:annotation];
        [self.annoArray addObject:annotation];
        
        if(annotation.coordinate.longitude < min_lon){
            min_lon = annotation.coordinate.longitude;
        }
        if(annotation.coordinate.latitude < min_lat){
            min_lat = annotation.coordinate.latitude;
        }
        if(annotation.coordinate.longitude > max_lon){
            max_lon = annotation.coordinate.longitude;
        }
        if(annotation.coordinate.latitude > max_lat){
            max_lat = annotation.coordinate.latitude;
        }
    }
    if(!self.isSetRegion && min_lon > 1){
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake((min_lat+max_lat)/2, (min_lon+max_lon)/2);
        MACoordinateSpan span = MACoordinateSpanMake(max_lat-min_lat+0.005, max_lon-min_lon+0.005);
        MACoordinateRegion region = MACoordinateRegionMake(center, span);
        [self.mapView setRegion:region animated:NO];
        self.isSetRegion = YES;
    }
}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        GroupLocationAnnotationView *annotationView = (GroupLocationAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[GroupLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            // must set to NO, so we can show the custom callout view.
            annotationView.centerOffset = CGPointMake(0, -20.6);
        }
        int tag = [((MAPointAnnotation*)annotation).title intValue];
        
        if(tag != 1000){
            NSDictionary* dic = [self.locations objectAtIndex:tag];
            NSString* nickname = [dic objectForKey:@"nickname"];
            NSString* time = [CNUtil getTimeFromTimestamp_ymdhm:[[dic objectForKey:@"timestamp"]longLongValue]/1000];
            ((MAPointAnnotation*)annotation).subtitle = [NSString stringWithFormat:@"%@+%@",nickname,time];
            annotationView.canShowCallout = NO;
            
            NSString* imgpath = [dic objectForKey:@"imgpath"];
            if(imgpath != nil && ![imgpath isEqualToString:@""]){//有头像url
                NSString* fullurl = [NSString stringWithFormat:@"%@%@",kApp.imageurl,imgpath];
                __block UIImage* image = [kApp.avatarDic objectForKey:fullurl];
                if(image != nil){//缓存中有
                    annotationView.imageview.image = image;
                }else{//下载
                    NSURL *url = [NSURL URLWithString:fullurl];
                    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                    [request setCompletionBlock :^{
                        image = [[UIImage alloc] initWithData:[request responseData]];
                        if(image != nil){
                            if(annotationView != nil){
                                annotationView.imageview.image = image;
                            }
                            [kApp.avatarDic setObject:image forKey:fullurl];
                        }else{
                            annotationView.imageview.image = [UIImage imageNamed:@"avatar_default.png"];
                        }
                    }];
                    [request startAsynchronous ];
                }
            }else{
                annotationView.imageview.image = [UIImage imageNamed:@"avatar_default.png"];
            }
            return annotationView;
        }else{//我自己
            NSString* nickname = [kApp.userInfoDic objectForKey:@"nickname"];
            NSString* time = @"刚刚";
            ((MAPointAnnotation*)annotation).subtitle = [NSString stringWithFormat:@"%@+%@",nickname,time];
            annotationView.imageview.image = kApp.imageData == nil?[UIImage imageNamed:@"avatar_default.png"]:[UIImage imageWithData:kApp.imageData];
            return annotationView;
                                                                
        }
        
    }
    return nil;
}
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"当前位置latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        if(self.switchButton.on){
            if(self.annotation_me == nil){
                self.annotation_me = [[MAPointAnnotation alloc] init];
                self.annotation_me.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
                self.annotation_me.title = @"1000";
            }else{
                self.annotation_me.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
            }
        }
    }
}

- (void)setupBarButtonItem
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    if (_isChatGroup) {
        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [detailButton setImage:[UIImage imageNamed:@"group_detail"] forState:UIControlStateNormal];
        [detailButton addTarget:self action:@selector(showRoomContact:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
    }
    else{
        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(removeAllMessages:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isScrollToBottom) {
        [self scrollViewToBottom:YES];
    }
    else{
        _isScrollToBottom = YES;
    }
    [self setShareLocationSwitch];
    if(self.mapContainer.hidden == NO){//地图显示着就继续刷新
        [self updataMemberLocations];
        self.timer_update = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updataMemberLocations) userInfo:nil repeats:YES];
        if(!self.switchButton.on){
            [self.mapView removeAnnotation:annotation_me];
        }else{
            [self.mapView removeAnnotation:annotation_me];
            [self.mapView addAnnotation:annotation_me];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    [[EaseMob sharedInstance].deviceManager disableProximitySensor];
    [self.timer_update invalidate];
    [self.view endEditing:YES];
    self.mapView.delegate = nil;
    
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _slimeView.delegate = nil;
    _slimeView = nil;
    
    _chatToolBar.delegate = nil;
    _chatToolBar = nil;
    
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#warning 以下第一行代码必须写，将self从ChatManager的代理中移除
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[[EaseMob sharedInstance] deviceManager] removeDelegate:self];
}

- (void)back
{
    //判断当前会话是否为空，若符合则删除该会话
    EMMessage *message = [_conversation latestMessage];
    if (message == nil) {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:NO append2Chat:YES];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - helper
- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

#pragma mark - getter

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 63+43, self.view.frame.size.width, self.view.frame.size.height - 63-43-36) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:247.0/255.0 alpha:1];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = .5;
        [_tableView addGestureRecognizer:lpgr];
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
        
        ChatMoreType type = _isChatGroup == YES ? ChatMoreTypeGroupChat : ChatMoreTypeChat;
        _chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 80) typw:type];
        _chatToolBar.moreView.backgroundColor = [UIColor lightGrayColor];
        _chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _chatToolBar;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (MessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}

- (NSDate *)chatTagDate
{
    if (_chatTagDate == nil) {
        _chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
    }
    
    return _chatTagDate;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            timeCell.textLabel.text = (NSString *)obj;
            
            return timeCell;
        }
        else{
            MessageModel *model = (MessageModel *)obj;
            NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
            EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //byzc
            NSString* phoneno = model.username;
            NSDictionary* dic = [self.groupMemberDic objectForKey:phoneno];
            if(dic != nil){
                if([dic objectForKey:@"imgpath"] != nil&&![[dic objectForKey:@"imgpath"] isEqualToString:@""]){
                    model.headImageURL = [NSURL URLWithString:[dic objectForKey:@"imgpath"]];
                }else{
                    model.headImageURL = nil;
                }
            }else{
                model.headImageURL = nil;
            }
            model.nickName = [dic objectForKey:@"nickname"];
            cell.messageModel = model;
            return cell;
        }
    }
    return nil;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 40;
    }
    else{
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadMoreMessages];
    [_slimeView endRefresh];
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[MessageModel class]]) {
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
        }
    }
}

- (void)reloadData{
    _chatTagDate = nil;
    self.dataSource = [[self formatMessages:self.messages] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    }
    else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
        [self chatLocationCellBubblePressed:model];
    }
    else if([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
        messageModel.status = eMessageDeliveryState_Delivering;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];
    }else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
        [self chatVideoCellPressed:model];
    }
}

//链接被点击
- (void)chatTextCellUrlPressed:(NSURL *)url
{
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(MessageModel *)model
{
    id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    if (downloadStatus == EMAttachmentDownloading) {
        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        
        return;
    }
    
    // 播放音频
    if (model.type == eMessageBodyType_Voice) {
        __weak ChatGroupViewController *weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(MessageModel *prevAudioModel, MessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak ChatGroupViewController *weakSelf = self;
            [[[EaseMob sharedInstance] deviceManager] enableProximitySensor];
            [[EaseMob sharedInstance].chatManager asyncPlayAudio:model.chatVoice completion:^(EMError *error) {
                [weakSelf.messageReadManager stopMessageAudioModel];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    
                    weakSelf.isPlayingAudio = NO;
                    [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
                });
            } onQueue:nil];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

// 位置的bubble被点击
-(void)chatLocationCellBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)chatVideoCellPressed:(MessageModel *)model{
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.messageBody;
    if (videoBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
    {
        NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
        if (localPath && localPath.length > 0)
        {
            [self playVideoWithVideoPath:localPath];
            return;
        }
    }
    
    __weak ChatGroupViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [weakSelf showHudInView:weakSelf.view hint:NSLocalizedString(@"message.downloadingVideo", @"downloading video...")];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0) {
                [weakSelf playVideoWithVideoPath:localPath];
            }
        }else{
            [weakSelf showHint:NSLocalizedString(@"message.videoFail", @"video for failure!")];
        }
    } onQueue:nil];
}

- (void)playVideoWithVideoPath:(NSString *)videoPath
{
    _isScrollToBottom = NO;
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerController.moviePlayer prepareToPlay];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(MessageModel *)model
{
    __weak ChatGroupViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
            {
                NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
                if (localPath && localPath.length > 0) {
                    NSURL *url = [NSURL fileURLWithPath:localPath];
                    self.isScrollToBottom = NO;
                    [self.messageReadManager showBrowserWithImages:@[url]];
                    return ;
                }
            }
            [weakSelf showHudInView:weakSelf.view hint:NSLocalizedString(@"message.downloadingImage", @"downloading a image...")];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHud];
                if (!error) {
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        NSURL *url = [NSURL fileURLWithPath:localPath];
                        weakSelf.isScrollToBottom = NO;
                        [weakSelf.messageReadManager showBrowserWithImages:@[url]];
                        return ;
                    }
                }
                [weakSelf showHint:NSLocalizedString(@"message.imageFail", @"image for failure!")];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
                }
                
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
                }
            } onQueue:nil];
        }
    }
}

#pragma mark - IChatManagerDelegate

-(void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    [self reloadTableViewDataWithMessage:message];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak ChatGroupViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    EMMessage *currMsg = [weakSelf.dataSource objectAtIndex:i];
                    if ([message.messageId isEqualToString:currMsg.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            
                        });
                        
                        break;
                    }
                }
            }
        }
    });
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress{
    NSLog(@"didFetchingMessageAttachment: %f", progress);
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addMessage:message];
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self showHint:NSLocalizedString(@"receiveCmd", @"receive cmd message")];
    }
}

- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    if (error && [_conversation.chatter isEqualToString:conversationChatter]) {
        
        __weak ChatGroupViewController *weakSelf = self;
        for (int i = 0; i < self.dataSource.count; i ++) {
            id object = [self.dataSource objectAtIndex:i];
            if ([object isKindOfClass:[MessageModel class]]) {
                MessageModel *currentModel = [self.dataSource objectAtIndex:i];
                EMMessage *currMsg = [currentModel message];
                if ([messageId isEqualToString:currMsg.messageId]) {
                    currentModel.status = eMessageDeliveryState_Failure;
                    currMsg.deliveryState = eMessageDeliveryState_Failure;
                    MessageModel *cellModel = [MessageModelManager modelWithMessage:currMsg];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView beginUpdates];
                        [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf.tableView endUpdates];
                        
                    });
                    
                    break;
                }
            }
        }
    }
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self loadMoreMessages];
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    if (_isChatGroup && [group.groupId isEqualToString:_chatter]) {
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didInterruptionRecordAudio
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    
    [self stopAudioPlaying];
}

- (void)groupDidUpdateInfo:(EMGroup *)group error:(EMError *)error
{
    if (!error && _isChatGroup && [_chatter isEqualToString:group.groupId])
    {
        self.title = group.groupSubject;
    }
}

#pragma mark - EMChatBarMoreViewDelegate

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView
{
    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:NSLocalizedString(@"message.simulatorNotSupportCamera", @"simulator does not support taking picture")];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
    
    LocationViewController *locationController = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
    locationController.delegate = self;
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView{
    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:NSLocalizedString(@"message.simulatorNotSupportVideo", @"simulator does not support vidio")];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter" object:_chatter];
    
    //    __weak typeof(self) weakSelf = self;
    //    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    //    {
    //        //requestRecordPermission
    //        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
    //            NSLog(@"granted = %d",granted);
    //            if(granted)
    //            {
    //                dispatch_async(dispatch_get_main_queue(), ^{
    //                    [[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter" object:weakSelf.chatter];
    //                });
    //            }
    //        }];
    //    }
}

#pragma mark - LocationViewDelegate

-(void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address
{
    EMMessage *locationMessage = [ChatSendHelper sendLocationLatitude:latitude longitude:longitude address:address toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO ext:nil];
    [self addMessage:locationMessage];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    NSLog(@"didChangeFrameToHeight--");
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 63+43;
        rect.size.height = self.view.frame.size.height - toHeight-63-43;
        self.tableView.frame = rect;
    }];
    [self scrollViewToBottom:YES];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    if ([self canRecord]) {
        DXRecordView *tmpView = (DXRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        
        NSError *error = nil;
        [[EaseMob sharedInstance].chatManager startRecordingAudioWithError:&error];
        if (error) {
            NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
        }
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EaseMob sharedInstance].chatManager asyncCancelRecordingAudioWithCompletion:nil onQueue:nil];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    [[EaseMob sharedInstance].chatManager
     asyncStopRecordingAudioWithCompletion:^(EMChatVoice *aChatVoice, NSError *error){
         if (!error) {
             [self sendAudioMessage:aChatVoice];
         }else{
             if (error.code == EMErrorAudioRecordNotStarted) {
                 [self showHint:error.domain yOffset:-40];
             } else {
                 [self showHint:error.domain];
             }
         }
         
     } onQueue:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        EMChatVideo *chatVideo = [[EMChatVideo alloc] initWithFile:[mp4 relativePath] displayName:@"video.mp4"];
        [self sendVideoMessage:chatVideo];
        
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self sendImageMessage:orgImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    // todo by du. 复制
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
        [_conversation removeMessage:model.message];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
        if (_longPressIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
            if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:_longPressIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataSource removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    _longPressIndexPath = nil;
}

#pragma mark - private

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

- (void)stopAudioPlaying
{
    //停止音频播放及播放动画
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    MessageModel *playingModel = [self.messageReadManager stopMessageAudioModel];
    
    NSIndexPath *indexPath = nil;
    if (playingModel) {
        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    }
    
    if (indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
}

- (void)loadMoreMessages
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
        
        NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:([weakSelf.messages count] + KPageCount) before:timestamp];
        if ([messages count] > 0) {
            weakSelf.messages = [messages mutableCopy];
            
            NSInteger currentCount = [weakSelf.dataSource count];
            weakSelf.dataSource = [[weakSelf formatMessages:messages] mutableCopy];
            [weakSelf.tableView reloadData];
            
//            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
            
            //从数据库导入时重新下载没有下载成功的附件
            for (NSInteger i = currentCount; i < [weakSelf.dataSource count]; i++)
            {
                id obj = weakSelf.dataSource[i];
                if ([obj isKindOfClass:[MessageModel class]])
                {
                    [weakSelf downloadMessageAttachments:obj];
                }
            }
        }
    });
}

- (void)downloadMessageAttachments:(MessageModel *)model
{
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [self reloadTableViewDataWithMessage:model.message];
        }
        else
        {
            [self showHint:NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
        }
    };
    
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:model.message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([model.messageBody messageBodyType] == eMessageBodyType_Video)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:model.message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([model.messageBody messageBodyType] == eMessageBodyType_Voice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)model.messageBody;
        if (voiceBody.attachmentDownloadStatus != EMAttachmentDownloadSuccessed)
        {
            //下载语言
            [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        }
    }
}

- (NSArray *)formatMessages:(NSArray *)messagesArray
{
    NSMutableArray *formatArray = [[NSMutableArray alloc] init];
    if ([messagesArray count] > 0) {
        for (EMMessage *message in messagesArray) {
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                [formatArray addObject:[createDate formattedTime]];
                self.chatTagDate = createDate;
            }
            
            MessageModel *model = [MessageModelManager modelWithMessage:message];
            if (model) {
                [formatArray addObject:model];
            }
        }
    }
    
    return formatArray;
}

-(NSMutableArray *)formatMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    if (model) {
        [ret addObject:model];
    }
    return ret;
}

-(void)addMessage:(EMMessage *)message
{
    [_messages addObject:message];
    __weak ChatGroupViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < messages.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.dataSource.count+i inSection:0];
            [indexPaths addObject:indexPath];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView beginUpdates];
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            
            [weakSelf.tableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void)showRoomContact:(id)sender
{
    [self.view endEditing:YES];
    if (_isChatGroup) {
        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:_chatter];
        [self.navigationController pushViewController:detailController animated:YES];
    }
}

- (void)removeAllMessages:(id)sender
{
    if (_dataSource.count == 0) {
        [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        if (_isChatGroup && [groupId isEqualToString:_conversation.chatter]) {
            [_conversation removeAllMessages];
            [_messages removeAllObjects];
            _chatTagDate = nil;
            [_dataSource removeAllObjects];
            [_tableView reloadData];
            [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"sureToDelete", @"please make sure to delete")
                     customizationBlock:^(WCAlertView *alertView) {
                         
                     } completionBlock:
         ^(NSUInteger buttonIndex, WCAlertView *alertView) {
             if (buttonIndex == 1) {
                 [weakSelf.conversation removeAllMessages];
                 [weakSelf.messages removeAllObjects];
                 weakSelf.chatTagDate = nil;
                 [weakSelf.dataSource removeAllObjects];
                 [weakSelf.tableView reloadData];
             }
         } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
    }
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(MessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == eMessageBodyType_Text) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else{
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self didReceiveMessage:message];
    }
}

- (void)applicationDidEnterBackground
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
}

#pragma mark - send message

-(void)sendTextMessage:(NSString *)textMessage
{
    //test code
    //    for (int i = 0; i < 500; i++) {
    //        NSString *sender = [NSString stringWithFormat:@"sender%i", i];
    //        for (int j = 0; j < 10; j++) {
    //            NSString *str = [NSString stringWithFormat:@"text%i_%i", i, j];
    //            EMChatText *text = [[EMChatText alloc] initWithText:str];
    //            EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    //            EMMessage *retureMsg = [[EMMessage alloc] initWithReceiver:@"899" sender:sender bodies:[NSArray arrayWithObject:body]];
    //            retureMsg.requireEncryption = NO;
    //            retureMsg.isGroup = NO;
    //            [[EaseMob sharedInstance].chatManager asyncSendMessage:retureMsg progress:nil];
    //        }
    //    }
    
    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage
                                                            toUsername:_conversation.chatter
                                                           isChatGroup:_isChatGroup
                                                     requireEncryption:NO
                                                                   ext:nil];
    [self addMessage:tempMessage];
}

-(void)sendImageMessage:(UIImage *)imageMessage
{
    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:imageMessage
                                                            toUsername:_conversation.chatter
                                                           isChatGroup:_isChatGroup
                                                     requireEncryption:NO
                                                                   ext:nil];
    [self addMessage:tempMessage];
}

-(void)sendAudioMessage:(EMChatVoice *)voice
{
    EMMessage *tempMessage = [ChatSendHelper sendVoice:voice
                                            toUsername:_conversation.chatter
                                           isChatGroup:_isChatGroup
                                     requireEncryption:NO ext:nil];
    [self addMessage:tempMessage];
}

-(void)sendVideoMessage:(EMChatVideo *)video
{
    EMMessage *tempMessage = [ChatSendHelper sendVideo:video
                                            toUsername:_conversation.chatter
                                           isChatGroup:_isChatGroup
                                     requireEncryption:NO ext:nil];
    [self addMessage:tempMessage];
}

#pragma mark - EMDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if (isCloseToUser)//黑屏
    {
        // 使用耳机播放
        [[EaseMob sharedInstance].deviceManager switchAudioOutputDevice:eAudioOutputDevice_earphone];
    } else {
        // 使用扬声器播放
        [[EaseMob sharedInstance].deviceManager switchAudioOutputDevice:eAudioOutputDevice_speaker];
        if (!_isPlayingAudio) {
            [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
        }
    }
}

@end

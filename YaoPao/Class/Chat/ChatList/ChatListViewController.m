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

#import "ChatListViewController.h"
#import "SRRefreshView.h"
#import "ChatListCell.h"
#import "EMSearchBar.h"
#import "NSDate+Category.h"
#import "RealtimeSearchUtil.h"
#import "ChatViewController.h"
#import "EMSearchDisplayController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "ChatDemoUIDefine.h"
#import "UIViewController+HUD.h"
#import "CNADBookViewController.h"
#import "CreateGroupViewController.h"
#import "ChatGroupViewController.h"
#import "CNLoginPhoneViewController.h"
#import "Toast+UIView.h"
#import "FriendInfo.h"

@interface ChatListViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate,SRRefreshDelegate, UISearchBarDelegate, IChatManagerDelegate>

@property (strong, nonatomic) NSMutableArray        *dataSource;

@property (strong, nonatomic) UITableView           *tableView;
@property (nonatomic, strong) EMSearchBar           *searchBar;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (nonatomic, strong) UIView                *networkStateView;
@property (nonatomic, strong) UIView                *view_pop;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation ChatListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    self.selectIndex = 2;
    [super viewDidLoad];
    if(kApp.isLogin == 0){
        [kApp.window makeToast:@"请先登录"];
        CNLoginPhoneViewController* loginVC = [[CNLoginPhoneViewController alloc]init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    self.view_pop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
    self.view_pop.backgroundColor = [UIColor clearColor];
    UIView* view_content = [[UIView alloc]initWithFrame:CGRectMake(218, 55, 102, 51)];
    view_content.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:166.0/255.0 blue:1 alpha:1];
    UIImageView* imageview_chat = [[UIImageView alloc]initWithFrame:CGRectMake(8, 6, 16, 14)];
    imageview_chat.image = [UIImage imageNamed:@"create_chat.png"];
    UILabel* label_chat = [[UILabel alloc]initWithFrame:CGRectMake(32, 6, 60, 14)];
    label_chat.text = @"发起聊天";
    label_chat.textColor = [UIColor whiteColor];
    [label_chat setFont:[UIFont systemFontOfSize:14]];
    label_chat.textAlignment = NSTextAlignmentCenter;
    UIView* view_line = [[UIView alloc]initWithFrame:CGRectMake(0, 26, 102, 1)];
    view_line.backgroundColor = [UIColor colorWithRed:121.0/255.0 green:194.0/255.0 blue:1 alpha:1];
    UIImageView* imageview_group = [[UIImageView alloc]initWithFrame:CGRectMake(8, 32, 16, 14)];
    imageview_group.image = [UIImage imageNamed:@"create_group.png"];
    UILabel* label_group = [[UILabel alloc]initWithFrame:CGRectMake(32, 32, 60, 14)];
    label_group.text = @"创建跑团";
    label_group.textColor = [UIColor whiteColor];
    [label_group setFont:[UIFont systemFontOfSize:14]];
    label_group.textAlignment = NSTextAlignmentCenter;
    
    UIButton * button_startChat = [UIButton buttonWithType:UIButtonTypeCustom];
    button_startChat.frame = CGRectMake(0, 0, 102, 25);
    button_startChat.tag = 2;
    [button_startChat addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * button_createGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    button_createGroup.frame = CGRectMake(0, 26, 102, 25);
    button_createGroup.tag = 3;
    [button_createGroup addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [view_content addSubview:imageview_chat];
    [view_content addSubview:label_chat];
    [view_content addSubview:view_line];
    [view_content addSubview:imageview_group];
    [view_content addSubview:label_group];
    [view_content addSubview:button_startChat];
    [view_content addSubview:button_createGroup];
    
    [self.view_pop addSubview:view_content];
    
    UIView* topbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 55)];
    topbar.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:166.0/255.0 blue:1 alpha:1];
    [self.view addSubview:topbar];
    UILabel* label_title = [[UILabel alloc]initWithFrame:CGRectMake(87, 20, 146, 35)];
    [label_title setTextAlignment:NSTextAlignmentCenter];
    label_title.text = @"会话";
    label_title.font = [UIFont systemFontOfSize:16];
    label_title.textColor = [UIColor whiteColor];
    [topbar addSubview:label_title];
    
    UIButton * button_contact = [UIButton buttonWithType:UIButtonTypeCustom];
    button_contact.frame = CGRectMake(254, 30, 20, 14);
    [button_contact setBackgroundImage:[UIImage imageNamed:@"chat_home_contact.png"] forState:UIControlStateNormal];
    button_contact.tag = 0;
    [button_contact addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topbar addSubview:button_contact];
    
    UIButton * button_add = [UIButton buttonWithType:UIButtonTypeCustom];
    button_add.frame = CGRectMake(293, 30, 14, 14);
    [button_add setBackgroundImage:[UIImage imageNamed:@"chat_home_add.png"] forState:UIControlStateNormal];
    button_add.tag = 1;
    [button_add addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topbar addSubview:button_add];
    
    
    [self removeEmptyConversationsFromDB];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self networkStateView];
    [self searchController];
    //添加弹出框
    [self.view addSubview:self.view_pop];
    self.view_pop.hidden = YES;
    UITapGestureRecognizer* tapRecognizer_switch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidePopView:)];
    [self.view_pop addGestureRecognizer:tapRecognizer_switch];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.view_pop.hidden = YES;
    [self unregisterNotifications];
}
- (void)hidePopView:(id)sender
{
    self.view_pop.hidden = YES;
}
- (void)requestFriendsDidSuccess{
    __weak ChatListViewController *weakSelf = self;
    [weakSelf hideHud];
    self.view.userInteractionEnabled = YES;
    NSLog(@"请求成功");
    [self.tableView reloadData];
}
- (void)requestFriendsDidFailed{
    __weak ChatListViewController *weakSelf = self;
    [weakSelf hideHud];
    self.view.userInteractionEnabled = YES;
}
- (void)buttonClicked:(id)sender{
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"通讯录");
            CNADBookViewController* adbookVC = [[CNADBookViewController alloc]init];
            [self.navigationController pushViewController:adbookVC animated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"发起");
            self.view_pop.hidden = NO;
            break;
        }
        case 2:
        {
            NSLog(@"发起对话");
            CNADBookViewController* adbookVC = [[CNADBookViewController alloc]init];
            [self.navigationController pushViewController:adbookVC animated:YES];
            break;
        }
        case 3:
        {
            NSLog(@"创建组");
            CreateGroupViewController *createChatroom = [[CreateGroupViewController alloc] init];
            [self.navigationController pushViewController:createChatroom animated:YES];
            break;
        }
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDataSource];
    [self registerNotifications];
    
    //获取好友信息
    if(kApp.friendHandler.friendList1NeedRefresh){
        kApp.friendHandler.delegete_requestFriends = self;
        [kApp.friendHandler dorequest];
        [self showHudInView:self.view hint:@"加载好友信息..."];
        self.view.userInteractionEnabled = NO;
        NSLog(@"开始请求");
    }
}

- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

#pragma mark - getter

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 55, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55+self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height-55-42) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"chatListCell"];
    }
    
    return _tableView;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak ChatListViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"ChatListCell";
            ChatListCell *cell = (ChatListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            cell.name = conversation.chatter;
            if (!conversation.isGroup) {
                cell.placeholderImage = [UIImage imageNamed:@"chatListCellHead.png"];
            }
            else{
                NSString *imageName = @"groupPublicHeader";
                NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:conversation.chatter]) {
                        cell.name = group.groupSubject;
                        imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
                        break;
                    }
                }
                cell.placeholderImage = [UIImage imageNamed:imageName];
            }
            cell.detailMsg = [weakSelf subTitleMessageByConversation:conversation];
            cell.time = [weakSelf lastMessageTimeByConversation:conversation];
            cell.unreadCount = [weakSelf unreadMessageCountByConversation:conversation];
            if (indexPath.row % 2 == 1) {
                cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
            }else{
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            
            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:conversation.chatter isGroup:conversation.isGroup];
            chatVC.title = conversation.chatter;
            [weakSelf.navigationController pushViewController:chatVC animated:YES];
        }];
    }
    
    return _searchController;
}

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

#pragma mark - private

- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];

    NSArray* sorte = [conversations sortedArrayUsingComparator:
           ^(EMConversation *obj1, EMConversation* obj2){
               EMMessage *message1 = [obj1 latestMessage];
               EMMessage *message2 = [obj2 latestMessage];
               if(message1.timestamp > message2.timestamp) {
                   return(NSComparisonResult)NSOrderedAscending;
               }else {
                   return(NSComparisonResult)NSOrderedDescending;
               }
           }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                ret = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                ret = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                ret = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                ret = NSLocalizedString(@"message.vidio1", @"[vidio]");
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}

#pragma mark - TableViewDelegate & TableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"chatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    FriendInfo* friend = [kApp.friendHandler.friendsDicByPhone objectForKey:conversation.chatter];
    cell.name = friend.nameInYaoPao;
//    cell.name = @"dkkd";
    NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
    for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:conversation.chatter]) {
            cell.name = group.groupSubject;
            break;
        }
    }
    
    if (!conversation.isGroup) {
        FriendInfo* friend = [kApp.friendHandler.friendsDicByPhone objectForKey:conversation.chatter];
        if(friend != nil){
            if(friend.avatarUrlInYaoPao != nil && ![friend.avatarUrlInYaoPao isEqualToString:@""]){//有头像url
                NSString* fullurl = [NSString stringWithFormat:@"%@%@",kApp.imageurl,friend.avatarUrlInYaoPao];
                __block UIImage* image = [kApp.avatarDic objectForKey:fullurl];
                if(image != nil){//缓存中有
                    cell.placeholderImage = image;
                }else{//下载
                    NSURL *url = [NSURL URLWithString:fullurl];
                    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                    [request setCompletionBlock :^{
                        image = [[UIImage alloc] initWithData:[request responseData]];
                        if(image != nil){
                            cell.placeholderImage = image;
                            cell.imageView.image = image;
                            [kApp.avatarDic setObject:image forKey:fullurl];
                        }
                    }];
                    [request startAsynchronous ];
                }
            }else{
                cell.placeholderImage = [UIImage imageNamed:@"avatar_default.png"];
            }
        }else{
            cell.placeholderImage = [UIImage imageNamed:@"avatar_default.png"];
        }
    }
    else{
        cell.placeholderImage = [UIImage imageNamed:@"group_avatar_default.png"];
    }
    cell.detailMsg = [self subTitleMessageByConversation:conversation];
    cell.time = [self lastMessageTimeByConversation:conversation];
    cell.unreadCount = [self unreadMessageCountByConversation:conversation];
    if (indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    
    
    NSString *title = conversation.chatter;
    if (conversation.isGroup) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                title = group.groupSubject;
                break;
            }
        }
        ChatGroupViewController *chatController;
        NSString *chatter = conversation.chatter;
        chatController = [[ChatGroupViewController alloc] initWithChatter:chatter isGroup:conversation.isGroup];
        chatController.title = title;
        chatController.groupname = title;
        [self.navigationController pushViewController:chatController animated:YES];
    }else{
        ChatViewController *chatController;
        NSString *chatter = conversation.chatter;
        chatController = [[ChatViewController alloc] initWithChatter:chatter isGroup:conversation.isGroup];
        chatController.title = title;
        [self.navigationController pushViewController:chatController animated:YES];
    }
    
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(chatter) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self refreshDataSource];
    [_slimeView endRefresh];
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - public

-(void)refreshDataSource
{
    self.dataSource = [self loadDataSource];
    [_tableView reloadData];
    [self hideHud];
}

- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }

}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
    [self refreshDataSource];
}

@end

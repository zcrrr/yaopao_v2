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

#import "CreateGroupViewController.h"

#import "ContactSelectionViewController.h"
#import "EMTextView.h"
#import "EMSDKFull.h"
#import "UIViewController+HUD.h"
#import "CNNetworkHandler.h"
#import "ChatGroupViewController.h"

@interface CreateGroupViewController ()<UITextFieldDelegate, UITextViewDelegate, EMChooseViewDelegate>

@property (strong, nonatomic) UIView *switchView;
@property (strong, nonatomic) UIBarButtonItem *rightItem;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) EMTextView *textView;

@property (nonatomic) BOOL isPublic;
@property (strong, nonatomic) UILabel *groupTypeLabel;//群组类型

@property (nonatomic) BOOL isMemberOn;
@property (strong, nonatomic) UILabel *groupMemberTitleLabel;
@property (strong, nonatomic) UISwitch *groupMemberSwitch;
@property (strong, nonatomic) UILabel *groupMemberLabel;
@property (strong, nonatomic) NSString* groupId;

@end

@implementation CreateGroupViewController
@synthesize groupId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isPublic = NO;
        _isMemberOn = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    [self.view setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:247.0/255.0 alpha:1]];
    UIView* topbar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 55)];
    topbar.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:166.0/255.0 blue:1 alpha:1];
    [self.view addSubview:topbar];
    UILabel* label_title = [[UILabel alloc]initWithFrame:CGRectMake(87, 20, 146, 35)];
    [label_title setTextAlignment:NSTextAlignmentCenter];
    label_title.text = NSLocalizedString(@"title.createGroup", @"Create a group");
    label_title.font = [UIFont systemFontOfSize:16];
    label_title.textColor = [UIColor whiteColor];
    [topbar addSubview:label_title];
    UIButton * button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    button_back.frame = CGRectMake(6, 23, 21, 29);
    [button_back setBackgroundImage:[UIImage imageNamed:@"back_v2.png"] forState:UIControlStateNormal];
    button_back.tag = 0;
    [button_back addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topbar addSubview:button_back];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 266, 293, 43)];
    addButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [addButton setTitle:@"添加好友" forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"button_green.png"] forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addContacts:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    UIView* view_groupname = [[UIView alloc]initWithFrame:CGRectMake(0, 55+9, 320, 43)];
    view_groupname.backgroundColor = [UIColor whiteColor];
    UILabel* label_groupname = [[UILabel alloc]initWithFrame:CGRectMake(13, 0, 28, 43)];
    label_groupname.text = @"名称";
    label_groupname.textColor = [UIColor blackColor];
    label_groupname.font = [UIFont systemFontOfSize:14];
    label_groupname.textAlignment = NSTextAlignmentLeft;
    [view_groupname addSubview:label_groupname];
    [view_groupname addSubview:self.textField];
    [self.view addSubview:view_groupname];
    
    
    UIView* view_groupdesc = [[UIView alloc]initWithFrame:CGRectMake(0, 110, 320, 143)];
    view_groupdesc.backgroundColor = [UIColor whiteColor];
    UILabel* label_groupdesc = [[UILabel alloc]initWithFrame:CGRectMake(13, 0, 28, 43)];
    label_groupdesc.text = @"简介";
    label_groupdesc.textColor = [UIColor blackColor];
    label_groupdesc.font = [UIFont systemFontOfSize:14];
    label_groupdesc.textAlignment = NSTextAlignmentLeft;
    [view_groupdesc addSubview:label_groupdesc];
    [view_groupdesc addSubview:self.textView];
    [self.view addSubview:view_groupdesc];
    
    
    
//    [self.view addSubview:self.switchView];
}
- (void)buttonClicked:(id)sender{
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"返回");
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter
- (UITextField *)textField
{
    if (_textField == nil) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(51, 0, 320-51-21, 43)];
//        _textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        _textField.layer.borderWidth = 0.5;
//        _textField.layer.cornerRadius = 3;
//        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.font = [UIFont systemFontOfSize:14.0];
        _textField.textColor = [UIColor blackColor];
        _textField.placeholder = NSLocalizedString(@"group.create.inputName", @"please enter the group name");
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
    }
    
    return _textField;
}

- (EMTextView *)textView
{
    if (_textView == nil) {
        _textView = [[EMTextView alloc] initWithFrame:CGRectMake(47, 5, 320-51-21, 130)];
//        _textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        _textView.layer.borderWidth = 0.5;
//        _textView.layer.cornerRadius = 3;
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.textColor = [UIColor blackColor];
        _textView.placeholder = NSLocalizedString(@"group.create.inputDescribe", @"please enter a group description");
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.delegate = self;
    }
    return _textView;
}

- (UIView *)switchView
{
    if (_switchView == nil) {
        _switchView = [[UIView alloc] initWithFrame:CGRectMake(10, 160, 300, 90)];
        _switchView.backgroundColor = [UIColor clearColor];
        
        CGFloat oY = 0;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, oY, 100, 35)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = NSLocalizedString(@"group.create.groupPermission", @"group permission");
        [_switchView addSubview:label];
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(100, oY, 50, _switchView.frame.size.height)];
        [switchControl addTarget:self action:@selector(groupTypeChange:) forControlEvents:UIControlEventValueChanged];
        [_switchView addSubview:switchControl];
        
        _groupTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(switchControl.frame.origin.x + switchControl.frame.size.width + 5, oY, 100, 35)];
        _groupTypeLabel.backgroundColor = [UIColor clearColor];
        _groupTypeLabel.font = [UIFont systemFontOfSize:12.0];
        _groupTypeLabel.textColor = [UIColor grayColor];
        _groupTypeLabel.text = NSLocalizedString(@"group.create.private", @"private group");
        [_switchView addSubview:_groupTypeLabel];
        
        oY += (35 + 20);
        _groupMemberTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, oY, 100, 35)];
        _groupMemberTitleLabel.font = [UIFont systemFontOfSize:14.0];
        _groupMemberTitleLabel.backgroundColor = [UIColor clearColor];
        _groupMemberTitleLabel.text = NSLocalizedString(@"group.create.occupantPermissions", @"members invite permissions");
        [_switchView addSubview:_groupMemberTitleLabel];
        
        _groupMemberSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, oY, 50, 35)];
        [_groupMemberSwitch addTarget:self action:@selector(groupMemberChange:) forControlEvents:UIControlEventValueChanged];
        [_switchView addSubview:_groupMemberSwitch];
        
        _groupMemberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_groupMemberSwitch.frame.origin.x + _groupMemberSwitch.frame.size.width + 5, oY, 150, 35)];
        _groupMemberLabel.backgroundColor = [UIColor clearColor];
        _groupMemberLabel.font = [UIFont systemFontOfSize:12.0];
        _groupMemberLabel.textColor = [UIColor grayColor];
        _groupMemberLabel.text = NSLocalizedString(@"group.create.unallowedOccupantInvite", @"don't allow group members to invite others");
        [_switchView addSubview:_groupMemberLabel];
    }
    
    return _switchView;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - EMChooseViewDelegate

- (void)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources
{
    NSLog(@"didFinishSelectedSources");
    [self showHudInView:self.view hint:NSLocalizedString(@"group.create.ongoing", @"create a group...")];
    NSMutableString* invitePersons = [NSMutableString stringWithString:@""];
    NSMutableArray *source = [NSMutableArray array];
    for (EMBuddy *buddy in selectedSources) {
        [source addObject:buddy.username];
        [invitePersons appendString:buddy.username];
        [invitePersons appendString:@","];
    }
    if([invitePersons hasSuffix:@","]){
        invitePersons = [NSMutableString stringWithString:[invitePersons substringToIndex:invitePersons.length - 1]];
    }
    
    EMGroupStyleSetting *setting = [[EMGroupStyleSetting alloc] init];
//    if (_isPublic) {
//        if(_isMemberOn)
//        {
//            setting.groupStyle = eGroupStyle_PublicOpenJoin;
//        }
//        else{
//            setting.groupStyle = eGroupStyle_PublicJoinNeedApproval;
//        }
//    }
//    else{
//        if(_isMemberOn)
//        {
//            setting.groupStyle = eGroupStyle_PrivateMemberCanInvite;
//        }
//        else{
//            setting.groupStyle = eGroupStyle_PrivateOnlyOwnerInvite;
//        }
//    }
    //默认私有群、允许成员加拉人
    setting.groupStyle = eGroupStyle_PublicJoinNeedApproval;
    setting.groupStyle = eGroupStyle_PrivateMemberCanInvite;
    setting.groupMaxUsersCount = 50;
   
    //建群成功，调用yaopao接口，建群
    NSString* groupDesc = [self.textView.text isEqualToString:@""]?@"没有添加描述":self.textView.text;
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    [params setObject:self.textField.text forKey:@"groupname"];
    [params setObject:groupDesc forKey:@"desc"];
    [params setObject:@"false" forKey:@"ispublic"];
    [params setObject:@"50" forKey:@"maxusers"];
    [params setObject:@"false" forKey:@"approval"];
    [params setObject:[kApp.userInfoDic objectForKey:@"phone"] forKey:@"owner"];
    [params setObject:invitePersons forKey:@"members"];
    kApp.networkHandler.delegate_createGroup = self;
    [kApp.networkHandler doRequest_createGroup:params];

}
- (void)createGroupDidFailed:(NSString *)mes{
    __weak CreateGroupViewController *weakSelf = self;
    [weakSelf hideHud];
}
- (void)createGroupDidSuccess:(NSDictionary *)resultDic{
    //先刷新全局群组信息：
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
        if (!error) {
            NSLog(@"获取成功 -- %@",groups);
            __weak CreateGroupViewController *weakSelf = self;
            [weakSelf hideHud];
            [weakSelf showHint:NSLocalizedString(@"group.create.success", @"create group success")];
            self.groupId = [[[resultDic objectForKey:@"grouplist"]objectAtIndex:0]objectForKey:@"id"];
            ChatGroupViewController *chatController = [[ChatGroupViewController alloc] initWithChatter:self.groupId isGroup:YES];
            chatController.groupname = self.textField.text;
            chatController.from = @"creatGroup";
            [self.navigationController pushViewController:chatController animated:YES];
        }
    } onQueue:nil];
    
    
    
}
#pragma mark - action

- (void)groupTypeChange:(UISwitch *)control
{
    _isPublic = control.isOn;
    
    [_groupMemberSwitch setOn:NO animated:NO];
    [self groupMemberChange:_groupMemberSwitch];
    
    if (control.isOn) {
        _groupTypeLabel.text = NSLocalizedString(@"group.create.public", @"public group");
    }
    else{
        _groupTypeLabel.text = NSLocalizedString(@"group.create.private", @"private group");
    }
}

- (void)groupMemberChange:(UISwitch *)control
{
    if (_isPublic) {
        _groupMemberTitleLabel.text = NSLocalizedString(@"group.create.occupantJoinPermissions", @"members join permissions");
        if(control.isOn)
        {
            _groupMemberLabel.text = NSLocalizedString(@"group.create.open", @"random join");
        }
        else{
            _groupMemberLabel.text = NSLocalizedString(@"group.create.needApply", @"you need administrator agreed to join the group");
        }
    }
    else{
        _groupMemberTitleLabel.text = NSLocalizedString(@"group.create.occupantPermissions", @"members invite permissions");
        if(control.isOn)
        {
            _groupMemberLabel.text = NSLocalizedString(@"group.create.allowedOccupantInvite", @"allows group members to invite others");
        }
        else{
            _groupMemberLabel.text = NSLocalizedString(@"group.create.unallowedOccupantInvite", @"don't allow group members to invite others");
        }
    }
    
    _isMemberOn = control.isOn;
}

- (void)addContacts:(id)sender
{
    if (self.textField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:@"请输入跑团名称" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    [self.view endEditing:YES];
    
    ContactSelectionViewController *selectionController = [[ContactSelectionViewController alloc] init];
    selectionController.delegate = self;
    [self.navigationController pushViewController:selectionController animated:YES];
}

@end

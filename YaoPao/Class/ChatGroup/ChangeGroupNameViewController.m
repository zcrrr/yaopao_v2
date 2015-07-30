//
//  ChangeGroupNameViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/5/4.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "ChangeGroupNameViewController.h"
#import "Toast+UIView.h"
#import "FriendsHandler.h"
#import "CNUtil.h"
#import "CNGroupInfo.h"
#import "UIImage+Rescale.h"
#import "AvatarManager.h"

@interface ChangeGroupNameViewController ()

@end

@implementation ChangeGroupNameViewController
@synthesize chatGroup;
@synthesize delegate_changename;
@synthesize image_avatar;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textfield.placeholder = self.chatGroup.groupName;
    self.textview.text = self.chatGroup.groupDesc;
    self.button_avatar.layer.cornerRadius = self.button_avatar.bounds.size.width/2;
    self.button_avatar.layer.masksToBounds = YES;
    if(![self.chatGroup.groupImgPath isEqualToString:@""]){
        [kApp.avatarManager setImageToButton:self.button_avatar fromUrl:self.chatGroup.groupImgPath];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            [self.view endEditing:YES];
            if([self.textfield.text isEqualToString:@""]){
                [kApp.window makeToast:@"跑团名称不能为空!"];
                return;
            }
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
            [params setObject:uid forKey:@"uid"];
            [params setObject:self.chatGroup.groupId forKey:@"groupid"];
            [params setObject:self.textview.text forKey:@"desc"];
            [params setObject:self.textfield.text forKey:@"groupname"];
            kApp.networkHandler.delegate_changeGroupName = self;
            [kApp.networkHandler doRequest_changeGroupName:params];
            [self displayLoading];
            break;
        }
        case 2:
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选取来自" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"用户相册", nil];
            [actionSheet showInView:self.view];
            break;
        }
        default:
            break;
    }
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController* pickC = [[UIImagePickerController alloc]init];
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"拍照");
            if([CNUtil checkUserPermission]){
                pickC.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickC.allowsEditing = YES;
                pickC.delegate = self;
                [self presentViewController:pickC animated:YES completion:^{
                    
                }];
            }
            break;
        }
        case 1:
        {
            NSLog(@"相册");
            pickC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickC.allowsEditing = YES;
            pickC.delegate = self;
            [self presentViewController:pickC animated:YES completion:^{
                
            }];
            break;
        }
        default:
            break;
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.image_avatar = [image rescaleImageToSize:CGSizeMake(640, 640)];
    [self.button_avatar setBackgroundImage:self.image_avatar forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)changeGroupNameDidFailed:(NSString *)mes{
    [self hideLoading];
    [CNUtil showAlert:mes];
}
- (void)changeGroupNameDidSuccess:(NSDictionary *)resultDic{
    self.chatGroup.groupName = self.textfield.text;
    self.chatGroup.groupDesc = self.textview.text;
    if(self.image_avatar != nil){
        //上传跑团头像
        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
        NSData* data_image = UIImageJPEGRepresentation(self.image_avatar, 1);
        [params setObject:@"6" forKey:@"type"];
        [params setObject:self.chatGroup.groupId forKey:@"groupid"];
        
        NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
        [params setObject:uid forKey:@"uid"];
        [params setObject:data_image forKey:@"avatar"];
        [kApp.networkHandler doRequest_updateAvatar:params];
        kApp.networkHandler.delegate_updateAvatar = self;
    }else{
        [self editGroupInfoOver];
    }
}
- (void)editGroupInfoOver{
    [self hideLoading];
    [self.delegate_changename changeNameDidSuccess:self.textfield.text];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)updateAvatarDidSuccess:(NSDictionary *)resultDic{
    NSLog(@"上传跑团头像成功");
    [self editGroupInfoOver];
    self.chatGroup.groupImgPath = [resultDic objectForKey:@"serverImagePathsSmall"];
    
}
- (void)updateAvatarDidFailed:(NSString *)mes{
    NSLog(@"上传跑团头像失败");
    [self editGroupInfoOver];
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
    self.view.userInteractionEnabled = NO;
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
    self.view.userInteractionEnabled = YES;
}
@end

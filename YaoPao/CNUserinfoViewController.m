//
//  CNUserinfoViewController.m
//  YaoPao
//
//  Created by zc on 14-7-24.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNUserinfoViewController.h"
#import "CNNetworkHandler.h"
#import "UIImage+Rescale.h"
#import "ASIHTTPRequest.h"
#import "ColorValue.h"
#import "CNCustomButton.h"

@interface CNUserinfoViewController ()

@end

@implementation CNUserinfoViewController
@synthesize selectedSex;
@synthesize from;
@synthesize height_array;
@synthesize weight_array1;
@synthesize weight_array2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.button_save fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    self.textfield_username.delegate = self;
    self.textfield_realname.delegate = self;
    self.textfield_birthday.delegate = self;
    self.textfield_height.delegate = self;
    self.textfield_weight.delegate = self;
    self.textfield_des.delegate = self;
    self.textfield_birthday.inputView = self.datePicker;
    self.textfield_birthday.inputAccessoryView = self.accessoryView;
    //赋值：应该从plist？
    self.textfield_phone.text = [self codeAndPhone];
    NSString* username = [kApp.userInfoDic objectForKey:@"nickname"];
    self.textfield_username.text = username == nil?self.textfield_phone.text:username;
    NSString* gender = [kApp.userInfoDic objectForKey:@"gender"];
    if(gender == nil||[gender isEqualToString:@"M"]){
        [self resetSexButton:0];
    }else{
        [self resetSexButton:1];
    }
    NSString* uname = [kApp.userInfoDic objectForKey:@"uname"];
    if(uname != nil){
        self.textfield_realname.text = uname;
    }
    NSString* birthday = [kApp.userInfoDic objectForKey:@"birthday"];
    if(birthday != nil){
        self.textfield_birthday.text = birthday;
    }
    NSString* height = [kApp.userInfoDic objectForKey:@"height"];
    if(height != nil){
        self.textfield_height.text = height;
    }
    NSString* weight = [kApp.userInfoDic objectForKey:@"weight"];
    if(weight != nil){
        self.textfield_weight.text = weight;
    }
    
    self.pickerview_height.delegate = self;
    self.textfield_height.inputView = self.pickerview_height;
    self.textfield_height.inputAccessoryView = self.toolbar_height;
    self.height_array = [[NSMutableArray alloc]init];
    int i = 0;
    for(i=100;i<=240;i++){
        [self.height_array addObject:[NSString stringWithFormat:@"%i",i]];
    }
    self.textfield_height.tintColor = [UIColor whiteColor];
    
    NSString* dateString = @"1985-07-15";
    if(birthday != nil)
    {
        dateString = birthday;
    }
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate* seletedDate = [df dateFromString:dateString];
    self.datePicker.date = seletedDate;
    
    NSString* tempheight = @"170cm";
    if(height != nil){
        tempheight = height;
    }
    int index_height = [self.height_array indexOfObject:[height stringByReplacingOccurrencesOfString:@"cm" withString:@""]];
    if(index_height == NSNotFound){
        index_height = 0;
    }
    [self.pickerview_height selectRow:index_height inComponent:0 animated:YES];
    self.pickerview_weight.delegate = self;
    self.textfield_weight.inputView = self.pickerview_weight;
    self.textfield_weight.inputAccessoryView = self.toolbar_weight;
    self.weight_array1 = [[NSMutableArray alloc]init];
    for(i=15;i<=200;i++){
        [self.weight_array1 addObject:[NSString stringWithFormat:@"%i",i]];
    }
    self.weight_array2 = [[NSMutableArray alloc]init];
    for(i=0;i<=9;i++){
        [self.weight_array2 addObject:[NSString stringWithFormat:@"%i",i]];
    }
    self.textfield_weight.tintColor = [UIColor whiteColor];
    NSString* tempweight = @"70.0kg";
    if(weight != nil){
        tempweight = weight;
    }
    NSArray* temp = [[tempweight stringByReplacingOccurrencesOfString:@"kg" withString:@""] componentsSeparatedByString:@"."];
    int index_weight1 = [self.weight_array1 indexOfObject:[temp objectAtIndex:0]];
    index_weight1 = (index_weight1 == NSNotFound)?0:index_weight1;
    [self.pickerview_weight selectRow:index_weight1 inComponent:0 animated:YES];
    if([temp count]>1){
        int index_weight2 = [self.weight_array2 indexOfObject:[temp objectAtIndex:1]];
        index_weight2 = (index_weight2 == NSNotFound)?0:index_weight2;
        [self.pickerview_weight selectRow:index_weight2 inComponent:2 animated:YES];
    }
    
    NSString* signature = [kApp.userInfoDic objectForKey:@"signature"];
    if(signature != nil){
        self.textfield_des.text = signature;
    }
    NSString* imgpath = [kApp.userInfoDic objectForKey:@"imgpath"];
    if(imgpath != nil){
        //显示头像
        NSData* imageData = kApp.imageData;
        if(imageData){
            [self.button_avatar setBackgroundImage:[[UIImage alloc] initWithData:imageData] forState:UIControlStateNormal];
        }else{
            NSString *avatar = imgpath;
            NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,avatar];
            NSLog(@"avatar is %@",imageURL);
            NSURL *url = [NSURL URLWithString:imageURL];
            ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
            Imagerequest.tag = 1;
            Imagerequest.timeOutSeconds = 15;
            [Imagerequest setDelegate:self];
            [Imagerequest startAsynchronous];
        }
    }
}
#pragma -mark ASIHttpRequest delegate
- (void)requestFinished:(ASIHTTPRequest *)request{
    UIImage *image = [[UIImage alloc] initWithData:[request responseData]];
    if(image){
        [self.button_avatar setBackgroundImage:image forState:UIControlStateNormal];
        kApp.imageData = [request responseData];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_save_clicked:(id)sender {
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [kApp.userInfoDic objectForKey:@"uid"];
    NSString* utype = [kApp.userInfoDic objectForKey:@"utype"];
    
    [params setObject:uid forKey:@"uid"];
    [params setObject:utype forKey:@"utype"];
    [params setObject:self.selectedSex forKey:@"gender"];
    if (self.textfield_username.text != nil && ![self.textfield_username.text isEqualToString:@""]){
        [params setObject:self.textfield_username.text forKey:@"nickname"];
    }else{
        [self showAlert:@"用户昵称不能为空"];
        return;
    }
    if (self.textfield_realname.text != nil && ![self.textfield_realname.text isEqualToString:@""]){
        [params setObject:self.textfield_realname.text forKey:@"uname"];
    }
    if (self.textfield_birthday.text != nil && ![self.textfield_birthday.text isEqualToString:@""]){
        [params setObject:self.textfield_birthday.text forKey:@"birthday"];
    }
    if (self.textfield_height.text != nil && ![self.textfield_height.text isEqualToString:@""]){
        [params setObject:self.textfield_height.text forKey:@"height"];
    }
    if (self.textfield_weight.text != nil && ![self.textfield_weight.text isEqualToString:@""]){
        [params setObject:self.textfield_weight.text forKey:@"weight"];
    }
    if (self.textfield_des.text != nil && ![self.textfield_des.text isEqualToString:@""]){
        [params setObject:self.textfield_des.text forKey:@"signature"];
    }
    kApp.networkHandler.delegate_updateUserinfo = self;
    [kApp.networkHandler doRequest_updateUserinfo:params];
    [self displayLoading];
}

- (IBAction)button_back_clicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)button_sex_clicked:(id)sender {
    [self resetSexButton:[sender tag]];
}


- (IBAction)dataChanged:(id)sender {
    NSDate* date = self.datePicker.date;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString* string_date = [df stringFromDate:date];
    self.textfield_birthday.text = string_date;
}

- (IBAction)doneEditing:(id)sender {
    NSDate* date = self.datePicker.date;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString* string_date = [df stringFromDate:date];
    self.textfield_birthday.text = string_date;
    [self.textfield_birthday resignFirstResponder];
    [self resetViewFrame];
}

- (IBAction)button_avatar_clicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选取来自" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"用户相册", nil];
    [actionSheet showInView:self.view];
}
#pragma mark- textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self resetViewFrame];
    return YES;
}
- (void)keyboardWillShow:(NSNotification *)noti
{
    //键盘输入的界面调整
    //键盘的高度
    float height = 216.0;
    CGRect frame = self.view.frame;
    frame.size = CGSizeMake(frame.size.width, frame.size.height - height);
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.30];
    [UIView setAnimationDelegate:self];
    [self.view setFrame:frame];
    [UIView commitAnimations];
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self enabelSaveButton];
    CGPoint point = [textField.superview convertPoint:textField.frame.origin toView:nil];
    int offset = point.y + 80 - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}
- (void)resetViewFrame{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
}
- (void)enabelSaveButton{
    
}
- (void)resetSexButton:(int)tag{
    switch (tag) {
        case 0:
        {
            [self.button_man setBackgroundImage:[UIImage imageNamed:@"sex_check.png"] forState:UIControlStateNormal];
            [self.button_women setBackgroundImage:[UIImage imageNamed:@"sex_uncheck.png"] forState:UIControlStateNormal];
            self.selectedSex = @"M";
            break;
        }
        case 1:
        {
            [self.button_man setBackgroundImage:[UIImage imageNamed:@"sex_uncheck.png"] forState:UIControlStateNormal];
            [self.button_women setBackgroundImage:[UIImage imageNamed:@"sex_check.png"] forState:UIControlStateNormal];
            self.selectedSex = @"F";
            break;
        }
        default:
            break;
    }
}
#pragma mark- userinfo delegate
- (void)updateUserinfoDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)updateUserinfoDidFailed:(NSString *)mes{
    [self hideLoading];
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController* pickC = [[UIImagePickerController alloc]init];
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"拍照");
            pickC.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickC.allowsEditing = YES;
            pickC.delegate = self;
            [self presentViewController:pickC animated:YES completion:^{
                
            }];
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
    UIImage* image_compressed = [image rescaleImageToSize:CGSizeMake(640, 640)];
    [self.button_avatar setBackgroundImage:image_compressed forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //新头像同步到服务器
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSData* data_image = UIImageJPEGRepresentation(image_compressed, 1);
    //本地保存一下
    kApp.imageData = data_image;
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"test.png"]];   // 保存文件的名称
//    BOOL result = [UIImagePNGRepresentation(image_compressed)writeToFile: filePath atomically:YES];
    
    
    [params setObject:@"1" forKey:@"type"];
    NSString* uid = [kApp.userInfoDic objectForKey:@"uid"];
    [params setObject:uid forKey:@"uid"];
    [params setObject:data_image forKey:@"avatar"];
    [kApp.networkHandler doRequest_updateAvatar:params];
    kApp.networkHandler.delegate_updateAvatar = self;
    [self displayLoading];
}
- (void)updateAvatarDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
}
- (void)updateAvatarDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)showAlert:(NSString*) content{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark--委托协议方法
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    int tag = [pickerView tag];
    if(tag == 0){
        if(component == 0){
            return [NSString stringWithFormat:@"%@",[height_array objectAtIndex:row]];
        }else{
            return @"cm";
        }
        
    }else{
        switch (component) {
            case 0:
                return [NSString stringWithFormat:@"%@",[weight_array1 objectAtIndex:row]];
                break;
            case 1:
                return @".";
                break;
            case 2:
                return [NSString stringWithFormat:@"%@",[weight_array2 objectAtIndex:row]];
                break;
            case 3:
                return @"kg";
                break;
            default:
                return 0;
        }
    }
}


#pragma mark--数据源协议方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    int tag = [pickerView tag];
    if(tag == 0){
        return 2;
    }else{
        return 4;
    }
}
- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    int tag = [pickerView tag];
    if(tag == 1){
        if(component == 1){
            return 20;
        }else{
            return 50;
        }
        
    }else{
        return 50;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    int tag = [pickerView tag];
    if(tag == 0){
        if(component == 0){
            return [self.height_array count];
        }else{
            return 1;
        }
    }else{
        if(component == 0){
            return [self.weight_array1 count];
        }else if(component == 1){
            return 1;
        }else if(component == 2){
            return [self.weight_array2 count];;
        }else{
            return 1;
        }
        
    }
}
- (IBAction)button_weight_ok:(id)sender {
    NSInteger row1 = [self.pickerview_weight selectedRowInComponent:0];
    NSInteger row2 = [self.pickerview_weight selectedRowInComponent:2];
    self.textfield_weight.text = [NSString stringWithFormat:@"%@.%@kg",[self.weight_array1 objectAtIndex:row1],[self.weight_array2 objectAtIndex:row2]];
    [self.textfield_weight resignFirstResponder];
    [self resetViewFrame];
}

- (IBAction)button_height_ok:(id)sender {
    NSInteger row = [self.pickerview_height selectedRowInComponent:0];
    self.textfield_height.text = [NSString stringWithFormat:@"%@cm",[self.height_array objectAtIndex:row]];
    [self.textfield_height resignFirstResponder];
    [self resetViewFrame];
}

- (IBAction)button_edit_nickname:(id)sender {
    [self.textfield_username becomeFirstResponder];
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
}
- (NSString*)codeAndPhone{
    NSString* country = [kApp.userInfoDic objectForKey:@"country"];
    if(country == nil || [country isEqualToString:@""] || [country isEqualToString:@"中国"]){
        return [NSString stringWithFormat:@"+86 %@",[kApp.userInfoDic objectForKey:@"phone"]];
    }else{
        NSString *path_cn = [[NSBundle mainBundle] pathForResource:@"country"
                                                            ofType:@"plist"];
        NSDictionary *dic_cn = [[NSDictionary alloc]
                                initWithContentsOfFile:path_cn];
        NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]init];
        for (NSString *key in dic_cn) {
            NSArray* array = [dic_cn objectForKey:key];
            for(int i=0;i<[array count];i++){
                NSString* info = [array objectAtIndex:i];
                NSArray* tempArray = [info componentsSeparatedByString:@"+"];
                [dic2 setObject:[tempArray objectAtIndex:1] forKey:[tempArray objectAtIndex:0]];
            }
        }
        return [NSString stringWithFormat:@"+%@ %@",[dic2 objectForKey:country],[kApp.userInfoDic objectForKey:@"phone"]];
    }
}
@end

//
//  ScanQRCodeViewController.m
//  QRCodeDemo
//
//  Created by Kelven on 15/6/25.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Toast+UIView.h"
#import "CNNetworkHandler.h"
#import "FriendInfo.h"
#import "FriendDetailViewController.h"
#import "FriendDetailNotFriendNotContactViewController.h"
#import "FriendDetailWantMeViewController.h"
#import "FriendDetailNotFriendViewController.h"
#import "FriendFromQRCodeViewController.h"

#define URL @"http://182.92.97.144:8888/chSports"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ScanRectImageView;
@property (weak, nonatomic) IBOutlet UIImageView *grayBGImageView;

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (assign, nonatomic) NSUInteger scanLineNum;   //控制上下移动的线
@property (assign, nonatomic) BOOL isUp;
@property (strong, nonatomic) NSTimer *timer;
@property (strong,nonatomic)AVCaptureDevice *device;
@property (strong,nonatomic)AVCaptureDeviceInput *input;
@property (strong,nonatomic)AVCaptureMetadataOutput *output;
@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *preview;

- (IBAction)back:(id)sender;
@end

@implementation ScanQRCodeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.dimBackground = YES;   //模态显示
    [self.view addSubview:self.HUD];
    
   
    
    [self setupCamera];
}

- (void)hollowOutGrayView{
    
    CAShapeLayer *shape = [CAShapeLayer layer];
    
    CGRect rect = self.ScanRectImageView.frame;
    rect.origin.x = rect.origin.x+5;
    rect.origin.y = rect.origin.y-60;
    rect.size.width = rect.size.width-10;
    rect.size.height = rect.size.height-8;
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.frame];
    [path appendPath:[[UIBezierPath bezierPathWithRect:rect] bezierPathByReversingPath]];
    
    shape.path = path.CGPath;
    [self.grayBGImageView.layer setMask:shape];
}

- (void)viewDidAppear:(BOOL)animated{
    
     [self hollowOutGrayView];
}
//上下移动扫描基准线动画
-(void)animation
{
    CGRect frame = self.lineImageView.frame;
    
    if (self.isUp == NO) {
        self.scanLineNum ++;
        self.lineImageView.frame = CGRectMake(frame.origin.x, self.ScanRectImageView.frame.origin.y+2*self.scanLineNum, frame.size.width, frame.size.height);
        if (2*self.scanLineNum >= self.ScanRectImageView.frame.size.height-20) {
            self.isUp = YES;
        }
    }
    else {
        self.scanLineNum --;
        self.lineImageView.frame = CGRectMake(frame.origin.x, self.ScanRectImageView.frame.origin.y+2*self.scanLineNum, frame.size.width, frame.size.height);
        if (self.scanLineNum <= 0) {
            self.isUp = NO;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{

    self.timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}

//启动相机扫描二维码
- (void)setupCamera
{
    
    //扫描完之后删除preview图层
    [self.preview removeFromSuperlayer];

    
    // Device
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = [UIScreen mainScreen].applicationFrame;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    // Start
    [self.session startRunning];
}

- (NSInteger)getCodeType:(NSString *)code{
    
    NSString *selfUID = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    NSRange range = [code rangeOfString:selfUID];
    
    
    NSArray *arr = [code componentsSeparatedByString:@"-"];
    
    if ([[arr objectAtIndex:0] isEqualToString:@"yaopao"] && [[arr objectAtIndex:1] isEqualToString:@"addFriend"]) {
        if (range.location != NSNotFound) {
            return 1;
        }else{
            //为要跑添加好友二维码.
            return 0;
        }
        
    }
    
    
    
    
    //为其他二维码
    return 2;
}

- (void)requestQRCode:(NSString *)code{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    [params setObject:uid forKey:@"uid"];
    [params setObject:code forKey:@"someonesID"];
    kApp.networkHandler.delegate_searchFriend = self;
    [kApp.networkHandler doRequest_searchFriend:params];
    [self.HUD show:YES];
//
//    NSString *urlStr = [NSString stringWithFormat:@"%@/friend/searchfriend.htm",URL];
//   [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    NSDictionary *parameters = @{@"uid": code};
//    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            NSString *desc = [[responseObject objectForKey:@"state"] objectForKey:@"desc"];
//            //TODO:获取到服务器返回信息，跳转到添加好友页面.
//            NSLog(@"JSON: %@", desc);
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Info" message:desc delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//       
//        
//         [self.HUD hide:YES];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"Error: %@", error);
//         [self.HUD hide:YES];
//    }];
    
}
- (void)searchFriendDidFailed:(NSString *)mes{
    [self.HUD hide:YES];
}
- (void)searchFriendDidSuccess:(NSDictionary *)resultDic{
    [self.HUD hide:YES];
    NSDictionary* dic = [[resultDic objectForKey:@"frdlist"] objectAtIndex:0];
    NSString* uid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
    NSString* phone = [dic objectForKey:@"phone"];
    NSString* name = [dic objectForKey:@"nickname"];
    NSString* avatar = [dic objectForKey:@"imgpath"];
    int status = [[dic objectForKey:@"friend"]intValue];
    NSString* sex = [dic objectForKey:@"gender"];
    NSString* remark = [[dic allKeys] containsObject:@"beizhu"]?[dic objectForKey:@"beizhu"]:@"";
    FriendInfo* friend = [[FriendInfo alloc]initWithUid:uid phoneNO:phone nameInPhone:@"" nameInYaoPao:name avatarInPhone:nil avatarUrlInYaoPao:avatar status:status verifyMessage:@"" sex:sex remark:remark];
        NSLog(@"succ");
    FriendFromQRCodeViewController* ffqVC = [[FriendFromQRCodeViewController alloc]init];
    ffqVC.friend = friend;
    [self.navigationController pushViewController:ffqVC animated:YES];
}
- (void)handleCode:(NSString *)code{
    
    NSInteger codeType = [self getCodeType:code];
    
    //要跑好友二维码
    if (codeType == 0) {
        NSLog(@"好友二维码信息:%@",code);
        NSArray *arr1 = [code componentsSeparatedByString:@"-"];
        
        if (arr1.count >= 3) {
            NSArray *arr2 = [[arr1 objectAtIndex:2] componentsSeparatedByString:@":"];
            
            if (arr2.count >= 2) {
                 [self requestQRCode:[arr2 objectAtIndex:1]];
            }
        }
        
    }
    //自己的二维码
    else if (codeType == 1){
        NSLog(@"自己的二维码信息：%@",code);
        [kApp.window makeToast:@"不能添加自己为好友！"];
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    //其他二维码信息
    else{
        NSLog(@"其他二维码信息：%@",code);
        [kApp.window makeToast:@"未能识别的二维码！"];
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//扫描二维码结果回调
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0){
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [self.session stopRunning];
    [self.timer invalidate];
    
    NSLog(@"%@",stringValue);
    
    NSData *decodeData = [[NSData alloc]initWithBase64EncodedString:stringValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *decodeStr =[[NSString alloc]initWithData:decodeData encoding:NSASCIIStringEncoding];
    
    [self handleCode:decodeStr];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0){
        [self back:nil];
    }
}


- (IBAction)back:(id)sender {
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)button_clicked:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

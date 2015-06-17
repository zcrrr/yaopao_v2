//
//  CNImageEditerViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/4/23.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNImageEditerViewController.h"
#import "ColorValue.h"
#import "CNCustomButton.h"
#import "CNUtil.h"
#import "CNRunManager.h"
#import "CNOverlayViewController.h"
#import "RunClass.h"
#import "CNCloudRecord.h"
#import "CNGPSPoint.h"
#import "BinaryIOManager.h"
#import "CNShareViewController.h"
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>
#import "UIImage+Rescale.h"
#import "WaterMarkViewController.h"
#import "RunClass.h"
#import "CNChooseModelViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface CNImageEditerViewController ()

@end

@implementation CNImageEditerViewController
extern NSMutableArray* imageArray;
@synthesize oneRun;
@synthesize clientImagePathsArray;
@synthesize clientImagePathsSmallArray;
@synthesize serverImagePathsArray;
@synthesize serverImagePathsSmallArray;
@synthesize isThisRecordClouded;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backToList) name:@"updatePathsArray" object:nil];
    [self.button_back fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[CNUtil getNowTime]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M月d日"];
    NSString* strDate2 = [dateFormatter stringFromDate:date];
    NSMutableDictionary* settingDic = [CNUtil getRunSettingWhole];
    self.label_title.text = [NSString stringWithFormat:@"%@的%@",strDate2,[settingDic objectForKey:@"typeDes"]];
    self.scrollview.delegate = self;
    self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
    self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
    self.scrollview.pagingEnabled=YES;

    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    long long synTime = [[cloudDiary objectForKey:@"synTime"] longLongValue];
    long long generateTime = [oneRun.generateTime longLongValue];
    if(generateTime == 0 || synTime == 0){//肯定没同步过
        self.isThisRecordClouded = NO;
    }else if(synTime>=generateTime){//同步过了
        self.isThisRecordClouded = YES;
    }else{
        self.isThisRecordClouded = NO;
    }
    [self updatePathsArray];
    [self print4array];
}
- (void)updatePathsArray{
    if([oneRun.clientImagePaths isEqualToString:@""]){//本地路径是空，那么服务器路径必为空
        self.clientImagePathsArray = [[NSMutableArray alloc]init];
        self.clientImagePathsSmallArray = [[NSMutableArray alloc]init];
        self.serverImagePathsArray = [[NSMutableArray alloc]init];
        self.serverImagePathsSmallArray = [[NSMutableArray alloc]init];
    }else{//本地路径不是空，还需判断服务器路径是否为空
        if([oneRun.serverImagePaths isEqualToString:@""]){//本地不空，服务器空,肯定没同步
            self.clientImagePathsArray = [[NSMutableArray alloc]initWithArray:[oneRun.clientImagePaths componentsSeparatedByString:@"|"]];
            self.clientImagePathsSmallArray = [[NSMutableArray alloc]initWithArray:[oneRun.clientImagePathsSmall componentsSeparatedByString:@"|"]];
        }else{//本地不为空，服务器也不为空，则同步过
            self.clientImagePathsArray = [[NSMutableArray alloc]initWithArray:[oneRun.clientImagePaths componentsSeparatedByString:@"|"]];
            self.clientImagePathsSmallArray = [[NSMutableArray alloc]initWithArray:[oneRun.clientImagePaths componentsSeparatedByString:@"|"]];
            self.serverImagePathsArray = [[NSMutableArray alloc]initWithArray:[oneRun.serverImagePaths componentsSeparatedByString:@"|"]];
            self.serverImagePathsSmallArray = [[NSMutableArray alloc]initWithArray:[oneRun.serverImagePathsSmall componentsSeparatedByString:@"|"]];
        }
    }
}
-(void)backToList{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self whichImageShouldDisplay];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    NSLog(@"zhixing");
}
- (void)whichImageShouldDisplay{
    //先删除所有控件
    for(UIImageView* iv in self.scrollview.subviews){
        [iv removeFromSuperview];
    }
    //根据currentpage和imageArray显示
    self.scrollview.contentSize = CGSizeMake(320*[imageArray count], 320);
    for (int i = 0; i < [imageArray count] ; i++){
        UIImageView* imageview = [[UIImageView alloc]initWithFrame:CGRectMake(i*320, 0, 320, 320)];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.image = (UIImage*)[imageArray objectAtIndex:i];
        [self.scrollview addSubview:imageview];
    }
    [self.scrollview setContentOffset:CGPointMake(self.currentpage*320, 0) animated:YES];
    [self howControllerDisplay];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView==self.scrollview){
        CGPoint offset = scrollView.contentOffset;
        self.currentpage = offset.x/320; //计算当前的页码
        [self howControllerDisplay];
    }
}
- (void)howControllerDisplay{
    if([imageArray count] == 0){//如果一张照片都没拍
        self.button_left.hidden = YES;
        self.button_right.hidden = YES;
        self.imageview_page.hidden = YES;
        self.label_whichpage.hidden = YES;
        self.button_deleteImage.enabled = NO;
        self.button_water.enabled = NO;
        self.button_edit.enabled = NO;
        return;
    }
    if(self.imageview_page.hidden == YES){
        self.imageview_page.hidden = NO;
        self.label_whichpage.hidden = NO;
        self.button_deleteImage.enabled = YES;
        self.button_water.enabled = YES;
        self.button_edit.enabled = YES;
    }
    if([imageArray count] == 1){
        self.button_left.hidden = YES;
        self.button_right.hidden = YES;
    }else{
        if(self.currentpage == 0){//第一页
            self.button_left.hidden = YES;
            self.button_right.hidden = NO;
        }else if(self.currentpage == [imageArray count]-1){//最后一页
            self.button_left.hidden = NO;
            self.button_right.hidden = YES;
        }else{//中间页
            self.button_left.hidden = NO;
            self.button_right.hidden = NO;
        }
    }
    self.label_whichpage.text = [NSString stringWithFormat:@"%i/%i",self.currentpage+1,(int)[imageArray count]];
}
- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            NSLog(@"返回");
            if(self.button_save.enabled){//可以点，证明有改变
                if(kApp.cloudManager.isSynServerTime){
                    self.oneRun.updateTime = [NSNumber numberWithLongLong:([CNUtil getNowTime1000]+kApp.cloudManager.deltaMiliSecond)];
                }else{
                    self.oneRun.updateTime = [NSNumber numberWithLongLong:0];
                }
                //第三步：先保存到本地数据库
                NSError *error = nil;
                [kApp.managedObjectContext save:&error];
                NSString* NOTIFICATION_REFRESH = @"REFRESH";
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH object:nil];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"保存");
            //第一步：将本地图片，删除和保存
            //第二步：更新本地的clientImagePath值，更新时间：
            if(kApp.cloudManager.isSynServerTime){
                self.oneRun.updateTime = [NSNumber numberWithLongLong:([CNUtil getNowTime1000]+kApp.cloudManager.deltaMiliSecond)];
            }else{
                self.oneRun.updateTime = [NSNumber numberWithLongLong:0];
            }
            //第三步：先保存到本地数据库
            NSError *error = nil;
            [kApp.managedObjectContext save:&error];
            //第四步：同步接口
            [CNAppDelegate popupWarningCloud:YES];
            [self.button_save setEnabled:NO];
            break;
        }
        case 2:
        {
            NSLog(@"左");
            [self.scrollview setContentOffset:CGPointMake(self.currentpage*320-320, 0) animated:YES];
            self.currentpage -- ;
            [self howControllerDisplay];
            break;
        }
        case 3:
        {
            NSLog(@"右");
            [self.scrollview setContentOffset:CGPointMake(self.currentpage*320+320, 0) animated:YES];
            self.currentpage ++ ;
            [self howControllerDisplay];
            break;
        }
        case 4:
        {
            NSLog(@"删除图片");
            [self deleteOneImage:self.currentpage];
            [imageArray removeObjectAtIndex:self.currentpage];
            if(self.currentpage == [imageArray count]){//最后一张
                self.currentpage --;
            }
            [self whichImageShouldDisplay];
            break;
        }
        case 5:
        {
            NSLog(@"再拍一张");
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选取来自" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"用户相册", nil];
            [actionSheet showInView:self.view];
            break;
        }
        case 6:
        {
            NSLog(@"美化");
            [self displayEditorForImage:[imageArray objectAtIndex:self.currentpage]];
            break;
        }
        case 7:
        {
            NSLog(@"水印");
//            CNChooseModelViewController* cmVC = [[CNChooseModelViewController alloc]init];
//            cmVC.delegate_combineImage = self;
//            UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:cmVC];
//            cmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//            navVC.modalPresentationStyle = UIModalPresentationCustom;
//            UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
//            rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//            [rootViewController presentViewController:navVC animated:YES completion:^(void){NSLog(@"pop");}];
            WaterMarkViewController* waterVC = [[WaterMarkViewController alloc]init];
            waterVC.delegate_addWater = self;
            waterVC.image_datasource = [imageArray objectAtIndex:self.currentpage];
            [self.navigationController pushViewController:waterVC animated:YES];
            break;
        }
        default:
            break;
    }
}
#pragma -mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"拍照");
            [self takePhoto];
            break;
        }
        case 1:
        {
            NSLog(@"相册");
            self.cameraPicker = [[UIImagePickerController alloc]init];
            self.cameraPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            self.cameraPicker.mediaTypes = @[(NSString *)kUTTypeImage];
            self.cameraPicker.allowsEditing = NO;
            self.cameraPicker.delegate = self;
            [self presentViewController:self.cameraPicker animated:YES completion:^{
                
            }];
            break;
        }
        default:
            break;
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if([picker isEqual:self.cameraPicker]){
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        float width = image.size.width;
        float height = image.size.height;
        UIImage* imageScaled;
        if(width > 1080 && height > 1080){
            imageScaled = [image rescaleImageToSize:CGSizeMake(1080, 1080)];
        }else{
            imageScaled = [image rescaleImageToSize:CGSizeMake(640, 640)];
        }
        if(imageArray == nil){
            imageArray = [[NSMutableArray alloc]init];
        }
        [imageArray addObject:imageScaled];
        [self addOneNewImage:imageScaled];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)takePhoto{
    self.cameraPicker = [[UIImagePickerController alloc]init];
    self.cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraPicker.allowsEditing = NO;
    self.cameraPicker.showsCameraControls=NO;
    self.overlayVC = [[CNOverlayViewController alloc]init];
    self.cameraPicker.cameraOverlayView = self.overlayVC.view;
    [self presentViewController:self.cameraPicker animated:YES completion:^{
        self.overlayVC.cameraPicker = self.cameraPicker;
        self.overlayVC.delegate_savaImage = self;
        self.overlayVC.cameraPicker.delegate = self.overlayVC;
    }];
}
- (void)saveImageDidFailed{
    
}
- (void)saveImageDidSuccess:(UIImage *)image{
    [self addOneNewImage:image];
}
- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    float image_width = imageToEdit.size.width;
    float image_height = imageToEdit.size.height;
    NSLog(@"image_width is %f",image_width);
    NSLog(@"image_height is %f",image_height);
    [AdobeImageEditorCustomization setToolOrder:@[kAdobeImageEditorOrientation,kAdobeImageEditorColorAdjust,kAdobeImageEditorLightingAdjust,kAdobeImageEditorEffects]];//菜单
    self.editorController = [[AdobeUXImageEditorViewController alloc] initWithImage:imageToEdit];
    [self.editorController setDelegate:self];
    [self presentViewController:self.editorController animated:YES completion:nil];
}
- (void)photoEditor:(AdobeUXImageEditorViewController *)editor finishedWithImage:(UIImage *)image
{
    // Handle the result image here
    NSLog(@"done");
    float image_width = image.size.width;
    float image_height = image.size.height;
    NSLog(@"image_width is %f",image_width);
    NSLog(@"image_height is %f",image_height);
    [self editOneImage:image :self.currentpage];
    [imageArray removeObjectAtIndex:self.currentpage];
    [imageArray insertObject:image atIndex:self.currentpage];
    [self.editorController dismissViewControllerAnimated:NO completion:nil];
}
- (void)addWaterDidSuccess:(UIImage *)image{
    [self editOneImage:image :self.currentpage];
    [imageArray removeObjectAtIndex:self.currentpage];
    [imageArray addObject:image];
}
- (void)photoEditorCanceled:(AdobeUXImageEditorViewController *)editor
{
    // Handle cancellation here
    NSLog(@"cancel");
    [self.editorController dismissViewControllerAnimated:YES completion:nil];
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)addOneNewImage:(UIImage*)image{
    [self.button_save setEnabled:YES];
    //保存图片
    long long thatTime = [oneRun.rid longLongValue];
    long long nowTime = [CNUtil getNowTime1000];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[CNUtil getYearMonth:thatTime/1000]];
    NSString *filePath_big = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lli_big.jpg",nowTime]];   // 保存文件的名称
    NSString *filePath_small = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lli_small.jpg",nowTime]];
    NSLog(@"filePath_big is %@",filePath_big);
    NSLog(@"filePath_small is %@",filePath_small);
    [UIImagePNGRepresentation(image) writeToFile: filePath_big atomically:YES];
    UIImage* image_small = [image rescaleImageToSize:CGSizeMake(120, 120)];
    [UIImagePNGRepresentation(image_small) writeToFile: filePath_small atomically:YES];
    //更新本地clientImagePath
    NSString* thisImagePath = [NSString stringWithFormat:@"%@/%lli_big.jpg",[CNUtil getYearMonth:thatTime/1000],nowTime];
    NSString* thisImagePathSmall = [NSString stringWithFormat:@"%@/%lli_small.jpg",[CNUtil getYearMonth:thatTime/1000],nowTime];
    [self.clientImagePathsArray addObject:thisImagePath];
    [self.clientImagePathsSmallArray addObject:thisImagePathSmall];
    oneRun.clientImagePaths = [self arrayToString:self.clientImagePathsArray];
    oneRun.clientImagePathsSmall = [self arrayToString:self.clientImagePathsSmallArray];
    //如果已经同步，操作名单新增一行
    if(self.isThisRecordClouded){
        [self.serverImagePathsArray addObject:@"placeholder"];
        [self.serverImagePathsSmallArray addObject:@"placeholder"];
        NSString* oneAction = [NSString stringWithFormat:@"add-%@-%@",thisImagePath,oneRun.rid];
        [self addOneLineToPlist:oneAction];
        oneRun.serverImagePaths = [self arrayToString:self.serverImagePathsArray];
        oneRun.serverImagePathsSmall = [self arrayToString:self.serverImagePathsSmallArray];
    }
    [self print4array];
}
- (void)deleteOneImage:(int)index{
    [self.button_save setEnabled:YES];
    //删除本地图片:大图
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[self.clientImagePathsArray objectAtIndex:index]];
    NSLog(@"delete:%@",filePath);
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if(blHave){
        [CNPersistenceHandler DeleteSingleFile:filePath];
    }
    //删除本地图片:小图
    NSString *filePath_small = [[paths objectAtIndex:0] stringByAppendingPathComponent:[self.clientImagePathsSmallArray objectAtIndex:index]];
    BOOL blHave_samll=[[NSFileManager defaultManager] fileExistsAtPath:filePath_small];
    if(blHave_samll){
        [CNPersistenceHandler DeleteSingleFile:filePath_small];
    }
    //更新clientImagePath
    NSString* deleteLine = [self.clientImagePathsArray objectAtIndex:index];
    [self.clientImagePathsArray removeObjectAtIndex:index];
    [self.clientImagePathsSmallArray removeObjectAtIndex:index];
    self.oneRun.clientImagePaths = [self arrayToString:self.clientImagePathsArray];
    self.oneRun.clientImagePathsSmall = [self arrayToString:self.clientImagePathsSmallArray];
    //如果已经同步，更新serverImagePath,samll.操作名单新增二行（大、小各一行）
    if(self.isThisRecordClouded){
        if(![[self.serverImagePathsArray objectAtIndex:index] isEqualToString:@"placeholder"]){//server不为空，说明删除的照片，已经在服务器上了
            NSString* oneAction = [NSString stringWithFormat:@"del-%@-%@",[self.serverImagePathsArray objectAtIndex:index],oneRun.rid];
            [self addOneLineToPlist:oneAction];
            NSString* oneAction_small = [NSString stringWithFormat:@"del-%@-%@",[self.serverImagePathsSmallArray objectAtIndex:index],oneRun.rid];
            [self addOneLineToPlist:oneAction_small];
        }else{//说明删除的照片还没往服务器同步，那么删除当时添加的哪行
            NSString* oneAction = [NSString stringWithFormat:@"add-%@-%@",deleteLine,oneRun.rid];
            [self deleteOneLineToPlist:oneAction];
        }
        [self.serverImagePathsArray removeObjectAtIndex:index];
        [self.serverImagePathsSmallArray removeObjectAtIndex:index];
        oneRun.serverImagePaths = [self arrayToString:self.serverImagePathsArray];
        oneRun.serverImagePathsSmall = [self arrayToString:self.serverImagePathsSmallArray];
    }
    [self print4array];
}
- (void)editOneImage:(UIImage*)image :(int)index{
    [self.button_save setEnabled:YES];
    [self deleteOneImage:index];
    [self addOneNewImage:image];
//    //删除本地图片:大图
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[self.clientImagePathsArray objectAtIndex:index]];
//    NSLog(@"delete:%@",filePath);
//    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
//    if(blHave){
//        [CNPersistenceHandler DeleteSingleFile:filePath];
//    }
//    //删除本地图片:小图
//    NSString *filePath_small = [[paths objectAtIndex:0] stringByAppendingPathComponent:[self.clientImagePathsSmallArray objectAtIndex:index]];
//    BOOL blHave_samll=[[NSFileManager defaultManager] fileExistsAtPath:filePath_small];
//    if(blHave_samll){
//        [CNPersistenceHandler DeleteSingleFile:filePath_small];
//    }
//    //保存新图片到本地
//    long long thatTime = [oneRun.rid longLongValue];
//    long long nowTime = [CNUtil getNowTime1000];
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *path = [documentsDirectory stringByAppendingPathComponent:[CNUtil getYearMonth:thatTime/1000]];
//    NSString *filePath_big_save = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lli_big.jpg",nowTime]];   // 保存文件的名称
//    NSString *filePath_small_save = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lli_small.jpg",nowTime]];
//    NSLog(@"filePath_big is %@",filePath_big_save);
//    NSLog(@"filePath_small is %@",filePath_small_save);
//    [UIImagePNGRepresentation(image) writeToFile: filePath_big_save atomically:YES];
//    UIImage* image_small = [image rescaleImageToSize:CGSizeMake(120, 120)];
//    [UIImagePNGRepresentation(image_small) writeToFile: filePath_small_save atomically:YES];
//    NSString* thisImagePath_big = [NSString stringWithFormat:@"%@/%lli_big.jpg",[CNUtil getYearMonth:thatTime/1000],nowTime];
//    NSString* thisImagePath_small = [NSString stringWithFormat:@"%@/%lli_small.jpg",[CNUtil getYearMonth:thatTime/1000],nowTime];
//    //更新clientImagePath
//    NSString* deleteLine = [self.clientImagePathsArray objectAtIndex:index];
//    [self.clientImagePathsArray replaceObjectAtIndex:index withObject:thisImagePath_big];
//    [self.clientImagePathsSmallArray replaceObjectAtIndex:index withObject:thisImagePath_small];
//    oneRun.clientImagePaths = [self arrayToString:self.clientImagePathsArray];
//    oneRun.clientImagePathsSmall = [self arrayToString:self.clientImagePathsSmallArray];
//    //如果已经同步：先删除原来对应的serverimagepaths,操作名单新增两行
//    if(self.isThisRecordClouded){
//        NSString* oneAction = [NSString stringWithFormat:@"add-%@-%@",thisImagePath_big,oneRun.rid];
//        [self addOneLineToPlist:oneAction];
//        
//        if(![[self.serverImagePathsArray objectAtIndex:index] isEqualToString:@""]){
//            NSString* oneAction_del = [NSString stringWithFormat:@"del-%@-%@",[self.serverImagePathsArray objectAtIndex:index],oneRun.rid];
//            [self addOneLineToPlist:oneAction_del];
//            [self.serverImagePathsArray replaceObjectAtIndex:index withObject:@""];
//            oneRun.serverImagePaths = [self arrayToString:self.serverImagePathsArray];
//            
//            NSString* oneAction_small = [NSString stringWithFormat:@"del-%@-%@",[self.serverImagePathsSmallArray objectAtIndex:index],oneRun.rid];
//            [self addOneLineToPlist:oneAction_small];
//            [self.serverImagePathsSmallArray replaceObjectAtIndex:index withObject:@""];
//            oneRun.serverImagePathsSmall = [self arrayToString:self.serverImagePathsSmallArray];
//        }else{//删除名单中add的那项
//            NSString* oneAction = [NSString stringWithFormat:@"add-%@-%@",deleteLine,oneRun.rid];
//            [self deleteOneLineToPlist:oneAction];
//        }
//    }
}
- (void)deleteOneLineToPlist:(NSString*)oneLine{
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    NSMutableArray* editImageLaterArray = [cloudDiary objectForKey:@"editImageLaterArray"];
    [editImageLaterArray removeObject:oneLine];
    [cloudDiary setObject:editImageLaterArray forKey:@"editImageLaterArray"];
    [cloudDiary writeToFile:filePath_cloud atomically:YES];
}
- (void)addOneLineToPlist:(NSString*)oneLine{
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    NSMutableArray* editImageLaterArray = [cloudDiary objectForKey:@"editImageLaterArray"];
    if(editImageLaterArray == nil){
        editImageLaterArray = [[NSMutableArray alloc]init];
    }
    [editImageLaterArray addObject:oneLine];
    [cloudDiary setObject:editImageLaterArray forKey:@"editImageLaterArray"];
    [cloudDiary writeToFile:filePath_cloud atomically:YES];
}
- (NSString*)arrayToString:(NSMutableArray*)array{
    if([array count] == 0)return @"";
    NSMutableString* arrayStr = [NSMutableString stringWithString:@""];
    for(NSString* onePath in array){
        [arrayStr appendString:onePath];
        [arrayStr appendString:@"|"];
    }
    if([arrayStr hasSuffix:@"|"]){
        arrayStr = [NSMutableString stringWithString:[arrayStr substringToIndex:arrayStr.length - 1]];
    }
    return arrayStr;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)print4array{
    NSLog(@"clientImagePathsArray is %@",clientImagePathsArray);
    NSLog(@"clientImagePathsSmallArray is %@",clientImagePathsSmallArray);
    NSLog(@"serverImagePathsArray is %@",serverImagePathsArray);
    NSLog(@"serverImagePathsSmallArray is %@",serverImagePathsSmallArray);
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    NSMutableArray* editImageLaterArray = [cloudDiary objectForKey:@"editImageLaterArray"];
    NSLog(@"editImageLaterArray is %@",editImageLaterArray);
}
#pragma -mark buttonClick delegate
- (void)buttonClickDidSuccess:(NSString *)type{
    [self dismissViewControllerAnimated:NO completion:nil];
    if([type isEqualToString:@"beautify"]){
        [self displayEditorForImage:[imageArray objectAtIndex:self.currentpage]];
    }else{
        NSLog(@"拼图");
        CNChooseModelViewController* cmVC = [[CNChooseModelViewController alloc]init];
        cmVC.delegate_combineImage = self;
        UINavigationController* navVC = [[UINavigationController alloc]initWithRootViewController:cmVC];
        cmVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        navVC.modalPresentationStyle = UIModalPresentationCustom;
        UIViewController* rootViewController =  [[UIApplication sharedApplication] keyWindow].rootViewController;
        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [rootViewController presentViewController:navVC animated:YES completion:^(void){NSLog(@"pop");}];
    }
}
- (void)combineImageDidSuccess:(UIImage *)image{
    [self whichImageShouldDisplay];
    [self addOneNewImage:image];
}

@end

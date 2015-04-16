//
//  FeelingViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/18.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "FeelingViewController.h"
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

@interface FeelingViewController ()

@end

@implementation FeelingViewController
@synthesize currentpage;
@synthesize overlayVC;
@synthesize editorController;
extern NSMutableArray* imageArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    kApp.isRunning = 0;
    kApp.gpsLevel = 1;
    self.textfield.delegate = self;
    [self.button_delete fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
    [self.button_save fillColor:kClear :kClear :kWhite :kWhiteHalfAlpha];
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
    if(!iPhone5){//4、4s
        self.view_part1.frame = CGRectMake(0, 336, 320, 47);
        self.view_part2.frame = CGRectMake(0, 384, 320, 47);
        self.view_bottom.frame = CGRectMake(0, 432, 320, 40);
        
        self.imageview_nophoto.frame = CGRectMake(0, 55, 320, 238);
        self.scrollview.frame = CGRectMake(0, 55, 320, 238);
        self.button_left.frame = CGRectMake(0, 153, 22, 43);
        self.button_right.frame = CGRectMake(298, 153, 22, 43);
        self.imageview_page.frame = CGRectMake(135, 260, 51, 17);
        self.label_whichpage.frame = CGRectMake(135, 260, 51, 17);
        self.view_middle.frame = CGRectMake(0, 293, 320, 43);
    }
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
        self.button_edit.enabled = NO;
        return;
    }
    if(self.imageview_page.hidden == YES){
        self.imageview_page.hidden = NO;
        self.label_whichpage.hidden = NO;
        self.button_deleteImage.enabled = YES;
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
            NSLog(@"删除");
            imageArray = nil;
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
        case 1:
        {
            NSLog(@"保存");
            //先保存，然后跳转
            [self saveRun];
            CNShareViewController* shareVC = [[CNShareViewController alloc]init];
            shareVC.dataSource = @"this";
            [self.navigationController pushViewController:shareVC animated:YES];
            if(kApp.isLogin == 1){
                [CNAppDelegate popupWarningCloud];
            }
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
            [imageArray removeObjectAtIndex:self.currentpage];
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
            [self displayEditorForImage:[imageArray objectAtIndex:self.currentpage]];
            NSLog(@"美化");
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
            self.cameraPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
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
        self.overlayVC.cameraPicker.delegate = self.overlayVC;
    }];
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
    [self.editorController dismissViewControllerAnimated:NO completion:nil];
    WaterMarkViewController* waterVC = [[WaterMarkViewController alloc]init];
    waterVC.delegate_addWater = self;
    waterVC.image_datasource = image;
    [self.navigationController pushViewController:waterVC animated:YES];
}
- (void)addWaterDidSuccess:(UIImage *)image{
    [imageArray removeObjectAtIndex:self.currentpage];
    [imageArray insertObject:image atIndex:self.currentpage];
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
- (IBAction)button_mood_clicked:(id)sender {
    NSLog(@"mood %i",(int)[sender tag]);
    [self resetMoodButtonStatus];
    int tag = (int)[sender tag];
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"mood%i_h.png",tag]] forState:UIControlStateNormal];
    kApp.runManager.feeling = tag;
}

- (IBAction)button_way_clicked:(id)sender {
    NSLog(@"way %i",(int)[sender tag]);
    [self resetWayButtonStatus];
    int tag = (int)[sender tag];
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"way%i_h.png",tag]] forState:UIControlStateNormal];
    kApp.runManager.runway = tag;
}
- (void)resetMoodButtonStatus{
    [self.button_mood1 setBackgroundImage:[UIImage imageNamed:@"mood1.png"] forState:UIControlStateNormal];
    [self.button_mood2 setBackgroundImage:[UIImage imageNamed:@"mood2.png"] forState:UIControlStateNormal];
    [self.button_mood3 setBackgroundImage:[UIImage imageNamed:@"mood3.png"] forState:UIControlStateNormal];
    [self.button_mood4 setBackgroundImage:[UIImage imageNamed:@"mood4.png"] forState:UIControlStateNormal];
    [self.button_mood5 setBackgroundImage:[UIImage imageNamed:@"mood5.png"] forState:UIControlStateNormal];
}
- (void)resetWayButtonStatus{
    [self.button_way1 setBackgroundImage:[UIImage imageNamed:@"way1.png"] forState:UIControlStateNormal];
    [self.button_way2 setBackgroundImage:[UIImage imageNamed:@"way2.png"] forState:UIControlStateNormal];
    [self.button_way3 setBackgroundImage:[UIImage imageNamed:@"way3.png"] forState:UIControlStateNormal];
    [self.button_way4 setBackgroundImage:[UIImage imageNamed:@"way4.png"] forState:UIControlStateNormal];
    [self.button_way5 setBackgroundImage:[UIImage imageNamed:@"way5.png"] forState:UIControlStateNormal];
}
- (void)saveRun{
    long long nowTime = [CNUtil getNowTime1000];
    kApp.runManager.remark = self.textfield.text;
    //存储到数据库
    RunClass * runClass  = [NSEntityDescription insertNewObjectForEntityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    runClass.averageHeart = [NSNumber numberWithInt:0];
    runClass.dbVersion = [NSNumber numberWithInt:2];
    runClass.distance = [NSNumber numberWithFloat:kApp.runManager.distance];
    runClass.duration = [NSNumber numberWithInt:[kApp.runManager during]];
    runClass.feeling = [NSNumber numberWithInt:kApp.runManager.feeling];
    if(kApp.cloudManager.isSynServerTime){
        runClass.generateTime = [NSNumber numberWithLongLong:(nowTime+kApp.cloudManager.deltaMiliSecond)];
    }else{
        runClass.generateTime = [NSNumber numberWithLongLong:0];
    }
    runClass.gpsCount = [NSNumber numberWithLongLong:[kApp.runManager.GPSList count]];
    runClass.gpsString = @"";
    runClass.heat = [NSNumber numberWithInt:0];
    runClass.howToMove = [NSNumber numberWithInt:kApp.runManager.howToMove];
    runClass.isMatch = [NSNumber numberWithInt:0];
    runClass.jsonParam = @"";
    runClass.kmCount = [NSNumber numberWithLongLong:[kApp.runManager.dataKm count]];
    runClass.maxHeart = [NSNumber numberWithInt:0];
    runClass.mileCount = [NSNumber numberWithLongLong:[kApp.runManager.dataMile count]];
    runClass.minCount = [NSNumber numberWithLongLong:[kApp.runManager.dataMin count]];
    runClass.remark = kApp.runManager.remark;
    runClass.rid = [NSString stringWithFormat:@"%lli",nowTime];
    runClass.runway = [NSNumber numberWithInt:kApp.runManager.runway];
    runClass.score = [NSNumber numberWithInt:kApp.runManager.score];
    runClass.secondPerKm = [NSNumber numberWithFloat:kApp.runManager.secondPerKm];
    CNGPSPoint* firstPoint = [kApp.runManager.GPSList firstObject];
    long long stamp = firstPoint.time;
    runClass.startTime = [NSNumber numberWithLongLong:stamp];
    runClass.targetType = [NSNumber numberWithInt:kApp.runManager.targetType];
    runClass.targetValue = [NSNumber numberWithInt:kApp.runManager.targetValue];
    runClass.temp = [NSNumber numberWithInt:0];
    if(kApp.userInfoDic == nil){
        runClass.uid = @"";
    }else{
        runClass.uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
    }
    if(kApp.cloudManager.isSynServerTime){
        runClass.updateTime = [NSNumber numberWithLongLong:(nowTime+kApp.cloudManager.deltaMiliSecond)];
    }else{
        runClass.updateTime = [NSNumber numberWithLongLong:0];
    }
    runClass.weather = [NSNumber numberWithInt:0];
    
    //存储2进制文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[CNUtil getYearMonth:nowTime/1000]];
    BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if(bo){
        NSString* filename = [NSString stringWithFormat:@"%@/%lli.yaopao",[CNUtil getYearMonth:nowTime/1000],nowTime];
        NSLog(@"filename is %@",filename);
        BinaryIOManager* ioManager = [[BinaryIOManager alloc]init];
        [ioManager writeBinary:filename];
        runClass.clientBinaryFilePath = filename;
        runClass.serverBinaryFilePath = @"";
    }else{
        return;
    }
    //如果有图片，存储到手机
    if([imageArray count] > 0){
        NSLog(@"有图片");
        NSMutableString* clientImagePaths = [NSMutableString stringWithString:@""];
        NSMutableString* clientImagePathsSmall = [NSMutableString stringWithString:@""];
        
        for(int i = 0;i<[imageArray count];i++){
            NSString *filePath_big = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lli_%i_big.jpg",nowTime,i]];   // 保存文件的名称
            NSString *filePath_small = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lli_%i_small.jpg",nowTime,i]];
            NSLog(@"filePath_big is %@",filePath_big);
            NSLog(@"filePath_small is %@",filePath_small);
            [UIImagePNGRepresentation((UIImage*)[imageArray objectAtIndex:i]) writeToFile: filePath_big atomically:YES];
            [clientImagePaths appendString:[NSString stringWithFormat:@"%@/%lli_%i_big.jpg|",[CNUtil getYearMonth:nowTime/1000],nowTime,i]];
            UIImage* image_small = [(UIImage*)[imageArray objectAtIndex:i] rescaleImageToSize:CGSizeMake(120, 120)];
            [UIImagePNGRepresentation(image_small) writeToFile: filePath_small atomically:YES];
            [clientImagePathsSmall appendString:[NSString stringWithFormat:@"%@/%lli_%i_small.jpg|",[CNUtil getYearMonth:nowTime/1000],nowTime,i]];
        }
        if([clientImagePaths hasSuffix:@"|"]){
            clientImagePaths = [NSMutableString stringWithString:[clientImagePaths substringToIndex:clientImagePaths.length - 1]];
        }
        if([clientImagePathsSmall hasSuffix:@"|"]){
            clientImagePathsSmall = [NSMutableString stringWithString:[clientImagePathsSmall substringToIndex:clientImagePathsSmall.length - 1]];
        }
        NSLog(@"clientImagePaths is %@",clientImagePaths);
        NSLog(@"clientImagePathsSmall is %@",clientImagePathsSmall);
        runClass.clientImagePaths = clientImagePaths;
        runClass.clientImagePathsSmall = clientImagePathsSmall;
        runClass.serverImagePaths = @"";
        runClass.serverImagePathsSmall = @"";
    }else{
        NSLog(@"没有图片");
        runClass.clientImagePaths = @"";
        runClass.clientImagePathsSmall = @"";
        runClass.serverImagePaths = @"";
        runClass.serverImagePathsSmall = @"";
    }
    NSError *error = nil;
    if (![kApp.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@", error);
        abort();
    }
    NSLog(@"add success");
    //更新plist中个人总记录：
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
    total_distance += kApp.runManager.distance;
    total_count++;
    total_time += [kApp.runManager during]/1000;
    total_score += kApp.runManager.score;
    [record_dic setObject:[NSString stringWithFormat:@"%f",total_distance] forKey:@"total_distance"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_count] forKey:@"total_count"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_time] forKey:@"total_time"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_score] forKey:@"total_score"];
    [record_dic writeToFile:filePath_record atomically:YES];
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
@end

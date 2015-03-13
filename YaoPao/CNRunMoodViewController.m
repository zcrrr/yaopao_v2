//
//  CNRunMoodViewController.m
//  YaoPao
//
//  Created by zc on 14-8-5.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunMoodViewController.h"
#import "CNMainViewController.h"
#import "CNShareViewController.h"
#import "SBJson.h"
#import "CNGPSPoint.h"
#import "RunClass.h"
#import "CNUtil.h"
#import "UIImage+Rescale.h"
#import "CNRunRecordViewController.h"
#import "CNRunManager.h"
#import "BinaryIOManager.h"
#import "Toast+UIView.h"
#import "CNCloudRecord.h"


@interface CNRunMoodViewController ()

@end

@implementation CNRunMoodViewController
@synthesize image_small;
@synthesize hasPhoto;

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
    kApp.isRunning = 0;
    kApp.gpsLevel = 1;
    // Do any additional setup after loading the view from its nib.
    
    self.textfield_feel.delegate = self;
    [self.button_delete addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_save addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[CNUtil getNowTime]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M月d日"];
    NSString* strDate2 = [dateFormatter stringFromDate:date];
    NSString* typeDes = @"";
    switch (kApp.runManager.howToMove) {
        case 1:
        {
            typeDes = @"跑步";
            break;
        }
        case 2:
        {
            typeDes = @"步行";
            break;
        }
        case 3:
        {
            typeDes = @"自行车骑行";
            break;
        }
        default:
            break;
    }
    self.label_title.text = [NSString stringWithFormat:@"%@的%@",strDate2,typeDes];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_delete_clicked:(id)sender {
    self.button_delete.backgroundColor = [UIColor clearColor];
    CNMainViewController* mainVC = [[CNMainViewController alloc]init];
    [self.navigationController pushViewController:mainVC animated:YES];
}
- (IBAction)button_mood_clicked:(id)sender {
    [self resetMoodButtonStatus];
    int tag = [sender tag];
    NSString* imageName = [NSString stringWithFormat:@"mood%i_h.png",tag];
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    kApp.runManager.feeling = tag;
}

- (IBAction)button_track_clicked:(id)sender {
    [self resetWayButtonStatus];
    int tag = [sender tag];
    NSString* imageName = [NSString stringWithFormat:@"way%i_h.png",tag];
    [(UIButton*)sender setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
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
- (IBAction)button_photo_clicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选取来自" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"用户相册", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)button_save_clicked:(id)sender {
    self.button_save.backgroundColor = [UIColor clearColor];
    //先保存，然后跳转
    [self saveRun];
    CNShareViewController* shareVC = [[CNShareViewController alloc]init];
    shareVC.dataSource = @"this";
    [self.navigationController pushViewController:shareVC animated:YES];
    if(kApp.isLogin == 1){
        [CNAppDelegate popupWarningCloud];
    }
    
//    CNRunRecordViewController* recordVC = [[CNRunRecordViewController alloc]init];
//    [self.navigationController pushViewController:recordVC animated:YES];
}
- (void)saveRun{
    long long nowTime = [CNUtil getNowTime1000];
    kApp.runManager.remark = self.textfield_feel.text;
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
        [kApp.window makeToast:@"保存运动轨迹文件出错"];
        return;
    }
    //如果有图片，存储到手机
    if(self.hasPhoto){
        NSLog(@"有图片");
        NSString *filePath_big = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lli_big.jpg",nowTime]];   // 保存文件的名称
        NSString *filePath_small = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lli_small.jpg",nowTime]];
        NSLog(@"filePath_big is %@",filePath_big);
        NSLog(@"filePath_small is %@",filePath_small);
        if ([UIImagePNGRepresentation(self.imageview_photo.image) writeToFile: filePath_big atomically:YES]) {
            [UIImagePNGRepresentation(self.image_small) writeToFile: filePath_small atomically:YES];
            runClass.clientImagePaths = [NSString stringWithFormat:@"%@/%lli_big.jpg",[CNUtil getYearMonth:nowTime/1000],nowTime];
            runClass.clientImagePathsSmall = [NSString stringWithFormat:@"%@/%lli_small.jpg",[CNUtil getYearMonth:nowTime/1000],nowTime];
            runClass.serverImagePaths = @"";
            runClass.serverImagePathsSmall = @"";
        }else{
            runClass.clientImagePaths = @"";
            runClass.clientImagePathsSmall = @"";
            runClass.serverImagePaths = @"";
            runClass.serverImagePathsSmall = @"";
        }
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
    UIImage* image_big = [image rescaleImageToSize:CGSizeMake(640, 640)];
    self.image_small = [image rescaleImageToSize:CGSizeMake(120, 120)];
    self.imageview_photo.image = image;
    self.imageview_photo.contentMode = UIViewContentModeScaleAspectFill;
    self.hasPhoto = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.button_takephoto.hidden = YES;
}

@end

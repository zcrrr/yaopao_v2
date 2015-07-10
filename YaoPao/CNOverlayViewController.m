//
//  CNOverlayViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/3/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNOverlayViewController.h"
#import "UIImage+Rescale.h"
#import "Toast+UIView.h"
#import "CNUtil.h"


@interface CNOverlayViewController ()

@end

@implementation CNOverlayViewController
@synthesize cameraPicker;
@synthesize delegate_savaImage;
NSMutableArray* imageArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.indicator.hidden = YES;
    self.button_takephoto.hidden = NO;
    if(!iPhone5){//4、4s
        self.button_cancel.frame = CGRectMake(33, 11, 35, 35);
        self.button_takephoto.frame = CGRectMake(128, 1, 55, 55);
        self.indicator.frame = CGRectMake(145, 18, 20, 20);
    }
    [CNUtil checkUserPermission];
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
            [self.cameraPicker dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
            self.indicator.hidden = NO;
            self.button_takephoto.hidden = YES;
            [self.indicator startAnimating];
            [self.cameraPicker takePicture];
            NSLog(@"开始拍照");
            break;
        default:
            break;
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"得到照片");
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    float width = image.size.width;
    float height = image.size.height;
    UIImage* imageScaled;
    if(width > 1080 && height > 1080){
        imageScaled = [image rescaleImageToSize:CGSizeMake(1080, 1080)];
    }else{
        imageScaled = [image rescaleImageToSize:CGSizeMake(640, 640)];
    }
    self.indicator.hidden = YES;
    self.button_takephoto.hidden = NO;
    [self.indicator stopAnimating];
//    self.imagePreviewVC.cameraPicker = self.cameraPicker;
//    self.imagePreviewVC.delegete_saveImage = self.delegate_savaImage;
//    [self.cameraPicker pushViewController:self.imagePreviewVC animated:YES];
    UIImageWriteToSavedPhotosAlbum(imageScaled, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    extern NSMutableArray* imageArray;
    if(imageArray == nil){
        imageArray = [[NSMutableArray alloc]init];
    }
    [imageArray addObject:imageScaled];
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
        [self.delegate_savaImage saveImageDidFailed];
    }else{
        msg = @"保存图片成功" ;
        [self.delegate_savaImage saveImageDidSuccess:image];
    }
    [kApp.window makeToast:msg duration:1 position:nil];
    [self.cameraPicker dismissViewControllerAnimated:YES completion:nil];
    
}
@end

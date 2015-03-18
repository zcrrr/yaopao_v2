//
//  CNOverlayViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/3/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNOverlayViewController.h"
#import "UIImage+Rescale.h"
#import "CNImagePreviewViewController.h"


@interface CNOverlayViewController ()

@end

@implementation CNOverlayViewController
@synthesize cameraPicker;
@synthesize imagePreviewVC;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
            [self.cameraPicker takePicture];
            break;
        default:
            break;
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    float width = image.size.width;
    float height = image.size.height;
    UIImage* imageScaled;
    if(width > 1080 && height > 1080){
        imageScaled = [image rescaleImageToSize:CGSizeMake(1080, 1080)];
    }else{
        imageScaled = [image rescaleImageToSize:CGSizeMake(640, 640)];
    }
    if(self.imagePreviewVC == nil){
        self.imagePreviewVC = [[CNImagePreviewViewController alloc]init];
    }
    self.imagePreviewVC.image = imageScaled;
    [self.cameraPicker pushViewController:self.imagePreviewVC animated:YES];
}
@end

//
//  CNImagePreviewViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/3/17.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNImagePreviewViewController.h"
#import "Toast+UIView.h"

@interface CNImagePreviewViewController ()

@end

@implementation CNImagePreviewViewController
NSMutableArray* imageArray;
@synthesize cameraPicker;
@synthesize image;
@synthesize delegete_saveImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(!iPhone5){//4、4s
        self.button_rePhoto.frame = CGRectMake(33, 14, 41, 41);
        self.button_save.frame = CGRectMake(246, 14, 41, 41);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.imageview.image = self.image;
    float image_width = self.image.size.width;
    float image_height = self.image.size.height;
    NSLog(@"image_width is %f",image_width);
    NSLog(@"image_height is %f",image_height);
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
            [self.cameraPicker dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 2:
        {
            self.button_save.enabled = NO;
            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            extern NSMutableArray* imageArray;
            if(imageArray == nil){
                imageArray = [[NSMutableArray alloc]init];
            }
            [imageArray addObject:self.image];
            break;
        }
            
        default:
            break;
    }
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
        [self.delegete_saveImage saveImageDidFailed];
    }else{
        msg = @"保存图片成功" ;
        [self.delegete_saveImage saveImageDidSuccess:self.image];
    }
    [kApp.window makeToast:msg duration:1 position:nil];
    [self.cameraPicker dismissViewControllerAnimated:YES completion:nil];
    
}
@end

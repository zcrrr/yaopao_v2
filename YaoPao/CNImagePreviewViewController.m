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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.imageview.image = self.image;
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
    }else{
        msg = @"保存图片成功" ;
    }
    [kApp.window makeToast:msg];
    [self.navigationController popViewControllerAnimated:YES];
}
@end

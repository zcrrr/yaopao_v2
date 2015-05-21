//
//  CombineImagePreviewViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/5/6.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CombineImagePreviewViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "Toast+UIView.h"

@interface CombineImagePreviewViewController ()

@end

@implementation CombineImagePreviewViewController
@synthesize image;
@synthesize delegate_combineImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageview.image = self.image;
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
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1:
        {
            NSLog(@"保存");
            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            extern NSMutableArray* imageArray;
            if(imageArray == nil){
                imageArray = [[NSMutableArray alloc]init];
            }
            [imageArray addObject:self.image];
            [self.delegate_combineImage combineImageDidSuccess:self.image];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 2:
        {
            NSLog(@"分享");
            [self sharetest];
            break;
        }
        default:
            break;
    }
}
- (void)sharetest{
    id<ISSContent> publishContent = [ShareSDK content:@"2015绍兴穿越古城路跑定向赛"
                                       defaultContent:@"2015绍兴穿越古城路跑定向赛"
                                                image:[ShareSDK pngImageWithImage:self.image]
                                                title:@"2015绍兴穿越古城路跑定向赛"
                                                  url:@"http://image.yaopao.net/html/redirect.html"
                                          description:@"2015绍兴穿越古城路跑定向赛"
                                            mediaType:SSPublishContentMediaTypeImage];
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    [kApp.window makeToast:msg duration:1 position:nil];
}
@end

//
//  CNChooseModelViewController.m
//  YaoPao
//
//  Created by 张驰 on 15/5/6.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNChooseModelViewController.h"
#import "UIImage+Rescale.h"
#import "CombineImagePreviewViewController.h"

@interface CNChooseModelViewController ()

@end

@implementation CNChooseModelViewController
@synthesize modelType;
@synthesize delegate_combineImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.button_model1.layer.cornerRadius = 15;
    self.button_model1.layer.masksToBounds = YES;
    self.button_model2.layer.cornerRadius = 15;
    self.button_model2.layer.masksToBounds = YES;
    self.button_model3.layer.cornerRadius = 15;
    self.button_model3.layer.masksToBounds = YES;
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
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
}
- (void)chooseImage:(int)count{
    DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
    cont.delegate = self;
    cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
    cont.nMaxCount = count;
    cont.nColumnCount = 3;
//    [self presentViewController:cont animated:YES completion:nil];
    [self.navigationController pushViewController:cont animated:YES];
}
- (IBAction)button_clicked:(id)sender {
    switch ([sender tag]) {
        case 0:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1:
        {
            self.modelType = 1;
            [self chooseImage:3];
            break;
        }
        case 2:
        {
            self.modelType = 2;
            [self chooseImage:2];
            break;
        }
        case 3:
        {
            self.modelType = 3;
            [self chooseImage:3];
            break;
        }
        default:
            break;
    }
}
#pragma mark - DoImagePickerControllerDelegate
- (void)didCancelDoImagePickerController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected
{
    //生成拼图
    CombineImagePreviewViewController* cipVC = [[CombineImagePreviewViewController alloc]init];
    cipVC.image = [self combineImage:self.modelType :aSelected];
    cipVC.delegate_combineImage = self.delegate_combineImage;
    [self.navigationController pushViewController:cipVC animated:YES];
}
- (UIImage*)combineImage:(int)type :(NSArray*)aSelected{
    //准备素材：
    UIImage* backgroudImage = [UIImage imageNamed:[NSString stringWithFormat:@"model%i.png",type]];
    switch (type) {
        case 1:
        {
            UIImage* image1 = [aSelected objectAtIndex:0];
            UIImage* image2 = [aSelected objectAtIndex:1];
            UIImage* image3 = [aSelected objectAtIndex:2];
            
            UIGraphicsBeginImageContext(backgroudImage.size);
            //将图片缩放到指定尺寸
            UIImage* image1_scaled = [image1 rescaleImageToSize:CGSizeMake(410, 410)];
            UIImage* image2_scaled = [image2 rescaleImageToSize:CGSizeMake(310, 310)];
            UIImage* image3_scaled = [image3 rescaleImageToSize:CGSizeMake(484, 484)];
            
            //先绘制小图
            [image1_scaled drawInRect:CGRectMake(76, 249, image1_scaled.size.width, image1_scaled.size.height)];
            [image2_scaled drawInRect:CGRectMake(98, 727, image2_scaled.size.width, image2_scaled.size.height)];
            [image3_scaled drawInRect:CGRectMake(518, 506, image3_scaled.size.width, image3_scaled.size.height)];
            break;
        }
        case 2:
        {
            UIImage* image1 = [aSelected objectAtIndex:0];
            UIImage* image2 = [aSelected objectAtIndex:1];
            
            UIGraphicsBeginImageContext(backgroudImage.size);
            //将图片缩放到指定尺寸
            UIImage* image1_scaled = [image1 rescaleImageToSize:CGSizeMake(379, 379)];
            UIImage* image2_scaled = [image2 rescaleImageToSize:CGSizeMake(609, 609)];
            
            //先绘制小图
            [image1_scaled drawInRect:CGRectMake(68, 641, image1_scaled.size.width, image1_scaled.size.height)];
            [image2_scaled drawInRect:CGRectMake(413, 311, image2_scaled.size.width, image2_scaled.size.height)];
            break;
        }
        case 3:
        {
            UIImage* image1 = [aSelected objectAtIndex:0];
            UIImage* image2 = [aSelected objectAtIndex:1];
            UIImage* image3 = [aSelected objectAtIndex:2];
            
            UIGraphicsBeginImageContext(backgroudImage.size);
            //将图片缩放到指定尺寸
            UIImage* image1_scaled = [image1 rescaleImageToSize:CGSizeMake(388, 388)];
            UIImage* image2_scaled = [image2 rescaleImageToSize:CGSizeMake(290, 290)];
            UIImage* image3_scaled = [image3 rescaleImageToSize:CGSizeMake(198, 198)];
            
            //先绘制小图
            [image1_scaled drawInRect:CGRectMake(90, 641, image1_scaled.size.width, image1_scaled.size.height)];
            [image2_scaled drawInRect:CGRectMake(396, 434, image2_scaled.size.width, image2_scaled.size.height)];
            [image3_scaled drawInRect:CGRectMake(634, 287, image3_scaled.size.width, image3_scaled.size.height)];
            break;
        }
        default:
            break;
    }
    
    //再绘制大图
    [backgroudImage drawInRect:CGRectMake(0, 0, backgroudImage.size.width, backgroudImage.size.height)];
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end

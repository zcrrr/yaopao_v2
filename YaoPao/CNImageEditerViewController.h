//
//  CNImageEditerViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/23.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>
#import "WaterMarkViewController.h"
#import "CNOverlayViewController.h"
#import "ChooseEditImageViewController.h"
#import "CombineImagePreviewViewController.h"
#import "AddWaterMarkToImageViewController.h"

@class CNCustomButton;
@class CNOverlayViewController;
@class AdobeUXImageEditorViewController;
@class RunClass;

@protocol EditImageDelegate <NSObject>
//登录接口成功或者失败的协议，如果失败了会有原因mes
- (void)editImageDidSuccess;
@end

@interface CNImageEditerViewController : UIViewController<UIScrollViewDelegate,AdobeUXImageEditorViewControllerDelegate,addWaternDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,saveImageDelegate,buttonClickDelegate,combineImageDelegate,addWaterDelegate>

@property (strong ,nonatomic) RunClass* oneRun;
@property (strong, nonatomic) NSMutableArray* editImageArray;
@property (strong, nonatomic) NSMutableArray* clientImagePathsArray;
@property (strong, nonatomic) NSMutableArray* clientImagePathsSmallArray;
@property (strong, nonatomic) NSMutableArray* serverImagePathsArray;
@property (strong, nonatomic) NSMutableArray* serverImagePathsSmallArray;

@property (assign, nonatomic) BOOL isThisRecordClouded;
@property (assign, nonatomic) int currentpage;
@property (strong, nonatomic) UIImagePickerController* cameraPicker;
@property (strong, nonatomic) CNOverlayViewController* overlayVC;
@property (strong, nonatomic) AdobeUXImageEditorViewController *editorController;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet CNCustomButton *button_back;
@property (weak, nonatomic) IBOutlet UIButton *button_left;
@property (weak, nonatomic) IBOutlet UIButton *button_right;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UILabel *label_whichpage;
@property (weak, nonatomic) IBOutlet UIImageView *imageview_page;
- (IBAction)button_clicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button_deleteImage;
@property (weak, nonatomic) IBOutlet UIButton *button_edit;
@property (weak, nonatomic) IBOutlet UIButton *button_save;
@property (weak, nonatomic) IBOutlet UIButton *button_water;
@property (strong, nonatomic) id<EditImageDelegate> delegate_editImage;

@end

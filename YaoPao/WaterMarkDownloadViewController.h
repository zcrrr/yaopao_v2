//
//  WaterMarkDownloadViewController.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/27.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ToolClass.h"
#import "XXFAdHeadlineView.h"
#import "CNNetworkHandler.h"

@interface WaterMarkDownloadViewController : UIViewController<ASIHTTPRequestDelegate,ASIProgressDelegate,WaterMarkInfoDelegate>

@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSMutableArray *WaterMarkInfoArray;
@property (strong, nonatomic) NSMutableArray *ImageLoopInfoArray;
@property (strong, nonatomic) NSMutableArray *progressBarArray;
@property (weak, nonatomic) IBOutlet XXFAdHeadlineView *ImageLoop;
@property (weak, nonatomic) IBOutlet UITableView *WaterMarkTable;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)back:(id)sender;
@end

//
//  WaterMarkDownloadViewController.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/27.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "WaterMarkDownloadViewController.h"
#import "WaterMarkTableViewCell.h"
#import "WMInfo.h"
#import "ZipArchive.h"
#import "GCD.h"
#import "UIImageView+WebCache.h"
#import "SBJson.h"
#import "UIViewController+HUD.h"
@interface WaterMarkDownloadViewController ()


@end

@implementation WaterMarkDownloadViewController

@synthesize imageArray;

#pragma -mark 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageArray = [[NSMutableArray alloc]init];
    self.WaterMarkInfoArray = [[NSMutableArray alloc]init];
    self.progressBarArray = [[NSMutableArray alloc]init];
    self.ImageLoopInfoArray = [[NSMutableArray alloc]init];
//    //请求时间戳
//    [self requestTimeStamp];
    if(kApp.hasNewWaterMaker){//有红点进来的肯定要下载
        [self requestWaterMark];
    }else{//没有红点进来的
        //水印更新时间戳一致，读取本地缓存水印
        [self readWmInfosFromLocal];
        self.pageControl.numberOfPages = self.ImageLoopInfoArray.count;
        [self.WaterMarkTable reloadData];
    }
}


- (void)viewDidAppear:(BOOL)animated{
    
}
- (void)viewWillDisappear:(BOOL)animated{
    

}



#pragma -mark 自定义
//使UIImage适应UIImageView的Size
- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (void)InitImageLoopView:(NSMutableArray *)imageArr{
    
    [self.ImageLoop initSubViews];
    [self.ImageLoop setSlideImgArr:imageArr Interval:3];
}

- (void)downloadWaterMark:(UIButton *)btn{
    NSLog(@"下载第%li行水印 ",(long)btn.tag);
    WMInfo *info = [self.WaterMarkInfoArray objectAtIndex:btn.tag];
    info.Status = WMStatusDownLoading;
    [self.WaterMarkTable reloadData];
    [self requestWaterMarkWithProgress:btn.tag];
}

- (void)deleteWaterMark:(UIButton *)btn{
    WMInfo *info = [self.WaterMarkInfoArray objectAtIndex:btn.tag];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *zipFile = [NSString stringWithFormat:@"%@/%@.zip",documentPath,info.Name];
    NSString *Folder = [NSString stringWithFormat:@"%@/waterMarks/%@",documentPath,info.Name];
    BOOL isExist = [fileManager fileExistsAtPath:zipFile];
    NSError *error;
    if (isExist) {
        
        [fileManager removeItemAtPath:zipFile error:&error];
    }
    BOOL isExist1 = [fileManager fileExistsAtPath:Folder];
    if (isExist1) {
        [fileManager removeItemAtPath:Folder error:&error];
    }
    info.Status = WMStatusUnDownLoad;
    [self saveWMInfosToLocal];
    [self deletewaterMarkFromFolder:info.Name];
    [self.WaterMarkTable reloadData];
}

//将水印文件夹信息存储到plist中 方便添加水印页面读取
- (void)savewaterMarkToFolder:(NSString *)name{
    
   NSString *filepath = [ToolClass getDocument:@"wmFolders.plist"];
    
   NSMutableArray  *wmFolder = [NSMutableArray arrayWithContentsOfFile:filepath];
    if (wmFolder == nil) {
        wmFolder = [[NSMutableArray alloc]init];
    }
    
    NSDictionary *dic = @{@"name":name};
    [wmFolder addObject:dic];
    
    [ToolClass saveToPlist:@"wmFolders.plist" :wmFolder];
}

//将水印文件夹信息删除
- (void)deletewaterMarkFromFolder:(NSString *)name{
    
    NSString *filepath = [ToolClass getDocument:@"wmFolders.plist"];
    NSMutableArray *wmFolder = [NSMutableArray arrayWithContentsOfFile:filepath];
    
    for (NSDictionary *dic in wmFolder) {
        NSString *FolderName =[dic objectForKey:@"name"];
        if ([name isEqualToString:FolderName]) {
            [wmFolder removeObject:dic];
            break;
        }
    }
    [ToolClass saveToPlist:@"wmFolders.plist" :wmFolder];
}


- (void)saveWMInfosToLocal{
    
    
    //存水印信息
    NSMutableArray *saveArray = [[NSMutableArray alloc]init];
    
    for (WMInfo *info in self.WaterMarkInfoArray) {
        
        NSString *status  =[NSString stringWithFormat:@"%ld",(long)info.Status];
        NSString *isNew;
        if (info.newOne) {
            isNew = @"true";
        }
        else{
            isNew = @"false";
        }
        NSDictionary *dic = @{@"name":info.Name,@"details":info.Details,@"imageurl":info.imageUrl,@"wmzipurl":info.WMZipUrl,@"status":status,@"isnew":isNew};
        [saveArray addObject:dic];
    }
    [ToolClass saveToPlist:@"WaterMarkInfos.plist" :saveArray];
    
    //存轮播信息
    [ToolClass saveToPlist:@"ImageLoopUrls.plist" :self.ImageLoopInfoArray];
}
- (void)readWmInfosFromLocal{
    //读取本地缓存水印信息
    NSString *filePath = [ToolClass getDocument:@"WaterMarkInfos.plist"];
    NSMutableArray *saveArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    if(saveArray == nil){
        [self requestWaterMark];
        return;
    }
    for (NSDictionary *dic in saveArray) {
        WMInfo *info = [[WMInfo alloc]init];
        info.Name = [dic objectForKey:@"name"];
        info.Details = [dic objectForKey:@"details"];
        info.imageUrl = [dic objectForKey:@"imageurl"];
        info.WMZipUrl = [dic objectForKey:@"wmzipurl"];
        NSInteger status = [[dic objectForKey:@"status"] integerValue];
        if (status == WMStatusDownLoading) {
            info.Status = WMStatusUnDownLoad;
        }
        else{
            info.Status = status;
        }
        NSString* isNew = [dic objectForKey:@"isnew"];
        if ([isNew isEqualToString:@"true"]) {
            info.newOne = YES;
        }
        else{
            info.newOne = NO;
        }
        [self.WaterMarkInfoArray addObject:info];
    }
    
    //读取本地缓存ImageLoop的URL
    NSString *imageFilePath = [ToolClass getDocument:@"ImageLoopUrls.plist"];
    self.ImageLoopInfoArray = [NSMutableArray arrayWithContentsOfFile:imageFilePath];
    
    [self updateImageLoop:self.ImageLoopInfoArray];
}

//异步加载轮播图片，加载完毕初始化轮播控件
- (void)updateImageLoop:(NSArray *)array{
    
    self.imageArray = [NSMutableArray arrayWithArray:array];
    [self InitImageLoopView:self.imageArray];
}

- (void)requestWaterMark{
    [kApp.networkHandler doRequest_WaterMarkInfo];
    kApp.networkHandler.delegate_WaterMarkInfo = self;
}



- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark 请求时间戳与水印信息delegate

- (void)WaterMarkInfoDidSuccess:(NSString* ) watermark{
    SBJsonParser *parser = [[SBJsonParser alloc]init];
    NSDictionary *dic = [parser objectWithString:watermark];
    NSArray *LoopImages= [dic objectForKey:@"headers"];
    self.ImageLoopInfoArray = [NSMutableArray arrayWithArray:LoopImages];

    if (self.ImageLoopInfoArray) {
        [self updateImageLoop:self.ImageLoopInfoArray];
    }
   
    self.pageControl.numberOfPages = self.ImageLoopInfoArray.count;

    
    //读取水印信息并缓存
    NSArray *WmArrays = [dic objectForKey:@"watermarks"];
    for (NSDictionary *watermarkDic in WmArrays) {
        WMInfo *info =[[WMInfo alloc]init];
        info.Name = [watermarkDic objectForKey:@"name"];
        info.Status = WMStatusUnDownLoad;
        info.Details = [watermarkDic objectForKey:@"desc"];
        info.imageUrl = [watermarkDic objectForKey:@"icon"];
        info.WMZipUrl = [watermarkDic objectForKey:@"url"];
        bool isNew = [[watermarkDic objectForKey:@"isnew"]boolValue];
        if (isNew) {
            info.newOne = YES;
        }
        else{
            info.newOne = NO;
        }
        [self.WaterMarkInfoArray addObject:info];
    }
    //缓存水印信息
    [self saveWMInfosToLocal];
    //加载列表信息
    [self.WaterMarkTable reloadData];
    NSDictionary* saveDic = [[NSDictionary alloc]initWithObjectsAndKeys:kApp.waterTimeStampNew,@"timestamp", nil];
    [ToolClass saveToPlist:@"WMTimeStamp.plist" :saveDic];
    kApp.hasNewWaterMaker = NO;
}

- (void)WaterMarkInfoDidFailed:(NSString* ) mes{
    NSLog(@"%@",mes);
}
#pragma mark network
- (void)requestWaterMarkWithProgress:(NSInteger)tag{
    

    WMInfo *info = [self.WaterMarkInfoArray objectAtIndex:tag];
    
    NSURL* url = [NSURL URLWithString:info.WMZipUrl];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

    request.tag = tag;
    //设定进度条
    [request setDownloadProgressDelegate:[self.progressBarArray objectAtIndex:tag]];
    [request setTimeOutSeconds:15];
    request.delegate = self;
    [request startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request{

    WMInfo *info = [self.WaterMarkInfoArray objectAtIndex:request.tag];
    
    
    [GCDQueue executeInGlobalQueue:^{
        //保存zip
        NSData *requestData = [request responseData];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString* zipFile = [NSString stringWithFormat:@"%@/%@.zip",documentPath,info.Name];
        
        [requestData writeToFile:zipFile atomically:NO];
        
        //解压
        ZipArchive* zip = [[ZipArchive alloc] init];
        NSString* unZipTo = [NSString stringWithFormat:@"%@/waterMarks/%@",documentPath,info.Name];
        if( [zip UnzipOpenFile:zipFile] ){
            BOOL result = [zip UnzipFileTo:unZipTo overWrite:YES];
            if( NO==result ){
                
            }
            [zip UnzipCloseFile];
        }
        //主线程更新列表状态
        [GCDQueue executeInMainQueue:^{
            
            info.Status = WMStatusDownLoaded;
            [self saveWMInfosToLocal];
            [self savewaterMarkToFolder:info.Name];
            [self.WaterMarkTable reloadData];
        }];
    }];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.WaterMarkInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WaterMarkTableViewCell";
    WaterMarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"WaterMarkTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
         cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    if (self.WaterMarkInfoArray.count < indexPath.row) {
        
        return cell;
    }
    

    WMInfo *info = [self.WaterMarkInfoArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = info.Name;
    cell.detailLabel.text = info.Details;
    NSLog(@"info.newOne is %i",info.newOne);
    cell.NewFlagImageView.hidden = !info.newOne;
    switch (info.Status) {
        case WMStatusDownLoaded:
            cell.deleteBtn.hidden = NO;
            cell.downLoadBtn.hidden = YES;
            cell.downLoadProgress.hidden = YES;
            break;
        case WMStatusUnDownLoad:
            cell.deleteBtn.hidden = YES;
            cell.downLoadBtn.hidden = NO;
            cell.downLoadProgress.hidden = YES;
            break;
        case WMStatusDownLoading:
            cell.deleteBtn.hidden = YES;
            cell.downLoadBtn.hidden = YES;
            cell.downLoadProgress.hidden = NO;
            break;
        default:
            break;
    }
    
    [cell.IconImageView sd_setImageWithURL:[NSURL URLWithString:info.imageUrl]];
   
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 6.0f);
    cell.downLoadProgress.transform = transform;
    
    [self.progressBarArray addObject:cell.downLoadProgress];
    cell.downLoadBtn.tag = indexPath.row;
    [cell.downLoadBtn addTarget:self action:@selector(downloadWaterMark:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteWaterMark:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
//       
        
    }else{
        
        
    }
}


@end

//
//  RecordViewController.m
//  AssistUI
//
//  Created by 张驰 on 15/3/10.
//  Copyright (c) 2015年 张驰. All rights reserved.
//

#import "RecordViewController.h"
#import "CNUtil.h"
#import "RunClass.h"
#import "CNResultTableViewCell.h"
#import "CNGPSPoint.h"
#import "BinaryIOManager.h"
#import "CNRunManager.h"
#import "CNTestGEOS.h"
#import "CNRecordDetailViewController.h"
#import "CNRecordDetailGoogleViewController.h"
#import "CNCloudRecord.h"

@interface RecordViewController ()

@end

@implementation RecordViewController
@synthesize pageNumber;
@synthesize recordList;
@synthesize from;
@synthesize page;

- (void)viewDidLoad {
    self.selectIndex = 1;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:@"REFRESH" object:nil];
    self.scrollview.delegate = self;
    self.scrollview.contentSize = CGSizeMake(960, 120);
    self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
    self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
    self.scrollview.pagingEnabled=YES;
    
    self.pageControl.numberOfPages=3; //设置页数为3
    self.pageControl.currentPage=0; //初始页码为 0
    self.pageControl.userInteractionEnabled = NO;//pagecontroller不响应点击操作
    self.pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    
    
    //表格尾部
    self.tableview.tableFooterView = nil;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableview.bounds.size.width, 40.0f)];
    UILabel *loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 116.0f, 40.0f)];
    [loadMoreText setCenter:tableFooterView.center];
    [loadMoreText setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [loadMoreText setTextColor:[UIColor whiteColor]];
    [loadMoreText setText:@"上拉显示更多数据"];
    [tableFooterView addSubview:loadMoreText];
    self.tableview.tableFooterView = tableFooterView;
        
    [self refreshData];
}

- (void)refreshTop{
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
    }
    float totaldistance = [[record_dic objectForKey:@"total_distance"]floatValue]/1000;
    self.label_dis.text = [NSString stringWithFormat:@"%0.2f",totaldistance];
    int total_count = [[record_dic objectForKey:@"total_count"]intValue];
    self.label_count.text = [NSString stringWithFormat:@"%i",total_count];
    int total_second = [[record_dic objectForKey:@"total_time"]intValue];
    self.label_total_time.text = [CNUtil duringTimeStringFromSecond:total_second];
}
- (void)refreshData{
    [self refreshTop];
    self.recordList = [[NSMutableArray alloc]init];
    self.page = 0;
    [self lookup];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView==self.scrollview){
        CGPoint offset = scrollView.contentOffset;
        self.pageControl.currentPage = offset.x/320; //计算当前的页码
        NSLog(@"current page is %i",self.pageControl.currentPage);
    }
}
- (void)lookup{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    //设置请求实体
    [request setEntity:entity];
    //指定对结果的排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rid" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    [request setFetchLimit:10];
    [request setFetchOffset:page * 10];
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[kApp.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    NSLog(@"mutableFetchResult count is %i",[mutableFetchResult count]);
    if(page != 0 && [mutableFetchResult count] == 0){
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"已经没有更多数据了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        return;
    }
    [self.recordList = self.recordList addObjectsFromArray:mutableFetchResult];
    [self.tableview reloadData];
    page++;
}
- (NSString*)imageNameFromType:(int)type{
    NSString* img_name_type = [NSString stringWithFormat:@"howToMove%i.png",type];
    return img_name_type;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.recordList count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"TableViewCell";
    int row = (int)[indexPath row];
    //自定义cell类
    CNResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //通过xib的名称加载自定义的cell
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CNResultTableViewCell" owner:self options:nil] lastObject];
    }
    RunClass *runClass = [self.recordList objectAtIndex:row];
    NSLog(@"averageHeart:%@",runClass.averageHeart);
    NSLog(@"clientBinaryFilePath:%@",runClass.clientBinaryFilePath);
    NSLog(@"clientImagePaths:%@",runClass.clientImagePaths);
    NSLog(@"clientImagePathsSmall:%@",runClass.clientImagePathsSmall);
    NSLog(@"dbVersion:%@",runClass.dbVersion);
    NSLog(@"distance:%@",runClass.distance);
    NSLog(@"duration:%@",runClass.duration);
    NSLog(@"feeling:%@",runClass.feeling);
    NSLog(@"generateTime:%@",runClass.generateTime);
    NSLog(@"gpsCount:%@",runClass.gpsCount);
    NSLog(@"gpsString:%@",runClass.gpsString);
    NSLog(@"heat:%@",runClass.heat);
    NSLog(@"howToMove:%@",runClass.howToMove);
    NSLog(@"isMatch:%@",runClass.isMatch);
    NSLog(@"jsonParam:%@",runClass.jsonParam);
    NSLog(@"kmCount:%@",runClass.kmCount);
    NSLog(@"maxHeart:%@",runClass.maxHeart);
    NSLog(@"mileCount:%@",runClass.mileCount);
    NSLog(@"minCount:%@",runClass.minCount);
    NSLog(@"remark:%@",runClass.remark);
    NSLog(@"rid:%@",runClass.rid);
    NSLog(@"runway:%@",runClass.runway);
    NSLog(@"score:%@",runClass.score);
    NSLog(@"secondPerKm:%@",runClass.secondPerKm);
    NSLog(@"serverBinaryFilePath:%@",runClass.serverBinaryFilePath);
    NSLog(@"serverImagePaths:%@",runClass.serverImagePaths);
    NSLog(@"serverImagePathsSmall:%@",runClass.serverImagePathsSmall);
    NSLog(@"startTime:%@",runClass.startTime);
    NSLog(@"targetType:%@",runClass.targetType);
    NSLog(@"targetValue:%@",runClass.targetValue);
    NSLog(@"temp:%@",runClass.temp);
    NSLog(@"uid:%@",runClass.uid);
    NSLog(@"updateTime:%@",runClass.updateTime);
    NSLog(@"weather:%@",runClass.weather);
    NSLog(@"--------------------------------------------");
    
    int type = [runClass.howToMove intValue];
    cell.image_type.image = [UIImage imageNamed:[self imageNameFromType:type]];
    
    long long stamp = [runClass.startTime longLongValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:stamp/1000];
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    int weekday = (int)[componets weekday];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"M月d日 周%@ HH:mm",[CNUtil weekday2chinese:weekday]]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    cell.label_date.text = [NSString stringWithFormat:@"%@",strDate];
    
    int feeling = [runClass.feeling intValue];
    NSString* img_name_mood = [NSString stringWithFormat:@"mood%i_h.png",feeling];
    cell.image_mood.image = [UIImage imageNamed:img_name_mood];
    
    int way = [runClass.runway intValue];
    NSString* img_name_way = [NSString stringWithFormat:@"way%i_h.png",way];
    cell.image_way.image = [UIImage imageNamed:img_name_way];
    
    if(![runClass.clientImagePathsSmall isEqualToString:@""]){
        NSArray* images = [runClass.clientImagePathsSmall componentsSeparatedByString:@"|"];
        //去沙盒读取图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[images objectAtIndex:0]];
        NSLog(@"filepath is %@",filePath);
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (blHave) {//图片存在
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            cell.image_photo.image = [[UIImage alloc] initWithData:data];
        }
    }
    
    int ismatch = [runClass.isMatch intValue];
    if(ismatch == 1){
        cell.image_mood.image = [UIImage imageNamed:@"matchicon.png"];
    }
    
    cell.label_pspeed.text = [CNUtil pspeedStringFromSecond:[runClass.secondPerKm intValue]];
    
    int duringSecond = [runClass.duration intValue]/1000;
    int minute1 = duringSecond/60;
    int second1 = duringSecond%60;
    cell.label_during.text = [NSString stringWithFormat:@"%02d:%02d",minute1,second1];
    
    //距离
    cell.label_dis.text = [NSString stringWithFormat:@"%0.2fkm",[runClass.distance floatValue]/1000];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = (int)[indexPath row];
    RunClass* oneRun = [self.recordList objectAtIndex:row];
    BinaryIOManager* ioManager = [[BinaryIOManager alloc]init];
    [ioManager readBinary:oneRun.clientBinaryFilePath :[oneRun.gpsCount intValue] :[oneRun.kmCount intValue] :[oneRun.mileCount intValue] :[oneRun.minCount intValue]];
    CNGPSPoint* startPoint = [kApp.runManager.GPSList firstObject];
    BOOL isInChina = [CNTestGEOS isInChina:startPoint.lon :startPoint.lat];
//    isInChina = NO;
    if(isInChina){
        CNRecordDetailViewController* recordDetailVC = [[CNRecordDetailViewController alloc]init];
        recordDetailVC.oneRun = oneRun;
        [self.navigationController pushViewController:recordDetailVC animated:YES];
    }else{
        CNRecordDetailGoogleViewController* recordDetailVC = [[CNRecordDetailGoogleViewController alloc]init];
        recordDetailVC.oneRun = oneRun;
        [self.navigationController pushViewController:recordDetailVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        int row = (int)[indexPath row];
        RunClass* runclass = [self.recordList objectAtIndex:row];
        if(![runclass.uid isEqualToString:@""]){//uid有值说明该记录有可能存在于服务器，所以需要通知一下服务器要删除
            NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
            NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
            NSMutableArray* deleteArray = [cloudDiary objectForKey:@"deleteArray"];
            NSLog(@"rid is %@",runclass.rid);
            [deleteArray addObject:runclass.rid];
            [cloudDiary setObject:deleteArray forKey:@"deleteArray"];
            [cloudDiary writeToFile:filePath_cloud atomically:YES];
        }
        [CNCloudRecord deleteOneRecord:runclass];
        
        [self.recordList removeObjectAtIndex:row];
        [self.tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self refreshTop];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(scrollView == self.tableview){
        if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
        {
            NSLog(@"到最底部上拉");
            [self lookup];
        }
    }
    
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
    if(kApp.unreadMessageCount != 0){
        self.reddot.hidden = NO;
    }else{
        self.reddot.hidden = YES;
    }
    [kApp addObserver:self forKeyPath:@"unreadMessageCount" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [kApp removeObserver:self forKeyPath:@"unreadMessageCount"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"unreadMessageCount"]){
        NSLog(@"--------------unreadMessageCount is %i",kApp.unreadMessageCount);
        if(kApp.unreadMessageCount != 0){
            self.reddot.hidden = NO;
        }else{
            self.reddot.hidden = YES;
        }
    }
}

@end

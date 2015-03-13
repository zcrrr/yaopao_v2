//
//  CNRunRecordViewController.m
//  YaoPao
//
//  Created by zc on 14-8-8.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunRecordViewController.h"
#import "RunClass.h"
#import "CNUtil.h"
#import "CNRecordDetailViewController.h"
#import "CNDistanceImageView.h"
#import "CNMainViewController.h"
#import "CNResultTableViewCell.h"
#import "CNCloudRecord.h"
#import "CNRecordDetailGoogleViewController.h"
#import "BinaryIOManager.h"
#import "CNGPSPoint.h"
#import "CNTestGEOS.h"
#import "CNRunManager.h"

@interface CNRunRecordViewController ()

@end

@implementation CNRunRecordViewController
@synthesize pageNumber;
@synthesize recordList;
@synthesize from;
@synthesize page;
@synthesize frame_dis;
@synthesize frame_count;
@synthesize frame_time;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString* NOTIFICATION_REFRESH = @"REFRESH";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:NOTIFICATION_REFRESH object:nil];
    [self.button_back addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_cloud addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    self.scrollview.delegate = self;
    self.scrollview.contentSize = CGSizeMake(960, 120);
    self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
    self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
    self.scrollview.pagingEnabled=YES;
    
    self.pageControl.numberOfPages=3; //设置页数为3
    self.pageControl.currentPage=0; //初始页码为 0
    self.pageControl.userInteractionEnabled = NO;//pagecontroller不响应点击操作
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    
    
    //表格尾部
    self.tableview.tableFooterView = nil;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableview.bounds.size.width, 40.0f)];
    UILabel *loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 116.0f, 40.0f)];
    [loadMoreText setCenter:tableFooterView.center];
    [loadMoreText setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [loadMoreText setText:@"上拉显示更多数据"];
    [tableFooterView addSubview:loadMoreText];
    self.tableview.tableFooterView = tableFooterView;
    
    self.frame_dis = self.view_dis.frame;
    
    [self refreshData];
}
- (void)refreshData{
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
    }
    float totaldistance = [[record_dic objectForKey:@"total_distance"]floatValue]/1000;
    [self setDisNumImage:totaldistance];
    int total_count = [[record_dic objectForKey:@"total_count"]intValue];
    [self setCountNumImage:total_count];
    int total_second = [[record_dic objectForKey:@"total_time"]intValue];
    [self setTimeNumImage:total_second];
    self.recordList = [[NSMutableArray alloc]init];
    self.page = 0;
    [self lookup];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"已经没有更多数据了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self.recordList = self.recordList addObjectsFromArray:mutableFetchResult];
    [self.tableview reloadData];
    page++;
}
- (IBAction)button_cloud_clicked:(id)sender {
    self.button_cloud.backgroundColor = [UIColor clearColor];
    [CNAppDelegate popupWarningCloud];
}

- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    if([self.from isEqual:@"match"]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
//        CNMainViewController* mainVC = [[CNMainViewController alloc]init];
//        [self.navigationController pushViewController:mainVC animated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}
- (NSString*)imageNameFromType:(int)type{
    NSString* img_name_type = @"runtype_run.png";
    switch (type) {
        case 1:
        {
            img_name_type = @"runtype_run.png";
            break;
        }
        case 2:
        {
            img_name_type = @"runtype_walk.png";
            break;
        } 
        case 3:
        {
            img_name_type = @"runtype_ride.png";
            break;
        }
        default:
            break;
    }
    return img_name_type;
}
- (void)setDisNumImage:(double)distance{
    self.view_dis.frame = self.frame_dis;
    int distance100 = distance*100;
    int dis1num = distance100/100000;
    distance100 = distance100 - dis1num*100000;
    int dis2num = distance100/10000;
    distance100 = distance100 - dis2num*10000;
    int dis3num = distance100/1000;
    distance100 = distance100 - dis3num*1000;
    int dis4num = distance100/100;
    distance100 = distance100 - dis4num*100;
    int dis5num = distance100/10;
    int dis6num = distance100%10;
    self.image_dis1.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis1num]];
    self.image_dis2.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis2num]];
    self.image_dis3.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis3num]];
    self.image_dis4.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis4num]];
    self.image_dis5.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis5num]];
    self.image_dis6.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",dis6num]];
    if(dis1num == 0){
        self.image_dis1.hidden = YES;
        [self offLeft];
        if(dis2num == 0){
            self.image_dis2.hidden = YES;
            [self offLeft];
            if(dis3num == 0){
                self.image_dis3.hidden = YES;
                [self offLeft];
            }
        }
    }
}
- (void)setCountNumImage:(int)count{
    int count1num = count/100;
    count = count-count1num*100;
    int count2num = count/10;
    int count3num = count%10;
    self.image_count1.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",count1num]];
    self.image_count2.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",count2num]];
    self.image_count3.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%i.png",count3num]];
    if(count1num == 0){
        self.image_count1.hidden = YES;
        [self offLeftCount];
        if(count2num == 0){
            self.image_count2.hidden = YES;
            [self offLeftCount];
        }
    }
}
- (void)setTimeNumImage:(int)second{
    NSString* timeString = [CNUtil duringTimeStringFromSecond:second];
    //    NSLog(@"timeString is %@",timeString);
    unichar char1 = [timeString characterAtIndex:0];
    unichar char2 = [timeString characterAtIndex:1];
    unichar char3 = [timeString characterAtIndex:3];
    unichar char4 = [timeString characterAtIndex:4];
    unichar char5 = [timeString characterAtIndex:6];
    unichar char6 = [timeString characterAtIndex:7];
    //    NSLog(@"char1:%c,char2:%c,char3:%c,char4:%c,char5:%c,char6:%c",char1,char2,char3,char4,char5,char6);
    self.image_time1.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char1]];
    self.image_time2.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char2]];
    self.image_time3.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char3]];
    self.image_time4.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char4]];
    self.image_time5.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char5]];
    self.image_time6.image = [UIImage imageNamed:[NSString stringWithFormat:@"red%c.png",char6]];
}
- (void)offLeft{
    //往左偏移width的一半，使居中
    int width = self.image_dis1.frame.size.width;
    CGRect newFrame = self.view_dis.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left-width/2, top);
    self.view_dis.frame = newFrame;
}
- (void)offLeftCount{
    //往左偏移width的一半，使居中
    int width = self.image_count1.frame.size.width;
    CGRect newFrame = self.view_count.frame;
    int left = newFrame.origin.x;
    int top = newFrame.origin.y;
    newFrame.origin = CGPointMake(left-width/2, top);
    self.view_count.frame = newFrame;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.recordList count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"TableViewCell";
    int row = [indexPath row];
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
    int weekday = [componets weekday];
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
        //去沙盒读取图片
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:runClass.clientImagePathsSmall];;
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
    CNDistanceImageView* div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(37, 20, 130, 32)];
    div.distance = [runClass.distance floatValue]/1000;
    div.color = @"red";
    [div fitToSize];
    [cell addSubview:div];
    UIImageView* image_km = [[UIImageView alloc]initWithFrame:CGRectMake(div.frame.origin.x+div.frame.size.width, 20,26, 32)];
    image_km.image = [UIImage imageNamed:@"redkm.png"];
    [cell addSubview:image_km];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = [indexPath row];
    RunClass* oneRun = [self.recordList objectAtIndex:row];
    BinaryIOManager* ioManager = [[BinaryIOManager alloc]init];
    [ioManager readBinary:oneRun.clientBinaryFilePath :[oneRun.gpsCount intValue] :[oneRun.kmCount intValue] :[oneRun.mileCount intValue] :[oneRun.minCount intValue]];
    CNGPSPoint* startPoint = [kApp.runManager.GPSList firstObject];
    BOOL isInChina = [CNTestGEOS isInChina:startPoint.lon :startPoint.lat];
    isInChina = NO;
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
        int row = [indexPath row];
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
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
    {
        NSLog(@"到最底部上拉");
        [self lookup];
    }
}


@end

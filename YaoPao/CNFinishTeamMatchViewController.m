//
//  CNFinishTeamMatchViewController.m
//  YaoPao
//
//  Created by zc on 14-10-2.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNFinishTeamMatchViewController.h"
#import "CNNetworkHandler.h"
#import "ASIHTTPRequest.h"
#import "CNDistanceImageView.h"

@interface CNFinishTeamMatchViewController ()

@end

@implementation CNFinishTeamMatchViewController
@synthesize imageviewList;
@synthesize urlList;
@synthesize div;
@synthesize image_km;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.button_ok addTarget:self action:@selector(button_blue_down:) forControlEvents:UIControlEventTouchDown];
    [self.button_share addTarget:self action:@selector(button_green_down:) forControlEvents:UIControlEventTouchDown];
    kApp.isRunning = 0;
    // Do any additional setup after loading the view from its nib.
    self.scrollview.delegate = self;
    self.imageviewList = [[NSMutableArray alloc]init];
    self.urlList = [[NSMutableArray alloc]init];
    self.label_tname.text = [kApp.matchDic objectForKey:@"groupname"];
    self.label_tname2.text = [NSString stringWithFormat:@"恭喜%@！",[kApp.matchDic objectForKey:@"groupname"]];
    self.div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(4, 220+IOS7OFFSIZE, 260, 64)];
    self.div.color = @"red";
    [self.div fitToSize];
    [self.scrollview addSubview:self.div];
    self.image_km = [[UIImageView alloc]initWithFrame:CGRectMake(div.frame.origin.x+div.frame.size.width, 220+IOS7OFFSIZE,52, 64)];
    self.image_km.image = [UIImage imageNamed:@"redkm.png"];
    [self.scrollview addSubview:self.image_km];
    
    
    int height = 468;
    if(iPhone5){
        height = 468;
    }else{
        height = 380;
    }
    self.scrollview.contentSize = CGSizeMake(640, height);
    self.scrollview.showsHorizontalScrollIndicator=NO; //不显示水平滑动线
    self.scrollview.showsVerticalScrollIndicator=NO;//不显示垂直滑动线
    self.scrollview.pagingEnabled=YES;
    
    self.pageControl.numberOfPages=2; //设置页数为2
    self.pageControl.currentPage=0; //初始页码为 0
    self.pageControl.userInteractionEnabled = NO;//pagecontroller不响应点击操作
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    [self displayLoading];
    [self performSelector:@selector(requestPersonal) withObject:nil afterDelay:10.0f];
    
}
- (void)button_green_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:111.0/255.0 green:150.0/255.0 blue:26.0/255.0 alpha:1];
}
- (void)button_blue_down:(id)sender{
    ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:0 green:88.0/255.0 blue:142.0/255.0 alpha:1];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView==self.scrollview){
        CGPoint offset = scrollView.contentOffset;
        self.pageControl.currentPage = offset.x/320; //计算当前的页码
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestPersonal{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:kApp.uid forKey:@"uid"];
    [params setObject:kApp.mid forKey:@"mid"];
    [params setObject:kApp.gid forKey:@"gid"];
    kApp.networkHandler.delegate_listPersonal = self;
    [kApp.networkHandler doRequest_listPersonal:params];
    [self displayLoading];
}
#pragma mark- delegate
- (void)listPersonalDidFailed:(NSString *)mes{
    [self hideLoading];
}
- (void)listPersonalDidSuccess:(NSDictionary *)resultDic{
    [self hideLoading];
    double distance = ([[resultDic objectForKey:@"distancegr"]doubleValue]+5)/1000.0;
    self.div.distance = distance;
    self.div.color = @"red";
    [self.div fitToSize];
    self.image_km.frame = CGRectMake(self.div.frame.origin.x+self.div.frame.size.width, 220+IOS7OFFSIZE,52, 64);
    NSArray* dataList = [resultDic objectForKey:@"list"];
    if([dataList count]>0){
        int y_used = 0;
        for(int i=0;i<[dataList count];i++){
            NSDictionary* oneRecordDic = [dataList objectAtIndex:i];
            UIView *view_one_record = [[UIView alloc]initWithFrame:CGRectMake(0, y_used, 320, 60)];
            //头像
            UIImageView* userAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
            userAvatar.image = [UIImage imageNamed:@"avatar_default.png"];
            NSString* avatarUrl = [oneRecordDic objectForKey:@"imgpath"];
            if(avatarUrl == nil){
                avatarUrl = @"";
            }else{
                UIImage* image = [kApp.avatarDic objectForKey:avatarUrl];
                if(image != nil){//缓存中有
                    userAvatar.image = image;
                }else{//下载
                    NSString* imageURL = [NSString stringWithFormat:@"%@%@",kApp.imageurl,avatarUrl];
                    NSLog(@"avatar is %@",imageURL);
                    NSURL *url = [NSURL URLWithString:imageURL];
                    ASIHTTPRequest *Imagerequest = [ASIHTTPRequest requestWithURL:url];
                    Imagerequest.tag = i;
                    Imagerequest.timeOutSeconds = 15;
                    [Imagerequest setDelegate:self];
                    [Imagerequest startAsynchronous];
                }
            }
            [view_one_record addSubview:userAvatar];
            [self.urlList addObject:avatarUrl];
            [self.imageviewList addObject:userAvatar];
            //username
            
            UILabel* label_name = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 100, 60)];
            label_name.textAlignment = NSTextAlignmentLeft;
            label_name.font = [UIFont systemFontOfSize:15];
            label_name.text = [oneRecordDic objectForKey:@"nickname"];
            [view_one_record addSubview:label_name];
            
            double distance = [[oneRecordDic objectForKey:@"km"]doubleValue];
//            UILabel* label_dis = [[UILabel alloc]initWithFrame:CGRectMake(220, 0, 100, 60)];
//            label_dis.textAlignment = NSTextAlignmentRight;
//            label_dis.font = [UIFont systemFontOfSize:15];
//            label_dis.text = [NSString stringWithFormat:@"%0.2fkm",distance/1000.0];
//            [view_one_record addSubview:label_dis];
            
            CNDistanceImageView* small_div = [[CNDistanceImageView alloc]initWithFrame:CGRectMake(160, 14, 130, 32)];
            small_div.distance = (distance+5)/1000.0;
            small_div.color = @"red";
            [small_div fitToSize];
            [view_one_record addSubview:small_div];
            UIImageView* image_km_one = [[UIImageView alloc]initWithFrame:CGRectMake(small_div.frame.origin.x+small_div.frame.size.width, 14,26, 32)];
            image_km_one.image = [UIImage imageNamed:@"redkm.png"];
            [view_one_record addSubview:image_km_one];
            
            UIView *view_line = [[UIView alloc]initWithFrame:CGRectMake(0, 59, 320, 1)];
            [view_line setBackgroundColor:[UIColor lightGrayColor]];
            [view_one_record addSubview:view_line];
            
            [self.view_list addSubview:view_one_record];
            y_used += 60;
        }
        [self.view_list setContentSize:CGSizeMake(320, y_used)];
        
    }
}
- (void)displayLoading{
    self.loadingImage.hidden = NO;
    [self.indicator startAnimating];
    [self disableAllButton];
}
- (void)hideLoading{
    self.loadingImage.hidden = YES;
    [self.indicator stopAnimating];
    [self enableAllButton];
}
- (void)disableAllButton{
    self.button_ok.enabled = NO;
    self.button_share.enabled = NO;
    
}
- (void)enableAllButton{
    self.button_ok.enabled = YES;
    self.button_share.enabled = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)button_ok_clicked:(id)sender {
//    self.button_ok.backgroundColor = [UIColor colorWithRed:0 green:123.0/255.0 blue:199.0/255.0 alpha:1];
//    CNMainViewController* mainvc = [[CNMainViewController alloc]init];
//    [self.navigationController pushViewController:mainvc animated:YES];
}

- (IBAction)button_share_clicked:(id)sender {
//    self.button_share.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:195.0/255.0 blue:31.0/255.0 alpha:1];
//    self.button_ok.backgroundColor = [UIColor colorWithRed:0 green:123.0/255.0 blue:199.0/255.0 alpha:1];
//    CNMainViewController* mainvc = [[CNMainViewController alloc]init];
//    [self.navigationController pushViewController:mainvc animated:YES];
}
@end

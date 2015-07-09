//
//  CNRunTypeViewController.m
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunTypeViewController.h"
#import "CNUtil.h"

@interface CNRunTypeViewController ()

@end

@implementation CNRunTypeViewController
@synthesize selectedIndex;
@synthesize runSettingDic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)changeLineOne:(UIView*)line{
    CGRect frame_new = line.frame;
    frame_new.size = CGSizeMake(frame_new.size.width, 0.5);
    line.frame = frame_new;
}
- (void)viewDidLoad
{
    [CNUtil appendUserOperation:@"进入类型设置页面"];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self changeLineOne:self.view_line1];
    [self changeLineOne:self.view_line2];
    [self changeLineOne:self.view_line3];
    NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
    self.runSettingDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(self.runSettingDic == nil){
        self.runSettingDic = [[NSMutableDictionary alloc]init];
        [self.runSettingDic setObject:@"2" forKey:@"targetType"];
        [self.runSettingDic setObject:@"5" forKey:@"distance"];
        [self.runSettingDic setObject:@"30" forKey:@"time"];
        [self.runSettingDic setObject:@"1" forKey:@"howToMove"];
        [self.runSettingDic setObject:@"1" forKey:@"countdown"];
        [self.runSettingDic setObject:@"1" forKey:@"voice"];
    }
    int type = [[runSettingDic objectForKey:@"howToMove"]intValue];
    [self selectType:type];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button_choose_clicked:(id)sender {
    [self selectType:(int)[sender tag]];
}

- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.runSettingDic setObject:[NSString stringWithFormat:@"%i",self.selectedIndex] forKey:@"howToMove"];
    NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
    [self.runSettingDic writeToFile:filePath atomically:YES];
    [self.navigationController popViewControllerAnimated:YES];
    [CNUtil appendUserOperation:[NSString stringWithFormat:@"类型设定为：%i",self.selectedIndex]];
}
- (void)selectType:(int)type{
    self.selectedIndex = type;
    self.image_choose1.hidden = YES;
    self.image_choose2.hidden = YES;
    self.image_choose3.hidden = YES;
    switch (type) {
        case 1:
        {
            self.image_choose1.hidden = NO;
            break;
        }
        case 2:
        {
            self.image_choose2.hidden = NO;
            break;
        }
        case 3:
        {
            self.image_choose3.hidden = NO;
            break;
        }
        default:
            break;
    }
}
@end

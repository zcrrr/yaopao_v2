//
//  CNRunTargetViewController.m
//  YaoPao
//
//  Created by zc on 14-7-30.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import "CNRunTargetViewController.h"
#import "CNUtil.h"

@interface CNRunTargetViewController ()

@end

@implementation CNRunTargetViewController
@synthesize runSettingDic;
@synthesize selectedIndex;
@synthesize distance;
@synthesize time;
@synthesize dis_array;
@synthesize time_array;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self changeLineOne:self.view_line1];
    [self changeLineOne:self.view_line2];
    [self changeLineOne:self.view_line3];
    [self changeLineOne:self.view_line4];
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
    int target = [[runSettingDic objectForKey:@"targetType"]intValue];
    [self selectTarget:target];
    self.textfield_choose2.text = [NSString stringWithFormat:@"%@km",[self.runSettingDic objectForKey:@"distance"]];
    int second = [[self.runSettingDic objectForKey:@"time"]intValue]*60;
    NSString* timestr = [CNUtil duringTimeStringFromSecond:second];
    self.textfield_choose3.text = timestr;
    self.distance = [[self.runSettingDic objectForKey:@"distance"]intValue];;
    self.time = [[self.runSettingDic objectForKey:@"time"]intValue];
    
    self.textfield_choose2.inputView = self.pickview_dis;
    self.textfield_choose2.inputAccessoryView = self.toolbar_dis;
    
    self.dis_array = [[NSMutableArray alloc]init];
    int i = 0;
    for(i = 1;i<=100;){
        [self.dis_array addObject:[NSString stringWithFormat:@"%i",i]];
        if(i < 20){
            i++;
        }else{
            i = i+5;
        }
    }
    [self.dis_array insertObject:@"21" atIndex:20];
    [self.dis_array insertObject:@"42" atIndex:25];
    self.textfield_choose2.tintColor = [UIColor whiteColor];
    int index_dis = [self.dis_array indexOfObject:[self.runSettingDic objectForKey:@"distance"]];
    [self.pickview_dis selectRow:index_dis inComponent:0 animated:YES];
    
    self.textfield_choose3.inputView = self.pickview_time;
    self.textfield_choose3.inputAccessoryView = self.toolbar_time;
    
    self.time_array = [[NSMutableArray alloc]init];
    for(i=5;i<=360;i=i+5){
        [self.time_array addObject:[NSString stringWithFormat:@"%i",i]];
    }
    self.textfield_choose3.tintColor = [UIColor whiteColor];
    int index_time = [self.time_array indexOfObject:[self.runSettingDic objectForKey:@"time"]];
    [self.pickview_time selectRow:index_time inComponent:0 animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark--委托协议方法
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    int tag = [pickerView tag];
    if(tag == 0){
        return [NSString stringWithFormat:@"%@km",[dis_array objectAtIndex:row]];
    }else{
        int second = [[time_array objectAtIndex:row]intValue]*60;
        NSString* timestr = [CNUtil duringTimeStringFromSecond:second];
        return timestr;
    }
}


#pragma mark--数据源协议方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    int tag = [pickerView tag];
    if(tag == 0){
        return [self.dis_array count];
    }else{
        return [self.time_array count];
    }
}
- (IBAction)dis_selected:(id)sender {
    NSInteger row = [self.pickview_dis selectedRowInComponent:0];
    self.textfield_choose2.text = [NSString stringWithFormat:@"%@km",[self.dis_array objectAtIndex:row]];
    self.distance = [[self.dis_array objectAtIndex:row]intValue];
    [self hideAllTextfiled];
}

- (IBAction)time_selected:(id)sender {
    NSInteger row = [self.pickview_time selectedRowInComponent:0];
    int second = [[time_array objectAtIndex:row]intValue]*60;
    NSString* timestr = [CNUtil duringTimeStringFromSecond:second];
    self.textfield_choose3.text = timestr;
    self.time = [[self.time_array objectAtIndex:row]intValue];
    [self hideAllTextfiled];
}
- (IBAction)button_back_clicked:(id)sender {
    self.button_back.backgroundColor = [UIColor clearColor];
    [self.runSettingDic setObject:[NSString stringWithFormat:@"%i",self.selectedIndex] forKey:@"targetType"];
    [self.runSettingDic setObject:[NSString stringWithFormat:@"%i",self.distance] forKey:@"distance"];
    [self.runSettingDic setObject:[NSString stringWithFormat:@"%i",self.time] forKey:@"time"];
    NSString* filePath = [CNPersistenceHandler getDocument:@"runSetting.plist"];
    [self.runSettingDic writeToFile:filePath atomically:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)button_choose_target:(id)sender {
    [self selectTarget:([sender tag]+1)];
}

- (IBAction)view_touched:(id)sender {
    [self hideAllTextfiled];
}
- (void)selectTarget:(int)index{
    self.selectedIndex = index;
    [self hideAllTextfiled];
    self.button_choose1.hidden = NO;
    self.button_choose2.hidden = NO;
    self.button_choose3.hidden = NO;
    self.image_choose1.hidden = YES;
    self.image_choose2.hidden = YES;
    self.image_choose3.hidden = YES;
    switch (index) {
        case 1:
        {
            self.button_choose1.hidden = YES;
            self.image_choose1.hidden = NO;
            [self hideAllTextfiled];
            break;
        }
        case 2:
        {
            self.button_choose2.hidden = YES;
            self.image_choose2.hidden = NO;
            [self.textfield_choose2 becomeFirstResponder];
            break;
        }
        case 3:
        {
            self.button_choose3.hidden = YES;
            self.image_choose3.hidden = NO;
            [self.textfield_choose3 becomeFirstResponder];
            break;
        }
        default:
            break;
    }
}
- (void)hideAllTextfiled{
    [self.textfield_choose2 resignFirstResponder];
    [self.textfield_choose3 resignFirstResponder];
}

@end

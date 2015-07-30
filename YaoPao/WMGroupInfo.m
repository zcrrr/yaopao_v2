//
//  WMGroupInfo.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/3.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "WMGroupInfo.h"
#import "SBJson.h"
#import "WMItems.h"
@implementation WMGroupInfo



- (void)InitWaterMarkInGroup:(NSString *)jsonStr withDistance:(NSString *)distance withSecondPerKM:(NSString *)secondPerKM withDuring:(NSString *)during withDate:(NSDate *)date{
    
    if (self.json == nil) {
        
        return;
    }
    
    SBJsonParser *SBJson = [[SBJsonParser alloc]init];
    NSDictionary *dic = [SBJson objectWithString:self.json];
    self.watermarkArray = [[NSMutableArray alloc]init];
    NSArray *markers = [dic objectForKey:@"markers"];
    
    for (NSDictionary *singleItemDic in markers) {
        
        WMItems *item = [[WMItems alloc]init];
        item.WMID = [[singleItemDic objectForKey:@"id"] integerValue];
        item.groupName = self.name;
        item.images = [[NSMutableArray alloc]init];
        item.multiDate = [[NSMutableArray alloc]init];
        
        NSArray *elements = [singleItemDic objectForKey:@"elements"];
        
        for (NSDictionary *elementDic in elements) {
            NSInteger type = [[elementDic objectForKey:@"type"] integerValue];
            
            
            //包含image元素
            if (type == 1) {
                
                ImageInfo *image = [[ImageInfo alloc]init];
                image.blackImage = [[elementDic objectForKey:@"black"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                image.whiteImage = [[elementDic objectForKey:@"white"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                image.x = [[elementDic objectForKey:@"x"] doubleValue];
                image.y = [[elementDic objectForKey:@"y"] doubleValue];
                image.width = [[elementDic objectForKey:@"width"] doubleValue];
                image.height = [[elementDic objectForKey:@"height"] doubleValue];
                image.imageType = [[elementDic objectForKey:@"imagetype"] integerValue];
                
                [item.images addObject:image];
            }
            //包含Line元素
            else if (type == 2){
                
                item.line = [[Line alloc]init];
                item.line.x = [[elementDic objectForKey:@"x"]doubleValue];
                item.line.y = [[elementDic objectForKey:@"y"]doubleValue];
                item.line.width = [[elementDic objectForKey:@"width"]doubleValue];
                item.line.height = [[elementDic objectForKey:@"height"]doubleValue];
                
            }
            //包含distance元素
            else if (type == 3 && distance){
                item.distance = [[Distance alloc]init];
                item.distance.text = distance;
                item.distance.x = [[elementDic objectForKey:@"x"]doubleValue];
                item.distance.y = [[elementDic objectForKey:@"y"]doubleValue];
                item.distance.anchor = [[elementDic objectForKey:@"anchor"]integerValue];
                item.distance.fontsize = [[elementDic objectForKey:@"fontsize"]doubleValue];
                
            }
            //包含seconperkm元素
            else if (type == 4 && secondPerKM){
                
                item.secondPerKM = [[SecondPerKM alloc]init];
                item.secondPerKM.text = secondPerKM;
                item.secondPerKM.x = [[elementDic objectForKey:@"x"]doubleValue];
                item.secondPerKM.y = [[elementDic objectForKey:@"y"]doubleValue];
                item.secondPerKM.anchor = [[elementDic objectForKey:@"anchor"]integerValue];
                item.secondPerKM.fontsize = [[elementDic objectForKey:@"fontsize"]doubleValue];
            }
            //包含during元素
            else if (type == 5 && during){
                
                item.during = [[During alloc]init];
                item.during.text = during;
                item.during.x = [[elementDic objectForKey:@"x"]doubleValue];
                item.during.y = [[elementDic objectForKey:@"y"]doubleValue];
                item.during.anchor = [[elementDic objectForKey:@"anchor"]integerValue];
                item.during.fontsize = [[elementDic objectForKey:@"fontsize"]doubleValue];
            }
            //包含date元素
            else if (type == 6 && date){
                
                Date *WMdate = [[Date alloc]init];
                //item.date = [[Date alloc]init];
                
                WMdate.x = [[elementDic objectForKey:@"x"]doubleValue];
                WMdate.y = [[elementDic objectForKey:@"y"]doubleValue];
                WMdate.anchor = [[elementDic objectForKey:@"anchor"]integerValue];
                WMdate.fontsize = [[elementDic objectForKey:@"fontsize"]doubleValue];
                WMdate.dateFormatter = [elementDic objectForKey:@"dateformatter"];
                WMdate.text = [self dateToString:date withFormatter:WMdate.dateFormatter];
                
                [item.multiDate addObject:WMdate];
            }
            //包含Track元素
            else if (type == 7){
                item.track = [[Track alloc]init];
                item.track.x = [[elementDic objectForKey:@"x"]doubleValue];
                item.track.y = [[elementDic objectForKey:@"y"]doubleValue];
                item.track.width = [[elementDic objectForKey:@"width"]doubleValue];
                item.track.height = [[elementDic objectForKey:@"height"]doubleValue];
            }
        }
        
        [self.watermarkArray addObject:item];
    }
}

//时间格式转换
- (NSString *)dateToString:(NSDate *)newDate withFormatter:(NSString *)form{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:form];
    return [formatter stringFromDate:newDate];
}

@end

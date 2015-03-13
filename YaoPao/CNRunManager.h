//
//  CNRunManager.h
//  YaoPao
//
//  Created by zc on 14-12-22.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNRunManager : NSObject
@property (assign, nonatomic) int runType;// 跑步类型：1：日常跑步,2:比赛
@property (assign, nonatomic) int howToMove;// 如何移动：1：跑步，2：步行，3：自行车
@property (assign, nonatomic) int targetType;// 设定的目标类型：1-自由；2-距离；3-时间
@property (assign, nonatomic) int targetValue;// 设定的目标对应的值，毫秒或者米
@property (assign, nonatomic) int runStatus;// 跑步状态：1：运动，2：暂停 3：赛道内，4：偏离赛道
@property (assign, nonatomic) int runway;// 跑道1，2，3，4，5
@property (assign, nonatomic) int feeling;// 心情1，2，3，4，5
@property (strong, nonatomic) NSString* remark;// 说说
@property (strong, nonatomic) UIImage* pictrue;// 图片
@property (assign, nonatomic) int timeInterval;// 取点间隔
@property (assign, nonatomic) int everyXMinute;// 没x分钟入一次数组

@property (assign, nonatomic) NSTimer* timerUpdate;// 取一个gps，更新数据的timer

@property (assign, nonatomic) long long startTimeStamp;// 初始化RunManager的时间戳（毫秒），初始化意味着开始跑步
@property (assign, nonatomic) long long endTimeStamp;//结束跑步时的时间戳
@property (assign, nonatomic) long long startPauseTimeStamp;// 开始暂停时间戳
@property (assign, nonatomic) int pauseSecond;// 总的暂停时间（毫秒）
@property (assign, nonatomic) int targetKM;// 下一个要到达的公里数，为了计算整公里的数据
@property (assign, nonatomic) int targetMile;// 下一个要到达的英里数，为了计算整英里的数据
@property (assign, nonatomic) int targetMinute;// 下一个要到达的分钟数，为了计算整分钟的数据
@property (assign, nonatomic) int pauseCount;//暂停时gps数组个数
// 下面这些变量是在timer中每次根据新的gps刷新值,外部可以访问
@property (assign, nonatomic) int distance;// 个人距离(米)
@property (assign, nonatomic) int secondPerKm;// 每公里配速（秒）
@property (assign, nonatomic) int secondPerMile;// 每英里配速
@property (assign, nonatomic) int averSpeedKm;// 平均速度（km/h）
@property (assign, nonatomic) int averSpeedMile;// 平均速度（mile/h)
@property (assign, nonatomic) int score;// 积分
@property (assign, nonatomic) float completePercent;// 完成目标百分比
@property (assign, nonatomic) double altitudeAdd;// 总高程增加值
@property (assign, nonatomic) double altitudeReduce;// 总高程降低值
// @property (assign, nonatomic) int step;//总步数
// @property (assign, nonatomic) int calorie;//总卡路里

@property (strong, nonatomic) NSMutableArray* dataKm;// 每公里的数据记录
@property (strong, nonatomic) NSMutableArray* dataMile;// 每公里的数据记录
@property (strong, nonatomic) NSMutableArray* dataMin;// 每分钟的数据记录
@property (strong, nonatomic) NSMutableArray* GPSList;// gps序列,每个点有状态，运动/暂停，赛道内/赛道外

- (id)initData;//创建一个实例，需要使用manager的数据结构
- (id)initWithSecond:(int)second;//gps取点间隔创建实例
- (void)startRun;//开始跑步
- (void)finishOneRun;//结束一次运动
- (void)saveOneRecord;//将这次的数据保存到数据库
- (int)during;//返回总的运动时间
- (void)changeRunStatus:(int)status;//改变运动状态

@property (assign, nonatomic) int testnum;

@end

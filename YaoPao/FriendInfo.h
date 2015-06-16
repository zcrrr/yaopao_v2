//
//  FriendInfo.h
//  YaoPao
//
//  Created by 张驰 on 15/4/10.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendInfo : NSObject

//对于一个好友对象（这里的好有对象是已经是好友的人，或者将来可能会发展为好友的人），可能有的所有属性如下，根据好友的类型不同不一定每个属性都有值
@property (strong, nonatomic) NSString* uid;
@property (strong, nonatomic) NSString* phoneNO;
@property (strong, nonatomic) NSString* nameInPhone;
@property (strong, nonatomic) NSString* nameInYaoPao;
@property (strong, nonatomic) UIImage* avatarInPhone;
@property (strong, nonatomic) NSString* avatarUrlInYaoPao;
@property (assign, nonatomic) int status;//状态：0-还没用app，1-已经是好友，2-可添加好友，3-this加我为好友，4-我加this为好友,5-已添加,6-已忽略
@property (strong, nonatomic) NSString* verifyMessage;//验证信息，对应上面状态为3时，会有
@property (strong, nonatomic) NSString* sex;//1-男，2-女


- (id)initWithUid:(NSString*)uid1 phoneNO:(NSString*)phoneNO1 nameInPhone:(NSString*)nameInPhone1 nameInYaoPao:(NSString*)nameInYaoPao1 avatarInPhone:(UIImage*)avatarInPhone1 avatarUrlInYaoPao:(NSString*)avatarUrlInYaoPao1 status:(int)status1 verifyMessage:(NSString*)verifyMessage1 sex:(NSString*)sex1;
@end

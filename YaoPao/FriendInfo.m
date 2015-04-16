//
//  FriendInfo.m
//  YaoPao
//
//  Created by 张驰 on 15/4/10.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "FriendInfo.h"

@implementation FriendInfo

@synthesize uid;
@synthesize phoneNO;
@synthesize nameInPhone;
@synthesize nameInYaoPao;
@synthesize avatarInPhone;
@synthesize avatarUrlInYaoPao;
@synthesize status;
@synthesize verifyMessage;
@synthesize sex;
- (id)initWithUid:(NSString*)uid1 phoneNO:(NSString*)phoneNO1 nameInPhone:(NSString*)nameInPhone1 nameInYaoPao:(NSString*)nameInYaoPao1 avatarInPhone:(UIImage*)avatarInPhone1 avatarUrlInYaoPao:(NSString*)avatarUrlInYaoPao1 status:(int)status1 verifyMessage:(NSString*)verifyMessage1 sex:(NSString*)sex1{
    if(self)
    {
        self.uid = uid1;
        self.phoneNO = phoneNO1;
        self.nameInPhone = nameInPhone1;
        self.nameInYaoPao = nameInYaoPao1;
        self.avatarInPhone = avatarInPhone1;
        self.avatarUrlInYaoPao = avatarUrlInYaoPao1;
        self.status = status1;
        self.verifyMessage = verifyMessage1;
        self.sex = sex1;
    }
    
    return self;
}
@end

//
//  LoginDoneHandler.h
//  YaoPao
//
//  Created by 张驰 on 15/6/17.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNNetworkHandler.h"

@interface LoginDoneHandler : NSObject<resetGroupSettingDelegate,uploadADBookDelegate>

@property (assign ,nonatomic) int type;
- (void)doManyThingAfterLogin:(int)loginType;

@end

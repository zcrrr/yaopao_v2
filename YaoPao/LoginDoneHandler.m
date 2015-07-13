//
//  LoginDoneHandler.m
//  YaoPao
//
//  Created by 张驰 on 15/6/17.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "LoginDoneHandler.h"
#import "CNCloudRecord.h"
#import "FriendsHandler.h"
#import <AddressBook/AddressBook.h>
#import "CNUtil.h"

@implementation LoginDoneHandler
@synthesize type;

//1-注册，2-手动登录，3-自动登录，4-重置密码
- (void)doManyThingAfterLogin:(int)loginType{
    switch (loginType) {
        case 1:
            NSLog(@"注册成功后的操作---------");
            [CNUtil appendUserOperation:@"注册成功"];
            break;
        case 2:
            NSLog(@"手动登录成功后的操作---------");
            [CNUtil appendUserOperation:@"手动登录成功"];
            break;
        case 3:
            NSLog(@"自动登录成功后的操作---------");
            [CNUtil appendUserOperation:@"自动登录成功"];
            break;
        case 4:
            NSLog(@"重置密码成功后的操作---------");
            [CNUtil appendUserOperation:@"重置密码成功"];
            break;
            
        default:
            break;
    }
    self.type = loginType;
    //第一步,对已有记录进行处理
    NSLog(@"login step1:对已有记录进行处理------------");
    if(self.type != 3){
        [CNCloudRecord ClearRecordAfterUserLogin];
    }else{
        NSLog(@"自动登录不用处理");
    }
    //第二步，登录环信：
    NSLog(@"login step2:登录环信------------------");
    NSString* phoneNO = [kApp.userInfoDic objectForKey:@"phone"];
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:phoneNO password:phoneNO completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error && loginInfo) {
            NSLog(@"登录环信成功!!");
            [CNUtil appendUserOperation:@"登录环信成功"];
            kApp.isLoginHX = 1;
            [CNAppDelegate howManyMessageToRead];
            
        }else{
            NSLog(@"登录环信失败!!");
            [CNUtil appendUserOperation:@"登录环信失败了"];
            [self tryLoginHuanxinAgain];
        }
    } onQueue:nil];
    //同时进行第三步：
    [self loginDoneStep3];
}
- (void)tryLoginHuanxinAgain{
    NSLog(@"重试登录环信!!");
    [CNUtil appendUserOperation:@"重试登录环信"];
    NSString* phoneNO = [kApp.userInfoDic objectForKey:@"phone"];
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:phoneNO password:phoneNO completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error && loginInfo) {
            NSLog(@"登录环信成功!!");
            [CNUtil appendUserOperation:@"登录环信成功"];
            kApp.isLoginHX = 1;
            [CNAppDelegate howManyMessageToRead];
        }else{
            NSLog(@"登录环信失败!!");
            [CNUtil appendUserOperation:@"登录环信失败了"];
            [self tryLoginHuanxinAgain];
        }
    } onQueue:nil];
}
////第三步：重置跑团上报
- (void)loginDoneStep3{
    NSLog(@"login step3:重置跑团设置----------------");
    if(self.type == 1){//如果是注册，不用重置跑团
        NSLog(@"如果是注册则不用设置");
        [self loginDoneStep4];
        return;
    }
    NSString* uid = [NSString stringWithFormat:@"%@",[kApp.userInfoDic objectForKey:@"uid"]];
    NSMutableDictionary* param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:uid,@"uid",nil];
    kApp.networkHandler.delegate_resetGroupSetting = self;
    [kApp.networkHandler doRequest_resetGroupSetting:param];
}
- (void)resetGroupSettingGroupDidFailed:(NSString *)mes{
    [self loginDoneStep4];
}
- (void)resetGroupSettingGroupDidSuccess:(NSDictionary *)resultDic{
    [self loginDoneStep4];
}
//第四步：上传通讯录
- (void)loginDoneStep4{
    NSLog(@"login step4:检测上传通讯录----------------");
    [self checkNeedUploadAD];
}
- (void)checkNeedUploadAD{
    //无论如何先获取通讯录
    NSMutableString* phoneNOString = [NSMutableString stringWithString:@""];
    long long newestTime = 0;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if(addressBook == nil){
        return;
    }
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    int i = 0;
    int k = 0;
    for(i = 0; i < CFArrayGetCount(results); i++){
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        NSString *lastknow = [NSString stringWithFormat:@"%@",(__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty)];
        lastknow = [lastknow substringToIndex:18];
        //        NSLog(@"lastKnow is %@",lastknow);
        long long timestamp = [CNUtil getTimestampFromDate:lastknow];
        //        NSLog(@"timestamp is %llu",timestamp);
        if(timestamp > newestTime){
            newestTime = timestamp;
        }
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (k = 0; k<ABMultiValueGetCount(phones); k++)
        {
            CFTypeRef value = ABMultiValueCopyValueAtIndex(phones, k);
            NSString* phoneNO = (__bridge NSString*)value;
            phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
            if([phoneNO hasPrefix:@"+86"]){
                phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            }
            [phoneNOString appendString:phoneNO];
            [phoneNOString appendString:@","];
        }
    }
    if([phoneNOString hasSuffix:@","]){
        phoneNOString = [NSMutableString stringWithString:[phoneNOString substringToIndex:phoneNOString.length - 1]];
    }
    newestTime += 8*60*60;
//    NSLog(@"phoneNOString is %@",phoneNOString);
    NSLog(@"newestTime is %llu",newestTime);
    NSString* filePath = [CNPersistenceHandler getDocument:@"uploadAD.plist"];
    NSLog(@"filepath is %@",filePath);
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(dic == nil){//没提交过,提交
        [self uploadADBook:phoneNOString];
    }else{
        long long lastUploadTime = [[dic objectForKey:@"lastUploadTime"]longLongValue];
        if(newestTime > lastUploadTime){
            [self uploadADBook:phoneNOString];
        }else{
            NSLog(@"已经上传通讯录，且通讯录未发生变化");
            [self loginDoneStep5];
        }
    }
}
- (void)uploadADBook:(NSString*)phoneNOString{
    kApp.networkHandler.delegate_uploadADBook = self;
    [kApp.networkHandler doRequest_uploadADBook:phoneNOString];
}
- (void)uploadADDidFailed:(NSString *)mes{
    [self loginDoneStep5];
}
- (void)uploadADDidSuccess:(NSDictionary *)resultDic{
    NSString* filePath = [CNPersistenceHandler getDocument:@"uploadAD.plist"];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(dic == nil){//没提交过,提交
        dic = [[NSMutableDictionary alloc]init];
    }
    NSString* newestTimeString = [NSString stringWithFormat:@"%lli",[CNUtil getNowTimeDelta]];
    [dic setObject:newestTimeString forKey:@"lastUploadTime"];
    [dic writeToFile:filePath atomically:YES];
    [self loginDoneStep5];
}
- (void)loginDoneStep5{
    NSLog(@"login step5:开始同步记录----------------");
    if(self.type == 1){//如果是注册则不用同步
        NSLog(@"注册不用同步记录");
        return;
    }
    [CNAppDelegate popupWarningCloud:NO];
}
@end

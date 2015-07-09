//
//  CNCloudRecord.m
//  YaoPao
//
//  Created by zc on 15-1-15.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "CNCloudRecord.h"
#import "RunClass.h"
#import "CNNetworkHandler.h"
#import "SBJson.h"
#import "CNUtil.h"
#import "GCDAsyncUdpSocket.h"
#import "ASIHTTPRequest.h"


@implementation CNCloudRecord
@synthesize fileArray;
@synthesize addRecordArray;
@synthesize downLoadRecordArray;
@synthesize synTimeNew;
@synthesize udpSocket;
@synthesize startRequestTime;
@synthesize endRequestTime;
@synthesize deltaTimeArray;
@synthesize synTimeIndex;
@synthesize deltaMiliSecond;
@synthesize isSynServerTime;
@synthesize forCloud;
@synthesize stepDes;
@synthesize fileCount;
@synthesize userCancel;
@synthesize editImageAddArray;
@synthesize udpRes;
@synthesize isClouding;

+ (void)ClearRecordAfterUserLogin{
    NSString* uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"] intValue]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    //设置请求实体
    [request setEntity:entity];
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[kApp.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    for(RunClass* runclass in mutableFetchResult){
        if([runclass.uid isEqualToString:@""]){
            runclass.uid = uid;
        }else if(![runclass.uid isEqualToString:uid]){//uid不相等
            [kApp.managedObjectContext deleteObject:runclass];
            [self deletePlistRecord:runclass];
        }
    }
    NSLog(@"存记录2");
    if ([kApp.managedObjectContext save:&error]) {
        NSLog(@"Error:%@,%@",error,[error userInfo]);
    }
    //然后查看同步记录文件，将uid赋值或者重置文件
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    NSString* uid_file = [cloudDiary objectForKey:@"uid"];
    if([uid_file isEqualToString:@""]){//里面的记录还尚未属于任何用户
        [cloudDiary setObject:uid forKey:@"uid"];
        [cloudDiary writeToFile:filePath_cloud atomically:YES];
    }else if(![uid_file isEqualToString:uid]){//和文件中uid不相等，属于别的用户，重置文件
        [cloudDiary setObject:@"0" forKey:@"synTime"];//同步时间
        [cloudDiary setObject:uid forKey:@"uid"];
        NSMutableArray* deleteArray = [[NSMutableArray alloc]init];
        [cloudDiary setObject:deleteArray forKey:@"deleteArray"];
        
        NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
        [cloudDiary writeToFile:filePath_cloud atomically:YES];
    }
}
+ (void)deletePlistRecord:(RunClass*)runclass{
    //更新plist中个人总记录：
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
        [record_dic setObject:@"0" forKey:@"total_score"];
    }
    float total_distance = [[record_dic objectForKey:@"total_distance"]floatValue];
    int total_count = [[record_dic objectForKey:@"total_count"]intValue];
    int total_time = [[record_dic objectForKey:@"total_time"]intValue];
    int total_score = [[record_dic objectForKey:@"total_score"]intValue];
    total_distance -= [runclass.distance floatValue];
    total_count--;
    total_time -= [runclass.duration intValue]/1000;
    total_score -= [runclass.score intValue];
    if(total_count == 0){
        total_time = 0;
        total_distance = 0;
        total_score = 0;
    }
    [record_dic setObject:[NSString stringWithFormat:@"%f",total_distance] forKey:@"total_distance"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_count] forKey:@"total_count"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_time] forKey:@"total_time"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_score] forKey:@"total_score"];
    [record_dic writeToFile:filePath_record atomically:YES];
    
    //再删除文件
    if(![runclass.clientBinaryFilePath isEqualToString:@""]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:runclass.clientBinaryFilePath];
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if(blHave){
            [CNPersistenceHandler DeleteSingleFile:filePath];
        }
    }
    if(![runclass.clientImagePaths isEqualToString:@""]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:runclass.clientImagePaths];
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if(blHave){
            [CNPersistenceHandler DeleteSingleFile:filePath];
        }
    }
    if(![runclass.clientImagePathsSmall isEqualToString:@""]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:runclass.clientImagePathsSmall];
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if(blHave){
            [CNPersistenceHandler DeleteSingleFile:filePath];
        }
    }
}
+ (void)addPlistRecord:(RunClass*)runclass{
    //更新plist中个人总记录：
    NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
    NSMutableDictionary* record_dic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_record];
    if(record_dic == nil){
        record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
        [record_dic setObject:@"0" forKey:@"total_score"];
    }
    float total_distance = [[record_dic objectForKey:@"total_distance"]floatValue];
    int total_count = [[record_dic objectForKey:@"total_count"]intValue];
    int total_time = [[record_dic objectForKey:@"total_time"]intValue];
    int total_score = [[record_dic objectForKey:@"total_score"]intValue];
    total_distance += [runclass.distance floatValue];
    total_count++;
    total_time += [runclass.duration intValue]/1000;
    total_score += [runclass.score intValue];
    [record_dic setObject:[NSString stringWithFormat:@"%f",total_distance] forKey:@"total_distance"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_count] forKey:@"total_count"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_time] forKey:@"total_time"];
    [record_dic setObject:[NSString stringWithFormat:@"%i",total_score] forKey:@"total_score"];
    [record_dic writeToFile:filePath_record atomically:YES];
}
+ (void)deleteOneRecord:(RunClass*)runclass{
    [self deletePlistRecord:runclass];
    NSError* error=nil;
    [kApp.managedObjectContext deleteObject:runclass];
    NSLog(@"存记录3");
    if ([kApp.managedObjectContext save:&error]) {
        NSLog(@"Error:%@,%@",error,[error userInfo]);
    }
}
+ (void)deleteAllRecordWhenFirstInstall{
    NSString* filePath = [CNPersistenceHandler getDocument:@"updateApp.plist"];
    NSLog(@"filePath is %@",filePath);
    NSMutableDictionary* updateApp = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(updateApp == nil){//第一次安装
        NSLog(@"第一次升级安装，删除全部已有记录");
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        //设置要检索哪种类型的实体对象
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
        //设置请求实体
        [request setEntity:entity];
        NSError *error = nil;
        NSMutableArray *mutableFetchResult = [[kApp.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        if (mutableFetchResult == nil) {
            NSLog(@"Error: %@,%@",error,[error userInfo]);
        }
        for(RunClass* runclass in mutableFetchResult){
            [kApp.managedObjectContext deleteObject:runclass];
        }
        NSLog(@"存记录4");
        if ([kApp.managedObjectContext save:&error]) {
            NSLog(@"Error:%@,%@",error,[error userInfo]);
        }
        NSString* filePath_record = [CNPersistenceHandler getDocument:@"all_record.plist"];
        NSMutableDictionary* record_dic = [[NSMutableDictionary alloc]init];
        [record_dic setObject:@"0" forKey:@"total_distance"];
        [record_dic setObject:@"0" forKey:@"total_count"];
        [record_dic setObject:@"0" forKey:@"total_time"];
        [record_dic setObject:@"0" forKey:@"total_score"];
        [record_dic writeToFile:filePath_record atomically:YES];
        NSMutableDictionary* updateApp = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1",@"hasDelete",nil];
        [updateApp writeToFile:filePath atomically:YES];
        
        [CNCloudRecord createCloudDiary:0];
    }
}
+ (void)createCloudDiary:(long long)synTime{
    //创建同步文件：
    NSMutableDictionary* cloudDiary = [[NSMutableDictionary alloc]init];
    [cloudDiary setObject:[NSString stringWithFormat:@"%lli",synTime] forKey:@"synTime"];//同步时间
    NSString* uid;
    if(kApp.userInfoDic == nil){
        uid = @"";
    }else{
        uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
    }
    [cloudDiary setObject:uid forKey:@"uid"];
    NSMutableArray* deleteArray = [[NSMutableArray alloc]init];
    [cloudDiary setObject:deleteArray forKey:@"deleteArray"];
    NSMutableArray* editImageLaterArray = [[NSMutableArray alloc]init];
    [cloudDiary setObject:editImageLaterArray forKey:@"editImageLaterArray"];
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    [cloudDiary writeToFile:filePath_cloud atomically:YES];
}
- (void)startCloud{
    if([CNUtil canNetWork]){
        if(self.isSynServerTime){
            [self cloud_step0];
        }else{
            self.forCloud = 1;
            [self synTimeWithServer];
            self.stepDes = [NSString stringWithFormat:@"正在和服务器同步时间"];
        }
    }else{
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请检查网络再同步记录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)cloud_step0{
    //第一步
    if(kApp.isLogin != 1){//是否登录
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请先登录再同步记录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        self.stepDes = @"请先登录";
        return;
    }
    self.downLoadRecordArray = [[NSMutableArray alloc]init];
    self.addRecordArray = [[NSMutableArray alloc]init];
    self.fileArray = [[NSMutableArray alloc]init];
    self.editImageAddArray = [[NSMutableArray alloc]init];
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    self.userCancel = NO;
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    //第一步：将uid赋值
    NSString* uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
    [cloudDiary setObject:uid forKey:@"uid"];
    [cloudDiary writeToFile:filePath_cloud atomically:YES];
    NSLog(@"------------------第一步：赋值uid:%@",uid);
    //第二步：上传或者删除需要的图片
    NSArray* arrayTemp = [cloudDiary objectForKey:@"editImageLaterArray"];
    if(arrayTemp == nil || [arrayTemp count] <1){//没有需要上传的图片或删除的图片
        [self cloud_step2];
    }else{
        //对arrayTemp进行处理得到删除字符串以及添加数组
        NSMutableArray* deleteImageArray = [[NSMutableArray alloc]init];
        for(NSString* oneLine in arrayTemp){
            NSArray* oneLineArray = [oneLine componentsSeparatedByString:@"-"];
            if([[oneLineArray objectAtIndex:0] isEqualToString:@"add"]){//添加
                [self.editImageAddArray addObject:oneLine];
            }else{//删除
                [deleteImageArray addObject:[oneLineArray objectAtIndex:1]];
                [self deleteOneLineToPlist:oneLine];
            }
        }
        if([deleteImageArray count] == 0){
            NSLog(@"不用删除图片，直接上传图片");
            [self cloud_step1];
        }else{
            //先删除
            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            NSString* jsonString = [jsonWriter stringWithObject:deleteImageArray];
            NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
            [params setObject:uid forKey:@"uid"];
            [params setObject:jsonString forKey:@"imgpaths"];
            kApp.networkHandler.delegate_deleteOneFile = self;
            [kApp.networkHandler doRequest_deleteOneFile:params];
            NSLog(@"删除后期修改的图片");
            self.stepDes = @"删除后期修改的图片";
        }
    }
}
- (void)deleteOneLineToPlist:(NSString*)oneLine{
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    NSMutableArray* editImageLaterArray = [cloudDiary objectForKey:@"editImageLaterArray"];
    [editImageLaterArray removeObject:oneLine];
    [cloudDiary setObject:editImageLaterArray forKey:@"editImageLaterArray"];
    [cloudDiary writeToFile:filePath_cloud atomically:YES];
}
- (void)deleteOneFileDidFailed:(NSString *)mes{
    [self cloudFailed:@"删除图片文件失败"];
}
- (void)deleteOneFileDidSuccess{
    NSLog(@"删除图片文件成功");
    
    [self cloud_step1];
}
- (void)cloud_step1{
    if([self.editImageAddArray count] == 0){//无需上传图片
        NSLog(@"无需上传图片");
        [self cloud_step2];
        return;
    }
    self.fileCount = (int)[self.editImageAddArray count];
    [self uploadOneImage];
}
- (void)uploadOneImage{
    if(self.userCancel){
        [self cloudFailed:@"用户取消"];
        return;
    }
    NSString* oneAction = [self.editImageAddArray firstObject];
    NSArray* temparray = [oneAction componentsSeparatedByString:@"-"];
    NSString* uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[temparray objectAtIndex:1]];
    NSLog(@"filePath is %@",filePath);
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSData* binaryData;
    if(blHave){
        binaryData = [NSData dataWithContentsOfFile:filePath];
        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
        [params setObject:uid forKey:@"uid"];
        [params setObject:@"2" forKey:@"type"];
        [params setObject:[NSString stringWithFormat:@"%@_%@",uid,[temparray objectAtIndex:2]] forKey:@"rid"];
        [params setObject:binaryData forKey:@"avatar"];
        kApp.networkHandler.delegate_cloudData = self;
        [kApp.networkHandler doRequest_cloudData:params];
        self.stepDes = [NSString stringWithFormat:@"正在上传后期修改的图片%i/%i",(self.fileCount-(int)[self.editImageAddArray count]+1),self.fileCount];
    }else{
        binaryData = nil;
        [self deleteOneLineToPlist:oneAction];
        [self.editImageAddArray removeObjectAtIndex:0];
        if([self.editImageAddArray count]>0){
            [self uploadOneImage];
        }else{//文件全部上传完毕，下一步
            NSLog(@"图片全部上传完毕");
            [self cloud_step2];
        }
    }
}
- (void)cloud_step2{
    NSLog(@"------------------第三步：删除记录");
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    //第一步：将uid赋值
    NSString* uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
    NSArray* deleteArray = [cloudDiary objectForKey:@"deleteArray"];
    if(deleteArray == nil||[deleteArray count]<1){//不需要删除
        NSLog(@"不需要删除");
        [self cloud_step3];
    }else{
        NSMutableArray* tempArray = [[NSMutableArray alloc]init];
        NSLog(@"需要删除记录个数:%i",(int)[deleteArray count]);
        for(int i=0;i<[deleteArray count];i++){
            [tempArray addObject:[NSString stringWithFormat:@"%@_%@",uid,[deleteArray objectAtIndex:i]]];
        }
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        NSString* deleteArrayJSON = [jsonWriter stringWithObject:tempArray];
        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
        [params setObject:uid forKey:@"uid"];
        [params setObject:deleteArrayJSON forKey:@"delrids"];
        kApp.networkHandler.delegate_deleteRecord = self;
        [kApp.networkHandler doRequest_DeleteRecord:params];
        self.stepDes = [NSString stringWithFormat:@"正在删除%i条记录",(int)[deleteArray count]];
    }
}
- (NSMutableArray*)getRecordsByFilter:(NSString*)filter{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
    //设置请求实体
    [request setEntity:entity];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:filter];
    [request setPredicate:predicate];
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[kApp.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    return mutableFetchResult;
}
- (void)cloud_step3{//上传文件
    if(self.userCancel){
        [self cloudFailed:@"用户取消"];
        return;
    }
    NSLog(@"------------------第三步：上传文件");
    //首先过滤哪些才是新纪录（时间大于generateTime，或者时间为0，离线下跑步生成时间为0）
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    long long synTime = [[cloudDiary objectForKey:@"synTime"] longLongValue];
    NSString* filter = [NSString stringWithFormat:@"generateTime>%lli||generateTime==0",synTime];
    NSMutableArray* mutableFetchResult = [self getRecordsByFilter:filter];
    if (mutableFetchResult==nil||[mutableFetchResult count] == 0) {
        NSLog(@"没有新增记录，跳过第三步上传文件步骤");
        [self cloud_step4];
    }else{
        self.stepDes = @"正在查找要上传的文件";
        self.addRecordArray = mutableFetchResult;
        NSLog(@"新增记录个数：%i",(int)[mutableFetchResult count]);
        for(int i = 0;i<[mutableFetchResult count];i++){
            RunClass* runclass = [mutableFetchResult objectAtIndex:i];
            if([runclass.serverBinaryFilePath isEqualToString:@""] && ![runclass.clientBinaryFilePath isEqualToString:@""]){//未上传服务器，并且二进制客户端路径有值
                [self.fileArray addObject:[NSString stringWithFormat:@"%i,%@,3,%@",i,runclass.clientBinaryFilePath,runclass.rid]];//记录index_二进制文件路径_文件类型_rid
            }
            if([runclass.serverImagePaths isEqualToString:@""] && ![runclass.clientImagePaths isEqualToString:@""]){
                NSArray* imagePaths = [runclass.clientImagePaths componentsSeparatedByString:@"|"];
                for(int j=0;j<[imagePaths count];j++){
                    [self.fileArray addObject:[NSString stringWithFormat:@"%i,%@,2,%@",i,[imagePaths objectAtIndex:j],runclass.rid]];//记录index_二进制文件路径_文件类型
                }
                
            }
            if([runclass.generateTime intValue] == 0){//当时离线保存
                runclass.generateTime = [NSNumber numberWithLongLong:([CNUtil getNowTime1000]+kApp.cloudManager.deltaMiliSecond)];
            }
            if([runclass.updateTime intValue] == 0){//当时离线保存
                runclass.updateTime = [NSNumber numberWithLongLong:([CNUtil getNowTime1000]+kApp.cloudManager.deltaMiliSecond)];
            }
        }
        self.fileCount = (int)[self.fileArray count];
        NSLog(@"需上传文件个数：%i",self.fileCount);
        if([self.fileArray count]>0){
            [self uploadOneFile];
        }else{
            NSLog(@"有新增文件，但是相关文件都已上传，到第四步");
            [self cloud_step4];
        }
    }
}
- (void)uploadOneFile{
    if(self.userCancel){
        [self cloudFailed:@"用户取消"];
        return;
    }
    NSLog(@"上传一个文件");
    NSString* fileString = [self.fileArray firstObject];
    NSArray* tempArray = [fileString componentsSeparatedByString:@","];
    NSString* uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[tempArray objectAtIndex:1]];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSData* binaryData;
    if(blHave){
        binaryData = [NSData dataWithContentsOfFile:filePath];
    }else{
        binaryData = nil;
    }
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:uid forKey:@"uid"];
    [params setObject:[tempArray objectAtIndex:2] forKey:@"type"];
    [params setObject:[NSString stringWithFormat:@"%@_%@",uid,[tempArray objectAtIndex:3]] forKey:@"rid"];
    [params setObject:binaryData forKey:@"avatar"];
    kApp.networkHandler.delegate_cloudData = self;
    [kApp.networkHandler doRequest_cloudData:params];
    self.stepDes = [NSString stringWithFormat:@"正在上传记录相关文件%i/%i",(self.fileCount-(int)[self.fileArray count]+1),self.fileCount];
}
- (void)cloud_step4{//上传记录
    if(self.userCancel){
        [self cloudFailed:@"用户取消"];
        return;
    }
    NSLog(@"------------------第四步：上传记录");
    NSString* jsonString_add = [self getJsonStringFromArray:self.addRecordArray];
    //更新的记录
    NSString* filePath_cloud = [CNPersistenceHandler getDocument:@"cloudDiary.plist"];
    NSMutableDictionary* cloudDiary = [NSMutableDictionary dictionaryWithContentsOfFile:filePath_cloud];
    long long synTime = [[cloudDiary objectForKey:@"synTime"] longLongValue];
    NSString* filter = [NSString stringWithFormat:@"generateTime<%lli&&(updateTime>%lli||updateTime==0)",synTime,synTime];
    NSMutableArray* updateRecordArray = [self getRecordsByFilter:filter];
    for(RunClass* runclass in updateRecordArray){
        if([runclass.updateTime intValue] == 0){
            runclass.updateTime = [NSNumber numberWithLongLong:([CNUtil getNowTime1000]+kApp.cloudManager.deltaMiliSecond)];
        }
    }
    NSError *error = nil;
    NSLog(@"存记录5");
    if ([kApp.managedObjectContext save:&error]) {
        NSLog(@"Error:%@,%@",error,[error userInfo]);
    }
    NSString* jsonString_update = [self getJsonStringFromArray:updateRecordArray];
    NSString* uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:uid forKey:@"uid"];
    [params setObject:[NSString stringWithFormat:@"%lli",synTime] forKey:@"synTime"];
    [params setObject:[NSString stringWithFormat:@"%@",jsonString_add] forKey:@"genrecords"];
    [params setObject:[NSString stringWithFormat:@"%@",jsonString_update] forKey:@"uprecords"];
    kApp.networkHandler.delegate_uploadRecord = self;
    [kApp.networkHandler doRequest_uploadRecord:params];
    self.stepDes = [NSString stringWithFormat:@"正在上传记录"];
}
- (NSString*)getJsonStringFromArray:(NSMutableArray*)array{
    NSMutableArray* jsonArray = [[NSMutableArray alloc]init];
    NSString* uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
    for(int i=0;i<[array count];i++){
        RunClass* runclass = [array objectAtIndex:i];
        NSMutableDictionary* recordData = [[NSMutableDictionary alloc]init];
        [recordData setObject:runclass.averageHeart forKey:@"averageHeart"];
        [recordData setObject:runclass.dbVersion forKey:@"dbVersion"];
        [recordData setObject:runclass.distance forKey:@"distance"];
        [recordData setObject:runclass.duration forKey:@"duration"];
        [recordData setObject:runclass.feeling forKey:@"feeling"];
        [recordData setObject:runclass.generateTime forKey:@"generateTime"];
        [recordData setObject:runclass.gpsCount forKey:@"gpsCount"];
        [recordData setObject:runclass.gpsString forKey:@"gpsString"];
        [recordData setObject:runclass.heat forKey:@"heat"];
        [recordData setObject:runclass.howToMove forKey:@"howToMove"];
        [recordData setObject:runclass.isMatch forKey:@"isMatch"];
        [recordData setObject:runclass.jsonParam forKey:@"jsonParam"];
        [recordData setObject:runclass.kmCount forKey:@"kmCount"];
        [recordData setObject:runclass.maxHeart forKey:@"maxHeart"];
        [recordData setObject:runclass.mileCount forKey:@"mileCount"];
        [recordData setObject:runclass.minCount forKey:@"minCount"];
        [recordData setObject:runclass.remark forKey:@"remark"];
        [recordData setObject:[NSString stringWithFormat:@"%@_%@",uid,runclass.rid] forKey:@"rid"];
        [recordData setObject:runclass.runway forKey:@"runway"];
        [recordData setObject:runclass.score forKey:@"score"];
        [recordData setObject:runclass.secondPerKm forKey:@"secondPerKm"];
        [recordData setObject:runclass.serverBinaryFilePath forKey:@"serverBinaryFilePath"];
        //这里加一个冗余，删除serverImagePaths中的placeholder再上传
        [recordData setObject:[self deletePlaceholderInString:runclass.serverImagePaths] forKey:@"serverImagePaths"];
        [recordData setObject:[self deletePlaceholderInString:runclass.serverImagePathsSmall] forKey:@"serverImagePathsSmall"];
        [recordData setObject:runclass.startTime forKey:@"startTime"];
        [recordData setObject:runclass.targetType forKey:@"targetType"];
        [recordData setObject:runclass.targetValue forKey:@"targetValue"];
        [recordData setObject:runclass.temp forKey:@"temp"];
        [recordData setObject:uid forKey:@"uid"];
        [recordData setObject:runclass.updateTime forKey:@"updateTime"];
        [recordData setObject:runclass.weather forKey:@"weather"];
        [jsonArray addObject:recordData];
    }
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    NSString* jsonString = [jsonWriter stringWithObject:jsonArray];
    return jsonString;
}
- (void)deleteRecordDidFailed:(NSString *)mes{
    [self cloudFailed:@"删除记录失败"];
}
- (void)deleteRecordDidSuccess:(NSDictionary *)resultDic{
    NSLog(@"删除成功");
    [self cloud_step3];
}
- (void)cloudDataDidFailed:(NSString *)mes{
    [self cloudFailed:@"上传文件失败"];
}
- (void)cloudDataDidSuccess:(NSDictionary *)resultDic{
    if(self.userCancel){
        [self cloudFailed:@"用户取消"];
        return;
    }
    if([self.editImageAddArray count] == 0){//说明此处上传文件是后面的上传文件
        NSString* fileString = [self.fileArray firstObject];
        NSArray* tempArray = [fileString componentsSeparatedByString:@","];
        int index = [[tempArray objectAtIndex:0]intValue];
        int type = [[tempArray objectAtIndex:2]intValue];
        RunClass* runclass = [self.addRecordArray objectAtIndex:index];
        if(type == 2){
            if([runclass.serverImagePaths isEqualToString:@""]){
                runclass.serverImagePaths = [resultDic objectForKey:@"serverImagePaths"];
            }else{
                runclass.serverImagePaths = [NSString stringWithFormat:@"%@|%@",runclass.serverImagePaths,[resultDic objectForKey:@"serverImagePaths"]];
            }
            if([runclass.serverImagePathsSmall isEqualToString:@""]){
                runclass.serverImagePathsSmall = [resultDic objectForKey:@"serverImagePathsSmall"];
            }else{
                runclass.serverImagePathsSmall = [NSString stringWithFormat:@"%@|%@",runclass.serverImagePathsSmall,[resultDic objectForKey:@"serverImagePathsSmall"]];
            }
        }else if(type == 3){
            runclass.serverBinaryFilePath = [resultDic objectForKey:@"serverBinaryFilePath"];
        }
        NSError *error = nil;
        NSLog(@"存记录6");
        if ([kApp.managedObjectContext save:&error]) {
            NSLog(@"Error:%@,%@",error,[error userInfo]);
        }
        [self.fileArray removeObjectAtIndex:0];
        if([self.fileArray count]>0){
            [self uploadOneFile];
        }else{//文件全部上传完毕，下一步
            NSLog(@"文件全部上传完毕");
            [self cloud_step4];
        }
    }else{//前面的上传图片
        NSString* fileString = [self.editImageAddArray firstObject];
        NSArray* tempArray = [fileString componentsSeparatedByString:@"-"];
        NSString* rid = [tempArray objectAtIndex:2];
        NSString* filter = [NSString stringWithFormat:@"rid==%@",rid];
        NSMutableArray* mutableFetchResult = [self getRecordsByFilter:filter];
        if(mutableFetchResult != nil && [mutableFetchResult count]>0){//如果已经存在rid，说明是要更新的记录
            NSLog(@"存在一个已有的记录");
            RunClass* runclass = [mutableFetchResult objectAtIndex:0];
            NSMutableArray* imagePathsList = [[NSMutableArray alloc]initWithArray:[runclass.serverImagePaths componentsSeparatedByString:@"|"]];
            runclass.serverImagePaths = [self replacePlaceHolder:imagePathsList :[resultDic objectForKey:@"serverImagePaths"]];
            NSLog(@"runclass.serverImagePaths is %@",runclass.serverImagePaths);
            NSMutableArray* imagePathsListSmall = [[NSMutableArray alloc]initWithArray:[runclass.serverImagePathsSmall componentsSeparatedByString:@"|"]];
            runclass.serverImagePathsSmall = [self replacePlaceHolder:imagePathsListSmall :[resultDic objectForKey:@"serverImagePathsSmall"]];
        }
        NSError *error = nil;
        if ([kApp.managedObjectContext save:&error]) {
            NSLog(@"Error:%@,%@",error,[error userInfo]);
        }
        [self deleteOneLineToPlist:fileString];
        [self.editImageAddArray removeObjectAtIndex:0];
        if([self.editImageAddArray count]>0){
            [self uploadOneImage];
        }else{//文件全部上传完毕，下一步
            NSLog(@"图片全部上传完毕");
            [self cloud_step2];
        }
    }
}
- (void)uploadRecordDidFailed:(NSString *)mes{
    [self cloudFailed:@"上传记录失败"];
}
- (void)uploadRecordDidSuccess:(NSDictionary *)resultDic{
    NSLog(@"上传记录成功");
    if(self.userCancel){
        [self cloudFailed:@"用户取消"];
        return;
    }
    NSArray* delrids = [resultDic objectForKey:@"delrids"];
    NSArray* downrecordIDs = [resultDic objectForKey:@"downrecordIDs"];
    self.synTimeNew = [[resultDic objectForKey:@"synTimeNew"]longLongValue];
    //先删除：
    NSLog(@"删除文件，个数:%i",(int)[delrids count]);
    int i = 0;
    NSError* error=nil;
    self.stepDes = [NSString stringWithFormat:@"正在删除本地记录:共%i条",(int)[delrids count]];
    for(i=0;i<[delrids count];i++){
        NSString* rid = [[[delrids objectAtIndex:i]componentsSeparatedByString:@"_"] objectAtIndex:1];
        NSString* filter = [NSString stringWithFormat:@"rid=%@",rid];
        NSMutableArray* deleteRecordArray = [self getRecordsByFilter:filter];
        for(RunClass* runclass in deleteRecordArray){
            [kApp.managedObjectContext deleteObject:runclass];
            [CNCloudRecord deletePlistRecord:runclass];
        }
        NSLog(@"存记录7");
        if ([kApp.managedObjectContext save:&error]) {
            NSLog(@"Error:%@,%@",error,[error userInfo]);
        }
    }
    //再下载
    NSLog(@"下载文件，个数:%i",(int)[downrecordIDs count]);
    if([downrecordIDs count]>0){
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        NSString* jsonString = [jsonWriter stringWithObject:downrecordIDs];
        NSString* uid = [NSString stringWithFormat:@"%i",[[kApp.userInfoDic objectForKey:@"uid"]intValue]];
        NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
        [params setObject:uid forKey:@"uid"];
        [params setObject:jsonString forKey:@"downrecordIDs"];
        kApp.networkHandler.delegate_downloadRecord = self;
        [kApp.networkHandler doRequest_downloadRecord:params];
        self.stepDes = [NSString stringWithFormat:@"正在下载记录"];
    }else{
        [self cloudSuccess];
    }
}
- (void)downloadRecordDidFailed:(NSString *)mes{
    [self cloudFailed:@"下载记录失败"];
}
- (void)downloadRecordDidSuccess:(NSDictionary *)resultDic{
    if(self.userCancel){
        [self cloudFailed:@"用户取消"];
        return;
    }
    NSArray* records = [resultDic objectForKey:@"downrecords"];
    for(int i=0;i<[records count];i++){
        NSDictionary* dic = [records objectAtIndex:i];
        NSString* rid = [[[dic objectForKey:@"rid"]componentsSeparatedByString:@"_"]objectAtIndex:1];
        NSString* filter = [NSString stringWithFormat:@"rid==%@",rid];
        NSMutableArray* mutableFetchResult = [self getRecordsByFilter:filter];
        if(mutableFetchResult != nil && [mutableFetchResult count]>0){//如果已经存在rid，说明是要更新的记录、先删除
            NSLog(@"存在一个已有的记录");
            RunClass* runClass = [mutableFetchResult objectAtIndex:0];
            [kApp.managedObjectContext deleteObject:runClass];
            [CNCloudRecord deletePlistRecord:runClass];
        }
        
        RunClass * runClass  = [NSEntityDescription insertNewObjectForEntityForName:@"RunClass" inManagedObjectContext:kApp.managedObjectContext];
        runClass.averageHeart = [dic objectForKey:@"averageHeart"];
        runClass.clientBinaryFilePath = @"";
        runClass.clientImagePaths = @"";
        runClass.clientImagePathsSmall = @"";
        runClass.dbVersion = [dic objectForKey:@"dbVersion"];
        runClass.distance = [dic objectForKey:@"distance"];
        runClass.duration = [dic objectForKey:@"duration"];
        runClass.feeling = [dic objectForKey:@"feeling"];
        runClass.generateTime = [dic objectForKey:@"generateTime"];
        runClass.gpsCount = [dic objectForKey:@"gpsCount"];
        runClass.gpsString = [dic objectForKey:@"gpsString"];
        runClass.heat = [dic objectForKey:@"heat"];
        runClass.howToMove = [dic objectForKey:@"howToMove"];
        runClass.isMatch = [dic objectForKey:@"isMatch"];
        runClass.jsonParam = [dic objectForKey:@"jsonParam"];
        runClass.kmCount = [dic objectForKey:@"kmCount"];
        runClass.maxHeart = [dic objectForKey:@"maxHeart"];
        runClass.mileCount = [dic objectForKey:@"mileCount"];
        runClass.minCount = [dic objectForKey:@"minCount"];
        runClass.remark = [dic objectForKey:@"remark"];
        runClass.rid = [[[dic objectForKey:@"rid"]componentsSeparatedByString:@"_"]objectAtIndex:1];
        runClass.runway = [dic objectForKey:@"runway"];
        runClass.score = [dic objectForKey:@"score"];
        runClass.secondPerKm = [dic objectForKey:@"secondPerKm"];
        runClass.serverBinaryFilePath = [dic objectForKey:@"serverBinaryFilePath"];
        runClass.serverImagePaths = [dic objectForKey:@"serverImagePaths"];
        runClass.serverImagePathsSmall = [dic objectForKey:@"serverImagePathsSmall"];
        runClass.startTime = [dic objectForKey:@"startTime"];
        runClass.targetType = [dic objectForKey:@"targetType"];
        runClass.targetValue = [dic objectForKey:@"targetValue"];
        runClass.temp = [dic objectForKey:@"temp"];
        runClass.uid = [dic objectForKey:@"uid"];
        runClass.updateTime = [dic objectForKey:@"updateTime"];
        runClass.weather = [dic objectForKey:@"weather"];
        [self.downLoadRecordArray addObject:runClass];
        if(![runClass.serverBinaryFilePath isEqualToString:@""]){
            [self.fileArray addObject:[NSString stringWithFormat:@"%i,%@,%@,3",(int)[self.downLoadRecordArray count]-1,runClass.rid,runClass.serverBinaryFilePath]];
        }
        if(![runClass.serverImagePaths isEqualToString:@""]){
            NSArray* imagePaths = [runClass.serverImagePaths componentsSeparatedByString:@"|"];
            for(int j=0;j<[imagePaths count];j++){
                [self.fileArray addObject:[NSString stringWithFormat:@"%i,%@,%@,21",(int)[self.downLoadRecordArray count]-1,runClass.rid,[imagePaths objectAtIndex:j]]];
            }
        }
        if(![runClass.serverImagePathsSmall isEqualToString:@""]){
            NSArray* imagePaths = [runClass.serverImagePathsSmall componentsSeparatedByString:@"|"];
            for(int j=0;j<[imagePaths count];j++){
                [self.fileArray addObject:[NSString stringWithFormat:@"%i,%@,%@,22",(int)[self.downLoadRecordArray count]-1,runClass.rid,[imagePaths objectAtIndex:j]]];
            }
        }
    }
    self.fileCount = [self.fileArray count];
    [self downloadfile];
}
- (void)downloadfile{
    if(self.userCancel){
        for(RunClass* runclass in self.downLoadRecordArray){
            [kApp.managedObjectContext deleteObject:runclass];
        }
        [self cloudFailed:@"用户取消"];
        return;
    }
    if([self.fileArray count] == 0){//刚开始下载就为0，说明本次同步只有更新，没有新增
        NSError *error = nil;
        NSLog(@"存记录8");
        if ([kApp.managedObjectContext save:&error]) {
        }else{
            [self cloudFailed:@"存储下载记录失败"];
            return;
        }
        [self cloudSuccess];
        return;
    }
    NSString* fileString = [self.fileArray firstObject];
    NSString* str_url = [NSString stringWithFormat:@"%@%@",kApp.imageurl,[[fileString componentsSeparatedByString:@","]objectAtIndex:2]];
    kApp.networkHandler.delegate_downloadOneFile = self;
    [kApp.networkHandler doRequest_downloadOneFile:str_url];
    self.stepDes = [NSString stringWithFormat:@"正在下载记录相关文件%i/%i",(self.fileCount-(int)[self.fileArray count]+1),self.fileCount];
}
- (void)downloadOneFileDidFailed:(NSString *)mes{
    [self cloudFailed:@"下载记录文件失败"];
}
- (void)downloadOneFileDidSuccess:(NSData *)data{
    if(self.userCancel){
        [self cloudFailed:@"用户取消"];
        
        return;
    }
    NSString* fileString = [self.fileArray firstObject];
    long long time = [[[fileString componentsSeparatedByString:@","]objectAtIndex:1] longLongValue]/1000;
    int index = [[[fileString componentsSeparatedByString:@","]objectAtIndex:0] intValue];
    int type = [[[fileString componentsSeparatedByString:@","]objectAtIndex:3] intValue];
    //同步下载文件并保存
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[CNUtil getYearMonth:time]];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    RunClass* runClass = [self.downLoadRecordArray objectAtIndex:index];
    if(type == 21){//大图
        //大图
        int hasCount = (int)[[runClass.clientImagePaths componentsSeparatedByString:@"|"] count];
        if([runClass.clientImagePaths isEqualToString:@""]){
            hasCount = 0;
        }
        NSString *bigImageFile = [NSString stringWithFormat:@"%@/%lli_%i_big.jpg",path,time,hasCount];
        [data writeToFile:bigImageFile atomically:YES];
        NSString* thisImagePath = [NSString stringWithFormat:@"%@/%lli_%i_big.jpg",[CNUtil getYearMonth:time],time,hasCount];
        if([runClass.clientImagePaths isEqualToString:@""]){
            runClass.clientImagePaths = thisImagePath;
        }else{
            runClass.clientImagePaths = [NSString stringWithFormat:@"%@|%@",runClass.clientImagePaths,thisImagePath];
        }
        
    }else if(type == 22){
        //小图
        int hasCount = (int)[[runClass.clientImagePathsSmall componentsSeparatedByString:@"|"] count];
        if([runClass.clientImagePathsSmall isEqualToString:@""]){
            hasCount = 0;
        }
        NSString *bigImageFile = [NSString stringWithFormat:@"%@/%lli_%i_small.jpg",path,time,hasCount];
        [data writeToFile:bigImageFile atomically:YES];
        NSString* thisImagePath = [NSString stringWithFormat:@"%@/%lli_%i_small.jpg",[CNUtil getYearMonth:time],time,hasCount];
        if([runClass.clientImagePathsSmall isEqualToString:@""]){
            runClass.clientImagePathsSmall = thisImagePath;
        }else{
            runClass.clientImagePathsSmall = [NSString stringWithFormat:@"%@|%@",runClass.clientImagePathsSmall,thisImagePath];
        }
    }else if(type == 3){
        //二进制文件
        NSString *binarayFile = [NSString stringWithFormat:@"%@/%lli.yaopao",path,time];
        [data writeToFile:binarayFile atomically:YES];
        runClass.clientBinaryFilePath = [NSString stringWithFormat:@"%@/%lli.yaopao",[CNUtil getYearMonth:time],time];
    }
    [self.fileArray removeObjectAtIndex:0];
    if([self.fileArray count] > 0){
        [self downloadfile];
    }else{
        NSError *error = nil;
        NSLog(@"存记录1");
        if ([kApp.managedObjectContext save:&error]) {
            for(int i=0;i<[self.downLoadRecordArray count];i++){
                RunClass* oneRunClass = [self.downLoadRecordArray objectAtIndex:i];
                [CNCloudRecord addPlistRecord:oneRunClass];
            }
        }else{
            [self cloudFailed:@"存储下载记录失败"];
            return;
        }
        [self cloudSuccess];
    }
}
- (void)cloudSuccess{
    NSLog(@"同步全部完成");
    [CNUtil appendUserOperation:@"同步全部完成"];
    self.stepDes = @"同步完毕！";
    //重置cloudDiray
    [CNCloudRecord createCloudDiary:self.synTimeNew];
    NSString* NOTIFICATION_REFRESH = @"REFRESH";
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePathsArray" object:nil];
    
}
- (void)cloudFailed:(NSString*)error{
    NSLog(@"同步失败：%@",error);
    [CNUtil appendUserOperation:@"同步失败"];
    self.stepDes = [NSString stringWithFormat:@"同步失败，原因是:%@",error];
}
- (void)synTimeWithServer{
    [self setupSocket];
}
- (void)setupSocket
{
    NSLog(@"一进入程序肯定会初始化---------------");
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    
    if (![self.udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![self.udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    NSLog(@"Ready");
    self.synTimeIndex = 1;
    self.deltaTimeArray = [[NSMutableArray alloc]init];
    [self sendMessage];
}
- (void)sendMessage{
    NSString* dataString = [NSString stringWithFormat:@"TIME:%i",self.synTimeIndex];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:data toHost:@"time.yaopao.net" port:8011 withTimeout:-1 tag:0];
    self.startRequestTime = [CNUtil getNowTime1000];
    NSLog(@"----------------------------------------");
    NSLog(@"startRequestTime is %lli",self.startRequestTime);
    [self performSelector:@selector(checkUDPRes) withObject:nil afterDelay:10];
}
- (void)checkUDPRes{
    if(self.udpRes == nil||[self.udpRes isEqualToString:@""]){//服务器没有响应同步时间udp
        NSLog(@"同步时间udp未响应------------------");
        [self cloudFailed:@"未能同步时间"];
    }else{
        NSLog(@"同步时间udp有相应------------------");
    }
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.udpRes = msg;
    if (msg)
    {
        NSLog(@"接收服务器响应:%@",msg);
        self.endRequestTime = [CNUtil getNowTime1000];
        int order = [[[msg componentsSeparatedByString:@":"] objectAtIndex:1]intValue];
        if(order == 1){//第一次直接不要
            self.synTimeIndex ++ ;
            [self sendMessage];
            return;
        }
        long long serverTime = [[[msg componentsSeparatedByString:@":"] objectAtIndex:2]longLongValue];
        NSLog(@"serverTime is %lli",serverTime);
        int deltaTime = (int)(serverTime-(self.startRequestTime+self.endRequestTime)/2);//取得毫秒数
        NSLog(@"deltaTime is %i",deltaTime);
        NSLog(@"endRequestTime is %lli",self.endRequestTime);
        if(self.endRequestTime - self.startRequestTime < 1000){//间隔小于800毫秒,就直接使用算出来的deltaTime
            self.deltaMiliSecond = deltaTime;
            self.isSynServerTime = YES;
            [self amIInEventTime];
            if(self.forCloud == 1){
                [self cloud_step0];
                self.forCloud = 0;
            }
        }else{//请求时间过长，则存入数组
            NSLog(@"请求时间间隔：%i",(int)(self.endRequestTime - self.startRequestTime));
            [self.deltaTimeArray addObject:[NSString stringWithFormat:@"%lli,%i",(self.endRequestTime - self.startRequestTime),deltaTime]];
            if([self.deltaTimeArray count] == 10){//已经同步了10次了，都请求时间有点长，则取平均值
                NSLog(@"self.deltaTimeArray is %@",self.deltaTimeArray);
                int min = 10000000;
                int minIndex = 0;
                for(int i = 0 ;i < 10 ;i++){
                    int oneRequestTime = [[[[self.deltaTimeArray objectAtIndex:i] componentsSeparatedByString:@","]objectAtIndex:0]intValue];
                    if(oneRequestTime < min){
                        min = oneRequestTime;
                        minIndex = i;
                    }
                }
                NSLog(@"最小的index是%i",minIndex);
                self.deltaMiliSecond = [[[[self.deltaTimeArray objectAtIndex:minIndex] componentsSeparatedByString:@","]objectAtIndex:1]intValue];
                NSLog(@"取得的deltaMiliSecond是%i",self.deltaMiliSecond);
                self.isSynServerTime = YES;
                [self amIInEventTime];
                if(self.forCloud == 1){
                    [self cloud_step0];
                    self.forCloud = 0;
                }
            }else{//没到十次继续请求
                self.synTimeIndex ++ ;
                [self sendMessage];
            }
        }
    }else{
        NSLog(@"------------------------未收到服务器响应");
        [self sendMessage];
    }
}
- (void)amIInEventTime{
    long long nowTime = [CNUtil getNowTimeDelta];
    NSArray* array = [kApp.eventTimeString componentsSeparatedByString:@","];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate* startDate_start = [dateFormatter dateFromString:[array objectAtIndex:0]];
    long long startTime = [startDate_start timeIntervalSince1970];
    NSDate* startDate_end = [dateFormatter dateFromString:[array objectAtIndex:1]];
    long long endTime = [startDate_end timeIntervalSince1970];
    NSLog(@"nowtime is %lli",nowTime);
    NSLog(@"startTime is %lli",startTime);
    NSLog(@"endTime is %lli",endTime);
    if(nowTime >= startTime && nowTime <= endTime){
        kApp.isInEvent = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"eventIcon" object:nil];
    }
}
- (NSString*)replacePlaceHolder:(NSMutableArray*)array :(NSString*)str{
    if(array == nil || [array count] == 0){
        return @"";
    }
    for (int i = 0;i<[array count];i++){
        if([[array objectAtIndex:i] isEqualToString:@"placeholder"]){
            [array replaceObjectAtIndex:i withObject:str];
            break;
        }
    }
    return [self arrayToString:array];
}
- (NSString*)arrayToString:(NSMutableArray*)array{
    if([array count] == 0)return @"";
    NSMutableString* arrayStr = [NSMutableString stringWithString:@""];
    for(NSString* onePath in array){
        if(![onePath isEqualToString:@""]){
            [arrayStr appendString:onePath];
            [arrayStr appendString:@"|"];
        }
    }
    if([arrayStr hasSuffix:@"|"]){
        arrayStr = [NSMutableString stringWithString:[arrayStr substringToIndex:arrayStr.length - 1]];
    }
    return arrayStr;
}
- (NSString*)deletePlaceholderInString:(NSString*)srcString{
    if([srcString isEqualToString:@""]){
        return @"";
    }else{
        NSMutableArray* array = [[NSMutableArray alloc]initWithArray:[srcString componentsSeparatedByString:@"|"]];
        for (int i = 0;i<[array count];i++){
            if([[array objectAtIndex:i] isEqualToString:@"placeholder"]){
                [array replaceObjectAtIndex:i withObject:@""];
            }
        }
        return [self arrayToString:array];
    }
}
@end

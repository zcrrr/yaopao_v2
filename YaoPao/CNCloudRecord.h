//
//  CNCloudRecord.h
//  YaoPao
//
//  Created by zc on 15-1-15.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RunClass;
#import "CNNetworkHandler.h"
@class GCDAsyncUdpSocket;

@interface CNCloudRecord : NSObject<deleteRecordDelegate,cloudDataDelegate,uploadRecordDelegate,downloadRecordDelegate,downloadOneFileDelegate,deleteOneFileDelegate>

@property (strong, nonatomic) NSMutableArray* fileArray;
@property (strong, nonatomic) NSMutableArray* addRecordArray;
@property (strong, nonatomic) NSMutableArray* downLoadRecordArray;
@property (strong, nonatomic) NSMutableArray* editImageAddArray;
@property (assign, nonatomic) long long synTimeNew;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (assign, nonatomic) long long startRequestTime;
@property (assign, nonatomic) long long endRequestTime;
@property (strong, nonatomic) NSMutableArray* deltaTimeArray;
@property (assign, nonatomic) int synTimeIndex;
@property (assign, nonatomic) int deltaMiliSecond;
@property (assign, nonatomic) BOOL isSynServerTime;
@property (assign, nonatomic) int forCloud;
@property (assign, nonatomic) int fileCount;
@property (assign, nonatomic) BOOL userCancel;
@property (strong, nonatomic) NSString* stepDes;
@property (strong, nonatomic) NSString* udpRes;

+ (void)ClearRecordAfterUserLogin;
+ (void)deletePlistRecord:(RunClass*)runclass;
+ (void)addPlistRecord:(RunClass*)runclass;
+ (void)deleteOneRecord:(RunClass*)runclass;
+ (void)deleteAllRecordWhenFirstInstall;


- (void)startCloud;
- (void)synTimeWithServer;

@end

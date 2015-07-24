//
//  main.m
//  YaoPao
//
//  Created by zc on 14-7-14.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CNAppDelegate.h"
#import <tingyunApp/NBSAppAgent.h>

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [NBSAppAgent startWithAppID:@"8e37d48dd9984c8da022ac9b5ca86621"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CNAppDelegate class]));
    }
}
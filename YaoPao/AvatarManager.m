//
//  AvatarManager.m
//  YaoPao
//
//  Created by 张驰 on 15/7/11.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import "AvatarManager.h"
#import "ASIHTTPRequest.h"


@implementation AvatarManager
@synthesize avatarDic;
@synthesize dirPath;

- (void)setImageToImageView:(UIImageView*)iv fromUrl:(NSString*)imageURL{
    //得到图片名称
    NSArray* tempArray = [imageURL componentsSeparatedByString:@"/"];
    NSString* imagename = [tempArray objectAtIndex:[tempArray count]-1];
    NSLog(@"imagename is %@",imagename);
    //看内存中有没有
    NSArray* allImageInMemory = [self.avatarDic allKeys];
    if([allImageInMemory containsObject:imagename]){//内存有
        UIImage* image = [self.avatarDic objectForKey:imagename];
        iv.image = image;
        return;
    }else{//内存无
        //看手机中是否有
        NSString *imageFullPath = [NSString stringWithFormat:@"%@/%@",self.dirPath,imagename];
        NSLog(@"imageFullPath is %@",imageFullPath);
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:imageFullPath];
        if(blHave){//手机中有
            NSData *data = [NSData dataWithContentsOfFile:imageFullPath];
            iv.image = [[UIImage alloc] initWithData:data];
            [self.avatarDic setObject:iv.image forKey:imagename];
            return;
        }else{//手机中无
            //开始下载
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kApp.imageurl,imageURL]];
            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setCompletionBlock :^{
                UIImage* image = [[UIImage alloc] initWithData:[request responseData]];
                iv.image = image;
                [self.avatarDic setObject:image forKey:imagename];
                NSString *imageFullPath = [NSString stringWithFormat:@"%@/%@",self.dirPath,imagename];
                [[request responseData] writeToFile: imageFullPath atomically:YES];
            }];
            [request startAsynchronous ];
        }
    }
}

- (void)setImageToButton:(UIButton*)button fromUrl:(NSString*)imageURL{
    //得到图片名称
    NSArray* tempArray = [imageURL componentsSeparatedByString:@"/"];
    NSString* imagename = [tempArray objectAtIndex:[tempArray count]-1];
    NSLog(@"imagename is %@",imagename);
    //看内存中有没有
    NSArray* allImageInMemory = [self.avatarDic allKeys];
    if([allImageInMemory containsObject:imagename]){//内存有
        UIImage* image = [self.avatarDic objectForKey:imagename];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        return;
    }else{//内存无
        //看手机中是否有
        NSString *imageFullPath = [NSString stringWithFormat:@"%@/%@",self.dirPath,imagename];
        NSLog(@"imageFullPath is %@",imageFullPath);
        BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:imageFullPath];
        if(blHave){//手机中有
            NSData *data = [NSData dataWithContentsOfFile:imageFullPath];
            UIImage* image = [[UIImage alloc] initWithData:data];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            [self.avatarDic setObject:image forKey:imagename];
            return;
        }else{//手机中无
            //开始下载
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kApp.imageurl,imageURL]];
            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setCompletionBlock :^{
                UIImage* image = [[UIImage alloc] initWithData:[request responseData]];
                [button setBackgroundImage:image forState:UIControlStateNormal];
                [self.avatarDic setObject:image forKey:imagename];
                NSString *imageFullPath = [NSString stringWithFormat:@"%@/%@",self.dirPath,imagename];
                [[request responseData] writeToFile: imageFullPath atomically:YES];
            }];
            [request startAsynchronous ];
        }
    }
}
- (void)initAvatarManager{
    //手机目录创建avatar文件夹
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.dirPath = [documentsDirectory stringByAppendingPathComponent:@"avatar"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    self.avatarDic = [[NSMutableDictionary alloc]init];
}
- (UIImage*)getMyAvatar{
    if(kApp.isLogin != 1){
        return nil;
    }else{
        NSString* imgpath = [kApp.userInfoDic objectForKey:@"imgpath"];
        if(imgpath != nil){
            NSArray* tempArray = [imgpath componentsSeparatedByString:@"/"];
            NSString* imagename = [tempArray objectAtIndex:[tempArray count]-1];
            UIImage* image = [self.avatarDic objectForKey:imagename];
            return image;
        }else{
            return nil;
        }
    }
    return nil;
}

@end

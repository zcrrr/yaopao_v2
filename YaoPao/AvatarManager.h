//
//  AvatarManager.h
//  YaoPao
//
//  Created by 张驰 on 15/7/11.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvatarManager : NSObject

@property (strong, nonatomic) NSMutableDictionary* avatarDic;//内存缓存
@property (strong, nonatomic) NSString* dirPath;//手机中的目录


- (void)setImageToImageView:(UIImageView*)iv fromUrl:(NSString*)imageURL;
- (void)setImageToButton:(UIButton*)button fromUrl:(NSString*)imageURL;
- (UIImage*)getMyAvatar;
- (void)initAvatarManager;


@end

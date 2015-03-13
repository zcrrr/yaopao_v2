//
//  CNVoiceHandler.h
//  YaoPao
//
//  Created by zc on 14-9-28.
//  Copyright (c) 2014年 张 驰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CNVoiceHandler : NSObject<AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSMutableArray *arrayOfTracks;

- (void)initPlayer;
- (void)startPlay;

- (NSMutableArray*)voiceOfTime:(int)second;
- (NSMutableArray*) voiceOf2Digit:(int)src :(BOOL)isLiang :(BOOL)isLing;
- (NSMutableArray*) voiceOf5Digit:(int)src :(BOOL)isLiang :(BOOL)isLing;
- (NSMutableArray*)voiceOfDouble:(double)number;
- (void)voiceOfapp:(NSString*)occasion :(NSDictionary*)params;


@end

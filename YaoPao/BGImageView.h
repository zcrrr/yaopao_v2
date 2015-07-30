//
//  scrollImageView.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/3.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMItems.h"

@protocol WMImageViewDelegate <NSObject>

- (NSInteger)numberOfItems;
- (WMItems *)scrollToWaterMark:(NSInteger)index;
@end

@interface BGImageView : UIImageView

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger totalPage;

@property (copy, nonatomic) UIImage *workImage;
@property (assign, nonatomic) id<WMImageViewDelegate> delegate;

//初始化手势
- (void)initGestureRecognizer;
//更新
- (void)reloadScrollImageView;

- (void)AddWaterMark:(UIImage *)workImage withText:(NSString *)text;
@end

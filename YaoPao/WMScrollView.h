//
//  WMScrollView.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/28.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMScrollViewDataSource <NSObject>
- (NSUInteger)numberOfImageViews;
- (UIImage *)imageOfIndex:(NSInteger)index;
@end


@protocol WMScrollViewDelegate <NSObject>
//- (void)DidClickImageAtIndex:(NSInteger)index withImage:(UIImage *)image;
- (void)DidImageViewIndexChanged:(NSInteger)index;

@end

@interface WMScrollView : UIScrollView<UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *imageViews;
@property (assign, nonatomic) NSInteger currentpage;
@property (weak, nonatomic) id<WMScrollViewDataSource> WMDataSource;
@property (weak, nonatomic) id<WMScrollViewDelegate> WMDelegate;

- (void)InitSubViews;
- (void)reloadScrollView:(BOOL)isReOffSet;
- (void)ChangePage:(NSInteger)page;
@end

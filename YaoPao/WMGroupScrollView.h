//
//  WMGroupScrollView.h
//  WaterMarkDemo
//
//  Created by Kelven on 15/7/21.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WMGroupScrollViewDataSource <NSObject>
- (NSUInteger)numberOfWMGroupImageViews;
- (UIImage *)GroupImageOfIndex:(NSInteger)index;
@end


@protocol WMGroupScrollViewDelegate <NSObject>
- (void)DidClickWMGroupImageAtIndex:(NSInteger)index withImage:(UIImage *)image;
- (void)ChangeWhiteAndBlack;
- (void)saveBtnClick;
- (void)AddNewWaterMarkBtnClick;
@end

@interface WMGroupScrollView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *btnArrays;
@property (strong, nonatomic) UIScrollView *myScrollView;
@property (strong, nonatomic) UILabel *LabelView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *whiteOrBlack;
@property (strong, nonatomic) UIButton *saveBtn;
@property (weak, nonatomic) id<WMGroupScrollViewDataSource> WMGroupDataSource;
@property (weak, nonatomic) id<WMGroupScrollViewDelegate> WMGroupDelegate;

- (void)InitSubViews;

@end
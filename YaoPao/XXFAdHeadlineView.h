//
//  XXFAdHeadlineView.m
//  XXFCusromView
//
//  Created by sc on 15-3-6.
//  Copyright (c) 2014年 Oliver. All rights reserved.
//



#import <UIKit/UIKit.h>

/**
 *  本视图代理   实现点击事件
 */
@protocol XXFAdHeadlineViewDelegate <NSObject>
/**
 *  图片点击事件
 *
 *  @param tap 点击
 */
@optional
- (void)tapClick:(int)tag;

@end

@interface XXFAdHeadlineView : UIView<UIScrollViewDelegate>
/**
 *  滚动视图
 */
@property (strong,nonatomic)UIScrollView *scrollView;
/**
 *  图片数组
 */
@property (strong,nonatomic)NSMutableArray *slideImagesArr;
/**
 *  显示页数的小点
 */
@property (strong,nonatomic)UIPageControl *pageControl;
/**
 *  申明代理
 */
@property (assign,nonatomic)id <XXFAdHeadlineViewDelegate>delegate;

/**
 *	@brief	需要传输的数据
 *
 *	@param 	imgArr 	图片数组
 *	@param 	Interval 	滚动时间
 */
- (void)setSlideImgArr:(NSMutableArray*)imgArr Interval:(NSTimeInterval)Interval;

- (void)initSubViews;
@end



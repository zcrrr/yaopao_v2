//
//  WMScrollView.m
//  WaterMarkDemo
//
//  Created by Kelven on 15/6/28.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "WMScrollView.h"

@implementation WMScrollView
@synthesize imageViews;


- (void)InitSubViews{
    
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    //设置scrollview的滚动范围
    NSInteger num = [self.WMDataSource numberOfImageViews];
    CGFloat contentW = num * self.frame.size.width;
    
    self.contentSize = CGSizeMake(contentW, 0);
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    
    if (self.imageViews == nil || self.imageViews.count == 0){
        
        self.imageViews = [[NSMutableArray alloc]init];
        
        CGFloat imageWidth = self.frame.size.width;
        
        for (NSInteger i = 0; i < num; i++){
            
            CGRect frame = self.bounds;
            frame.origin.x = i * imageWidth;
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
            imageView.image = [self.WMDataSource imageOfIndex:i];
            [self.imageViews addObject:imageView];
            [self addSubview:imageView];
        }
    }
}

- (void)reloadScrollView:(BOOL)isReOffSet{
    
    for (UIImageView *view in self.imageViews) {
        
        view.image = nil;
    }
    [self.imageViews removeAllObjects];
    [self InitSubViews];
    
    if (isReOffSet) {
        self.contentOffset = CGPointZero;
    }
}


#pragma -mark scrollview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat imageWidth = self.frame.size.width;
    //偏移量
    CGFloat x = scrollView.contentOffset.x;
    //页码计算
    NSInteger page = (x + imageWidth/2)/imageWidth;
    
    if (self.currentpage != page) {
        
        [self.WMDelegate DidImageViewIndexChanged:page];
    }
    
    self.currentpage = page;
    
}

- (void)ChangePage:(NSInteger)page{
    
    self.currentpage = page;
    
    [UIView animateWithDuration:0.2 animations:^{
         self.contentOffset = CGPointMake(page*self.frame.size.width, self.contentOffset.y);
    }];
   
    
    [self.WMDelegate DidImageViewIndexChanged:page];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    
}
@end
